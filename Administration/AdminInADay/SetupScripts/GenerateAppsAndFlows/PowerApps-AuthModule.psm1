$local:ErrorActionPreference = "Stop"

[Reflection.Assembly]::LoadFile("$(Split-Path $script:MyInvocation.MyCommand.Path)\Microsoft.IdentityModel.Clients.ActiveDirectory.dll") | Out-Null
[Reflection.Assembly]::LoadFile("$(Split-Path $script:MyInvocation.MyCommand.Path)\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll") | Out-Null

function Get-JwtTokenClaims
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$JwtToken
    )

    $tokenSplit = $JwtToken.Split(".")
    $claimsSegment = $tokenSplit[1].Replace(" ", "+");
    
    $mod = $claimsSegment.Length % 4
    if ($mod -gt 0)
    {
        $paddingCount = 4 - $mod;
        for ($i = 0; $i -lt $paddingCount; $i++)
        {
            $claimsSegment += "="
        }
    }

    $decodedClaimsSegment = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($claimsSegment))

    return ConvertFrom-Json $decodedClaimsSegment
}

function Add-PowerAppsAccount
{
    [CmdletBinding()]
    param
    (
        [string] $Audience = "https://management.azure.com/",

        [Parameter(Mandatory = $false)]
        [ValidateSet("prod","preview","tip1", "tip2")]
        [string]$Endpoint = "prod",

        [string]$Username = $null,

        [SecureString]$Password = $null
    )
    
    $authContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext("https://login.windows.net/common");
    $redirectUri = New-Object System.Uri("urn:ietf:wg:oauth:2.0:oob");

    if ($Username -ne $null -and $Password -ne $null)
    {
        $credential = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential($Username, $Password)
        $authResult = $authContext.AcquireToken($Audience, "1950a258-227b-4e31-a9cf-717495945fc2", $credential);
    }
    else {
        $authResult = $authContext.AcquireToken($Audience, "1950a258-227b-4e31-a9cf-717495945fc2", $redirectUri, 1);
    }

    $claims = Get-JwtTokenClaims -JwtToken $authResult.IdToken

    $global:currentSession = @{
        loggedIn = $true;
        idToken = $authResult.IdToken;
        upn = $claims.upn;
        tenantId = $claims.tid;
        userId = $claims.oid;
        refreshToken = $authResult.RefreshToken;
        expiresOn = (Get-Date).AddHours(8);
        resourceTokens = @{
            $Audience = @{
                accessToken = $authResult.AccessToken;
                expiresOn = $authResult.ExpiresOn;
            }
        };
        selectedEnvironment = "~default";
        flowEndpoint = 
            switch ($Endpoint)
            {
                "prod"      { "api.flow.microsoft.com" }
                "preview"   { "preview.api.flow.microsoft.com" }
                "tip1"      { "tip1.api.flow.microsoft.com"}
                "tip2"      { "tip2.api.flow.microsoft.com" }
                default     { throw "Unsupported endpoint '$Endpoint'"}
            };
        powerAppsEndpoint = 
            switch ($Endpoint)
            {
                "prod"      { "api.powerapps.com" }
                "preview"   { "preview.api.powerapps.com" }
                "tip1"      { "tip1.api.powerapps.com"}
                "tip2"      { "tip2.api.powerapps.com" }
                default     { throw "Unsupported endpoint '$Endpoint'"}
            };            
        bapEndpoint = 
            switch ($Endpoint)
            {
                "prod"      { "api.bap.microsoft.com" }
                "preview"   { "preview.api.bap.microsoft.com" }
                "tip1"      { "tip1.api.bap.microsoft.com"}
                "tip2"      { "tip2.api.bap.microsoft.com" }
                default     { throw "Unsupported endpoint '$Endpoint'"}
            };      
        graphEndpoint = 
            switch ($Endpoint)
            {
                "prod"      { "graph.windows.net" }
                "preview"   { "graph.windows.net" }
                "tip1"      { "graph.windows.net"}
                "tip2"      { "graph.windows.net" }
                default     { throw "Unsupported endpoint '$Endpoint'"}
            };
        cdsOneEndpoint = 
            switch ($Endpoint)
            {
                "prod"      { "api.cds.microsoft.com" }
                "preview"   { "preview.api.cds.microsoft.com" }
                "tip1"      { "tip1.api.cds.microsoft.com"}
                "tip2"      { "tip2.api.cds.microsoft.com" }
                default     { throw "Unsupported endpoint '$Endpoint'"}
            };
    };
}

function Test-PowerAppsAccount
{
    [CmdletBinding()]
    param
    (
    )

    if (-not $global:currentSession)
    {
        Add-PowerAppsAccount
    }
}

function Remove-PowerAppsAccount
{
    [CmdletBinding()]
    param
    (
    )

    if ($global:currentSession -ne $null -and $global:currentSession.upn -ne $null)
    {
        Write-Verbose "Logging out $($global:currentSession.upn)"
    }
    else
    {
        Write-Verbose "No user logged in"
    }

    $global:currentSession = @{
        loggedIn = $false;
    };
}

function Get-JwtToken
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $Audience
    )

    if ($global:currentSession -eq $null)
    {
        $global:currentSession = @{
            loggedIn = $false;
        };
    }

    if ($global:currentSession.loggedIn -eq $false -or $global:currentSession.expiresOn -lt (Get-Date))
    {
        Write-Verbose "No user logged in. Signing the user in before acquiring token."
        Add-PowerAppsAccount -Audience $Audience
    }

    if ($global:currentSession.resourceTokens[$Audience] -eq $null -or `
        $global:currentSession.resourceTokens[$Audience].accessToken -eq $null -or `
        $global:currentSession.resourceTokens[$Audience].expiresOn -eq $null -or `
        $global:currentSession.resourceTokens[$Audience].expiresOn -lt (Get-Date))
    {

        Write-Verbose "Token for $Audience is either missing or expired. Acquiring a new one."

        $tenantId = $global:currentSession.tenantId
        $authContext = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext("https://login.windows.net/$tenantId");
        $refreshTokenResult = $authContext.AcquireTokenByRefreshToken($global:currentSession.refreshToken, "1950a258-227b-4e31-a9cf-717495945fc2", $Audience)
        $global:currentSession.resourceTokens[$Audience] = @{
            accessToken = $refreshTokenResult.AccessToken;
            expiresOn = $refreshTokenResult.ExpiresOn;
        }
    }

    return $global:currentSession.resourceTokens[$Audience].accessToken;
}

function Invoke-OAuthDialog
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $ConsentLinkUri
    )

    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{ Width=440; Height=640 }
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{ Width=420; Height=600; Url=$ConsentLinkUri }
    $DocComp  = {
        $Global:uri = $web.Url.AbsoluteUri        
        if ($Global:uri -match "error=[^&]*|code=[^&]*")
        {
            $form.Close()
        }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null
    $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)

    $output = @{}

    foreach($key in $queryOutput.Keys)
    {
        $output["$key"] = $queryOutput[$key]
    }
    
    return $output
}


function Get-TenantDetailsFromGraph
{
 <#
 .SYNOPSIS
 .
 .DESCRIPTION
 The Get-TenantDetailsFromGraph function . 
 Use Get-Help Get-TenantDetailsFromGraph -Examples for more detail.
 .EXAMPLE
 Get-TenantDetailsFromGraph
 .
 #>
    param
    (
        [string]$GraphApiVersion = "1.6"
    )

    process 
    {
        $TenantIdentifier = "myorganization"

        $route = "https://{graphEndpoint}/{tenantIdentifier}/tenantDetails`?api-version={graphApiVersion}" `
        | ReplaceMacro -Macro "{tenantIdentifier}" -Value $TenantIdentifier `
        | ReplaceMacro -Macro "{graphApiVersion}" -Value $GraphApiVersion;

        $graphResponse = InvokeApi -Method GET -Route $route
        
        CreateTenantObject -TenantObj $graphResponse.value

    }
}

#Returns users or groups from Graph
#wrapper on top of https://msdn.microsoft.com/en-us/library/azure/ad/graph/api/users-operations & https://msdn.microsoft.com/en-us/library/azure/ad/graph/api/groups-operations 
function Get-UsersOrGroupsFromGraph(
)
{
    [CmdletBinding(DefaultParameterSetName="Id")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$ObjectId,

        [Parameter(Mandatory = $true, ParameterSetName = "Search")]
        [string]$SearchString,

        [Parameter(Mandatory = $false, ParameterSetName = "Search")]
        [Parameter(Mandatory = $false, ParameterSetName = "Id")]
        [string]$GraphApiVersion = "1.6"
    )

    Process
    {
        if (-not [string]::IsNullOrWhiteSpace($ObjectId))
        {
            $userGraphUri = "https://graph.windows.net/myorganization/users/{userId}`?&api-version={graphApiVersion}" `
            | ReplaceMacro -Macro "{userId}" -Value $ObjectId `
            | ReplaceMacro -Macro "{graphApiVersion}" -Value $GraphApiVersion;

            $userGraphResponse = InvokeApi -Route $userGraphUri -Method GET
            
            If($userGraphResponse.StatusCode -eq $null)
            {
                CreateUserObject -UserObj $userGraphResponse
            }

            $groupsGraphUri = "https://graph.windows.net/myorganization/groups/{groupId}`?api-version={graphApiVersion}" `
            | ReplaceMacro -Macro "{groupId}" -Value $ObjectId `
            | ReplaceMacro -Macro "{graphApiVersion}" -Value $GraphApiVersion;

            $groupGraphResponse = InvokeApi -Route $groupsGraphUri -Method GET

            If($groupGraphResponse.StatusCode -eq $null)
            {
                CreateGroupObject -GroupObj $groupGraphResponse
            }
        }
        else 
        {
            $userFilter = "startswith(userPrincipalName,'$SearchString') or startswith(displayName,'$SearchString')"
    
            $userGraphUri = "https://graph.windows.net/myorganization/users`?`$filter={filter}&api-version={graphApiVersion}" `
            | ReplaceMacro -Macro "{filter}" -Value $userFilter `
            | ReplaceMacro -Macro "{graphApiVersion}" -Value $GraphApiVersion;

            $userGraphResponse = InvokeApi -Route $userGraphUri -Method GET
    
            foreach($user in $userGraphResponse.value)
            {
                CreateUserObject -UserObj $user
            }

            $groupFilter = "startswith(displayName,'$SearchString')"
    
            $groupsGraphUri = "https://graph.windows.net/myorganization/groups`?`$filter={filter}&api-version={graphApiVersion}" `
            | ReplaceMacro -Macro "{filter}" -Value $groupFilter `
            | ReplaceMacro -Macro "{graphApiVersion}" -Value $GraphApiVersion;

            $groupsGraphResponse = Invoke-Request -Uri $groupsGraphUri -Method GET -ParseContent -ThrowOnFailure
    
            foreach($group in $groupsGraphResponse.value)
            {
                CreateGroupObject -GroupObj $group
            }    
        }
    }
}


function CreateUserObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$UserObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ObjectType -Value $UserObj.objectType `
        | Add-Member -PassThru -MemberType NoteProperty -Name ObjectId -Value $UserObj.objectId `
        | Add-Member -PassThru -MemberType NoteProperty -Name UserPrincipalName -Value $UserObj.userPrincipalName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Mail -Value $UserObj.mail `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $UserObj.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name AssignedLicenses -Value $UserObj.assignedLicenses `
        | Add-Member -PassThru -MemberType NoteProperty -Name AssignedPlans -Value $UserObj.assignedLicenses `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $UserObj;
}

function CreateGroupObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$GroupObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ObjectType -Value $GroupObj.objectType `
        | Add-Member -PassThru -MemberType NoteProperty -Name Objectd -Value $GroupObj.objectId `
        | Add-Member -PassThru -MemberType NoteProperty -Name Mail -Value $GroupObj.mail `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $GroupObj.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $GroupObj;
}


function CreateTenantObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$TenantObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ObjectType -Value $TenantObj.objectType `
        | Add-Member -PassThru -MemberType NoteProperty -Name TenantId -Value $TenantObj.objectId `
        | Add-Member -PassThru -MemberType NoteProperty -Name Country -Value $TenantObj.countryLetterCode `
        | Add-Member -PassThru -MemberType NoteProperty -Name Language -Value $TenantObj.preferredLanguage `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $TenantObj.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Domains -Value $TenantObj.verifiedDomains `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $TenantObj;
}
