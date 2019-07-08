Import-Module (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "PowerApps-RestClientModule.psm1") -Force
Import-Module (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "PowerApps-AuthModule.psm1") -Force


function Add-ConnectorToBusinessDataGroup
{
    <#
    .SYNOPSIS
    Sets connector to the business data group of data loss policy
    .DESCRIPTION
    The Add-ConnectorToBusinessDataGroup set connector to the business data group of DLP depending on parameters. 
    Use Get-Help Add-ConnectorToBusinessDataGroup -Examples for more detail.
    .PARAMETER PolicyName
    The PolicyName's identifier.
    .PARAMETER ConnectorName
    The Connector's identifier.
    .PARAMETER ApiVersion
    The api version to call with. Default 2018-01-01
    .EXAMPLE
    Add-ConnectorToBusinessDataGroup -PolicyName e25a94b2-3111-468e-9125-3d3db3938f13 -ConnectorName shared_office365users
    Sets the connector to BusinessData group of policyname e25a94b2-3111-468e-9125-3d3db3938f13
    #> 
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PolicyName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2018-01-01"
    )
    process 
    {

        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policyname}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{policyname}" -Value $PolicyName;

        $policy = InvokeApi -Method Get -Route $route -ThrowOnFailure -ApiVersion $ApiVersion

        #collect the provided json from lbi api list 
        #$providedConnectorJson = $policy.properties.definition.apiGroups.lbi.apis | where { $_.id -match $ConnectorName }
        $providedConnectorJson = $policy.properties.definition.apiGroups.lbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }
        

        if($providedConnectorJson -ne $null)
        {

            #Add it to the hbi object of policy
            $policy.properties.definition.apiGroups.hbi.apis += $providedConnectorJson

            #remove from lbi object of policy
            $lbiWithoutProvidedConnector = $policy.properties.definition.apiGroups.lbi.apis -ne $providedConnectorJson
            $policy.properties.definition.apiGroups.lbi.apis =  $lbiWithoutProvidedConnector

            #APi Call
            $setConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

            CreateHttpResponse($setConnectorResult)
        }
        else
        {
            #$providedConnectorJson = $policy.properties.definition.apiGroups.hbi.apis | where { $_.id -match $ConnectorName }
            $providedConnectorJson = $policy.properties.definition.apiGroups.hbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }

            if($providedConnectorJson -eq $null)
            {
                Write-Error "No connector with specified name found"
            }
            else
            {
                Write-Error "Connector already exists in business data group"
            }
            return $null
        }
    }
}

function Remove-ConnectorFromBusinessDataGroup
{
     <#
    .SYNOPSIS
    Removes connector to the business data group of data loss policy
    .DESCRIPTION
    The Remove-ConnectorFromBusinessDataGroup removes connector from the business data group of DLP depending on parameters. 
    Use Get-Help Remove-ConnectorFromBusinessDataGroup -Examples for more detail.
    .PARAMETER PolicyName
    The PolicyName's identifier.
    .PARAMETER ConnectorName
    The Connector's identifier.
    .PARAMETER ApiVersion
    The api version to call with. Default 2018-01-01
    .EXAMPLE
    Remove-ConnectorFromBusinessDataGroup -PolicyName e25a94b2-3111-468e-9125-3d3db3938f13 -ConnectorName shared_office365users
    Removes the connector from BusinessData group of policyname e25a94b2-3111-468e-9125-3d3db3938f13
    #> 
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PolicyName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2018-01-01"
    )
    process 
    {

        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policyname}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{policyname}" -Value $PolicyName;

        $policy = InvokeApi -Route $route -Method Get -ThrowOnFailure -ApiVersion $ApiVersion

        #collect the provided json from lbi api list 
        $providedConnectorJson = $policy.properties.definition.apiGroups.hbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }

        if($providedConnectorJson -ne $null)
        {
            #Add it to the lbi object of policy
            $policy.properties.definition.apiGroups.lbi.apis += $providedConnectorJson

            #remove from hbi object of policy
            $hbiWithoutProvidedConnector = $policy.properties.definition.apiGroups.hbi.apis -ne $providedConnectorJson
            $policy.properties.definition.apiGroups.hbi.apis =  $hbiWithoutProvidedConnector

            #APi Call
            $removeConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

            CreateHttpResponse($removeConnectorResult)
        }
        else
        {
            $providedConnectorJson = $policy.properties.definition.apiGroups.lbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }
            if($providedConnectorJson -eq $null)
            {
                Write-Error "No connector with specified name found"
            }
            else
            {
                Write-Error "Connector does not exists in business data group"
            }
            return $null
        }
    }
}

function Add-CustomConnectorToGroup
{
    <#
    .SYNOPSIS
    Adds a custom connector to the given group.
    .DESCRIPTION
    The Add-CustomConnectorToGroup adds a custom connector to a specific group of a DLP policy depending on parameters.
    Use Get-Help Add-CustomConnectorToGroup -Examples for more detail.
    .PARAMETER PolicyName
    The PolicyName's identifier.
    .PARAMETER GroupName
    The name of the group to add the connector to, lbi or hbi.
    .PARAMETER ConnectorName
    The Custom Connector's name.
    .PARAMETER ConnectorId
    The Custom Connector's ID.
    .PARAMETER ConnectorType
    The Custom Connector's type.
    .PARAMETER ApiVersion
    The api version to call with. Default 2018-01-01
    .EXAMPLE
    Add-CustomConnectorToGroup -PolicyName 7b914a18-ad8b-4f15-8da5-3155c77aa70a -ConnectorName BloopBlop -ConnectorId /providers/Microsoft.PowerApps/apis/BloopBlop -ConnectorType Microsoft.PowerApps/apis -GroupName hbi
    Adds the custom connector 'BloopBlop' to BusinessData group of policy name 7b914a18-ad8b-4f15-8da5-3155c77aa70a
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PolicyName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string][ValidateSet("lbi", "hbi")]$GroupName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorType,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2018-01-01"
    )
    process
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policyname}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{policyname}" -Value $PolicyName;

        $policy = InvokeApi -Method Get -Route $route -ThrowOnFailure -ApiVersion $ApiVersion

        $connectorJsonLbi = $policy.properties.definition.apiGroups.lbi.apis | where { $_.id -eq $ConnectorId }
        $connectorJsonHbi = $policy.properties.definition.apiGroups.hbi.apis | where { $_.id -eq $ConnectorId }


        if($connectorJsonLbi -eq $null -and $connectorJsonHbi -eq $null)
        {
            $customConnectorJson = @{
                id = $ConnectorId
                name = $ConnectorName
                type = $ConnectorType
            }

            if ($GroupName -eq "hbi")
            {
                #Add it to the hbi object of policy
                $policy.properties.definition.apiGroups.hbi.apis += $customConnectorJson
            }
            else
            {
                #Add it to the lbi object of policy
                $policy.properties.definition.apiGroups.lbi.apis += $customConnectorJson
            }

            #APi Call
            $setConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

            CreateHttpResponse($setConnectorResult)
        }
        else
        {
            if($connectorJsonLbi -eq $null)
            {
                Write-Error "The given connector is already present in the hbi group."
            }
            else
            {
                Write-Error "The given connector is already present in the lbi group."
            }
            return $null
        }
    }
}

function Delete-CustomConnectorFromPolicy
{
    <#
    .SYNOPSIS
    Deletes a custom connector from the given DLP policy.
    .DESCRIPTION
    The Delete-CustomConnectorFromPolicy deletes a custom connector from the specific DLP policy. 
    Use Get-Help Delete-CustomConnectorFromPolicy -Examples for more detail.
    .PARAMETER PolicyName
    The PolicyName's identifier.
    .PARAMETER ConnectorName
    The Custom Connector's name.
    .PARAMETER ApiVersion
    The api version to call with. Default 2018-01-01
    .EXAMPLE
    Delete-CustomConnectorFromPolicy -PolicyName 7b914a18-ad8b-4f15-8da5-3155c77aa70a -ConnectorName BloopBlop
    Deletes the custom connector 'BloopBlop' from the DLP policy of policy name 7b914a18-ad8b-4f15-8da5-3155c77aa70a
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$PolicyName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2018-01-01"
    )
    process
    {

        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policyname}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{policyname}" -Value $PolicyName;

        $policy = InvokeApi -Method Get -Route $route -ThrowOnFailure -ApiVersion $ApiVersion

        $connectorJsonLbi = $policy.properties.definition.apiGroups.lbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }
        $connectorJsonHbi = $policy.properties.definition.apiGroups.hbi.apis | where { ($_.id -split "/apis/")[1] -eq $ConnectorName }


        if($connectorJsonLbi -eq $null -and $connectorJsonHbi -eq $null)
        {
            Write-Error "The given connector is not in the policy."
            return $null

                $customConnectorJson = @{
                    id = $ConnectorId
                    name = $ConnectorName
                    type = $ConnectorType
                }

                if ($GroupName -eq "hbi")
                {
                    #Add it to the hbi object of policy
                    $policy.properties.definition.apiGroups.hbi.apis += $customConnectorJson
                }
                else
                {
                    #Add it to the lbi object of policy
                    $policy.properties.definition.apiGroups.lbi.apis += $customConnectorJson
                }

                #APi Call
                $setConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

                CreateHttpResponse($setConnectorResult)
        }
        else
        {
            if($connectorJsonLbi -eq $null)
            {
                #remove from hbi object of policy
                $hbiWithoutProvidedConnector = $policy.properties.definition.apiGroups.hbi.apis -ne $connectorJsonHbi
                $policy.properties.definition.apiGroups.hbi.apis =  $hbiWithoutProvidedConnector

                #APi Call
                $removeConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

                CreateHttpResponse($removeConnectorResult)
            }
            else
            {
                #remove from hbi object of policy
                $lbiWithoutProvidedConnector = $policy.properties.definition.apiGroups.lbi.apis -ne $connectorJsonLbi
                $policy.properties.definition.apiGroups.lbi.apis =  $lbiWithoutProvidedConnector

                #APi Call
                $removeConnectorResult = InvokeApiNoParseContent -Method PUT -Body $policy -Route $route -ApiVersion $ApiVersion

                CreateHttpResponse($removeConnectorResult)
            }
        }
    }
}

function Get-AdminPowerAppConnectionReferences
{
 <#
 .SYNOPSIS
 Returns app connection references.
 .DESCRIPTION
 The Get-AdminPowerAppConnectionList information about all connections referenced in an input PowerApp. 
 Use Get-Help Get-AdminPowerAppConnectionList -Examples for more detail.
 .PARAMETER AppName
 PowerApp to list connectors for.
 .PARAMETER EnvironmentName
 Environment where the input PowerApp is located.
 .EXAMPLE
 Get-AdminPowerAppConnectionList -EnvironmentName 643268a6-c680-446f-b8bc-a3ebbf98895f -AppName fc947231-728a-4a74-a654-64b0f22a0d71
 Returns all connections referenced in the PowerApp fc947231-728a-4a74-a654-64b0f22a0d71.
 #>
    [CmdletBinding(DefaultParameterSetName="Connector")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,
        [Parameter(Mandatory = $true, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName
    )
    process
    {
        $app = Get-AdminPowerApp -EnvironmentName $EnvironmentName -AppName $AppName

        foreach($conRef in $app.Internal.properties.connectionReferences)
        {
            foreach($connection in $conRef)
            {
                foreach ($connId in ($connection | Get-Member -MemberType NoteProperty).Name)
                {
                    Get-AdminPowerAppConnection -EnvironmentName $EnvironmentName -ConnectorName ($($connection.$connId).id -split '/apis/')[1]
                }
            }
        }
    }
}

function Get-AdminPowerAppConnector
{
 <#
 .SYNOPSIS
 Returns information about one or more custom connectors.
 .DESCRIPTION
 The Get-AdminConnector looks up information about one or more custom connectors depending on parameters. 
 Use Get-Help Get-AdminConnector -Examples for more detail.
 .PARAMETER Filter
 Finds custom connector matching the specified filter (wildcards supported).
 .PARAMETER ConnectorName
 Limit custom connectors returned to those of a specified connector.
 .PARAMETER EnvironmentName
 Limit custom connectors returned to those in a specified environment.
 .PARAMETER CreatedBy
 Limit custom connectors returned to those created by the specified user (email or AAD Principal object id)
 .PARAMETER ApiVersion
 The api version to call with. Default 2017-05-01
 .EXAMPLE
 Get-AdminConnector
 Returns all custom connector from all environments where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminConnector *customapi*
 Returns all custom connectors with the text "customapi" in the name/display name from all environments where the calling user is an Environment Admin  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminConnector -CreatedBy foo@bar.onmicrosoft.com
 Returns all apps created by the user with an email of "foo@bar.onmicrosoft.com" from all environment where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminConnector -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f
 Finds custom connectors within the 0fc02431-15fb-4563-a5ab-8211beb2a86f environment
  .EXAMPLE
 Get-AdminConnector -ConnectorName shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698
 Finds all custom connectosr created with name/id shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698 from all environments where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminConnector -ConnectorName shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698 -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f
 Finds connections within the 0fc02431-15fb-4563-a5ab-8211beb2a86f environment that are created against the shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698.
 .EXAMPLE
 Get-AdminConnector *customapi* -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f
 Finds all connections in environment 0fc02431-15fb-4563-a5ab-8211beb2a86f that contain the string "customapi" in their display name.
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "User")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$CreatedBy,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector")]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2017-05-01"
    )

    process 
    {
        # If the connector name is specified, only return connections for that connector
        if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
        {
            $environments = @();
 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $environments += @{
                    EnvironmentName = $EnvironmentName
                }
            }
            else 
            {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false
            }

            foreach($environment in $environments)
            {

                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environmentName}/apis?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{environmentName}" -Value $environment.EnvironmentName;

                $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                # There is no api endpoint with connector name to get the details for specified connector, so assigning filter to connectorname to just return the specified connector details
                Get-FilteredCustomConnectors -Filter $ConnectorName -CreatedBy $CreatedBy -ConnectorResult $connectionResult
            }
        }
        else
        {
            # If the caller passed in an environment scope, filter the query to only that environment 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environmentName}/apis?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;    

                $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                Get-FilteredCustomConnectors -Filter $Filter -CreatedBy $CreatedBy -ConnectorResult $connectionResult
            }
            # otherwise search for the apps acroos all environments for this calling user
            else 
            {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false

                foreach($environment in $environments)
                {
                    $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environmentName}/apis?api-version={apiVersion}" `
                    | ReplaceMacro -Macro "{environmentName}" -Value $environment.EnvironmentName;    
    
                    $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion
    
                    Get-FilteredCustomConnectors -Filter $Filter -CreatedBy $CreatedBy -ConnectorResult $connectionResult                 
                }
            }
        }
    }
}

function Get-AdminPowerAppConnectorRoleAssignment
{
 <#
 .SYNOPSIS
 Returns the connection role assignments for a user or a custom connection. Owner role assignments cannot be deleted without deleting the connection resource.
 .DESCRIPTION
 The Get-AdminConnectorRoleAssignment functions returns all roles assignments for an custom connector or all custom connectors roles assignments for a user (across all of their connections).  A connection's role assignments determine which users have access to the connection for using or building apps and flows and with which permission level (CanUse, CanUseAndShare) . 
 Use Get-Help Get-AdminPowerAppConnectorRoleAssignment -Examples for more detail.
 .PARAMETER EnvironmentName
 The connector's environment. 
 .PARAMETER ConnectorName
 The connector's identifier.
 .PARAMETER PrincipalObjectId
 The objectId of a user or group, if specified, this function will only return role assignments for that user or group.
 .EXAMPLE
 Get-AdminPowerAppConnectorRoleAssignment
 Returns all role assignments for all custom connectors in all environments
 .EXAMPLE
 Get-AdminPowerAppConnectorRoleAssignment -ConnectorName shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698
 Returns all role assignments for the connector with name shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698 in all environments
 .EXAMPLE
 Get-AdminPowerAppConnectorRoleAssignment -ConnectorName shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698 -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f -PrincipalObjectId a1caec2d-8b48-40cc-8eb8-5cf95b445b46
 Returns all role assignments for the user, or group with an principal object id of a1caec2d-8b48-40cc-8eb8-5cf95b445b46 for the custom connector with name shared_customapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698 in environment with name 0fc02431-15fb-4563-a5ab-8211beb2a86f
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $selectedObjectId = $null

        if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        #If Both EnvironmentName and ConnectorName is Provided, Get the details of provided connector in provided Environment
        if (-not [string]::IsNullOrWhiteSpace($ConnectorName) -and -not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/permissions?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $connectorRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            foreach ($connectorRole in $connectorRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($connectorRole.properties.principal.id ) -or
                        $pattern.IsMatch($connectorRole.properties.principal.email) -or 
                        $pattern.IsMatch($connectorRole.properties.principal.tenantId))
                    {
                        CreateCustomConnectorRoleAssignmentObject -ConnectorRoleAssignmentObj $connectorRole -EnvironmentName $EnvironmentName
                    }
                }
                else 
                { 
                    CreateCustomConnectorRoleAssignmentObject -ConnectorRoleAssignmentObj $connectorRole -EnvironmentName $EnvironmentName
                }
            }
        }
        else 
        {
            # only if EnvironmentName is provided, get the details of specified environment
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $connectorsList = Get-AdminPowerAppConnector -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion
            }
            #only if ConnectorName is provided, get the details of specified ConnectorName in all environments
            elseif(-not [string]::IsNullOrWhiteSpace($ConnectorName))
            {
                $connectorsList = Get-AdminPowerAppConnector -ConnectorName $ConnectorName -ApiVersion $ApiVersion
            }
            else
            {
                $connectorsList = Get-AdminPowerAppConnector -ApiVersion $ApiVersion           
            }

            foreach($connector in $connectorsList)
            {
                Get-AdminPowerAppConnectorRoleAssignment `
                    -ConnectorName $connector.ConnectorName `
                    -EnvironmentName $connector.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion
            }
        }
    }
}

function Set-AdminPowerAppConnectorRoleAssignment
{
    <#
    .SYNOPSIS
    Sets permissions to the custom connectors.
    .DESCRIPTION
    The Set-AdminPowerAppConnectorRoleAssignment set up permission to custom connectors depending on parameters. 
    Use Get-Help Set-AdminPowerAppConnectorRoleAssignment -Examples for more detail.
    .PARAMETER ConnectorName
    The custom connector's identifier.
    .PARAMETER EnvironmentName
    The connectors's environment. 
    .PARAMETER RoleName
    Specifies the permission level given to the connector: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
    .PARAMETER PrincipalType
    Specifies the type of principal this connector is being shared with; a user, a security group, the entire tenant.
    .PARAMETER PrincipalObjectId
    If this connector is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
    .EXAMPLE
   Set-AdminPowerAppConnectorRoleAssignment -ConnectorName shared_testapi.5f0629412a7d1fe83e.5f6f049093c9b7a698 -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f -RoleName CanView -PrincipalType User -PrincipalObjectId a9f34b89-b7f2-48ef-a3ca-1c435bc655a0
    Give the specified user CanView permissions to the connector with name shared_testapi.5f0629412a7d1fe83e.5f6f049093c9b7a698
    #> 
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $TenantId = $Global:currentSession.tenantId

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/modifyPermissions?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body 
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{ 
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            principal = @{
                                id = $TenantId
                                tenantId = $TenantId
                            }          
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{ 
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            principal = @{
                                id = $PrincipalObjectId
                            }               
                        }
                    }
                )
            }
        }
        
        $setConnectorRoleResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($setConnectorRoleResult)
    }
}

function Remove-AdminPowerAppConnectorRoleAssignment
{
 <#
 .SYNOPSIS
 Deletes a connector role assignment record.
 .DESCRIPTION
 The Remove-AdminPowerAppConnectorRoleAssignment deletes the specific connector role assignment
 Use Get-Help Remove-AdminPowerAppConnectorRoleAssignment -Examples for more detail.
 .PARAMETER RoleId
 The id of the role assignment to be deleted.
 .PARAMETER ConnectorName
 The connector name
 .PARAMETER EnvironmentName
 The connector's environment. 
 .EXAMPLE
 Remove-AdminPowerAppConnectorRoleAssignment -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f -ConnectorName shared_testapi.5f0629412a7d1fe83e.5f6f049093c9b7a698 -RoleId /providers/Microsoft.PowerApps/scopes/admin/environments/0fc02431-15fb-4563-a5ab-8211beb2a86f/apis/shared_testapi.5f0629412a7d1fe83e.5f6f049093c9b7a698/permissions/a9f34b89-b7f2-48ef-a3ca-1c435bc655a0
 Deletes the role assignment with an id of /providers/Microsoft.PowerApps/scopes/admin/environments/0fc02431-15fb-4563-a5ab-8211beb2a86f/apis/shared_testapi.5f0629412a7d1fe83e.5f6f049093c9b7a698/permissions/a9f34b89-b7f2-48ef-a3ca-1c435bc655a0
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/modifyPermissions`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName `
        | ReplaceMacro -Macro "{apiVersion}"  -Value $ApiVersion;

        #Construct the body 
        $requestbody = $null
        
        $requestbody = @{ 
            delete = @(
                @{ 
                    id = $RoleId
                }
            )
        }
    
        $removeResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion

        If($removeResult -eq $null)
        {
            return $null
        }
        
        CreateHttpResponse($removeResult)
    }
}

function Remove-AdminPowerAppConnector
{
 <#
 .SYNOPSIS
 Deletes the custom connector.
 .DESCRIPTION
 The Remove-AdminPowerAppConnector permanently deletes the custom connector. 
 Use Get-Help Remove-AdminPowerAppConnector -Examples for more detail.
 .PARAMETER ConnectorName
 The connector's connector name.
 .PARAMETER EnvironmentName
 The connector's environment.
 .EXAMPLE
 Remove-AdminPowerAppConnector -EnvironmentName 0fc02431-15fb-4563-a5ab-8211beb2a86f -ConnectorName shared_testapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698
 Deletes the custom connector with name shared_testapi2.5f0629412a7d1fe83e.5f6f049093c9b7a698
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        $removeResult = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        If($removeResult -eq $null)
        {
            return $null
        }
        
        CreateHttpResponse($removeResult)
    }
}

function Get-AdminPowerAppsUserDetails
{
 <#
 .SYNOPSIS
 Downloads the user details into specified filepath
 .DESCRIPTION
 The Get-AdminPowerAppsUserDetails downloads the powerApps user details into the specified path file
 Use Get-Help Get-AdminPowerAppsUserDetails -Examples for more detail.
 .PARAMETER UserPrincipalName
 The user principal name
 .PARAMETER OutputFilePath
 The Output FilePath 
 .EXAMPLE
 Get-AdminPowerAppsUserDetails -OutputFilePath C:\Users\testuser\userdetails.json
 Donloads the details of calling user into specified path file C:\Users\testuser\userdetails.json
 .EXAMPLE
 Get-AdminPowerAppsUserDetails -UserPrincipalName foo@bar.com -OutputFilePath C:\Users\testuser\userdetails.json
 downloads the details of user with principal name foo@bar.com into specified file path C:\Users\testuser\userdetails.json
 #>
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$UserPrincipalName = $null,

        [Parameter(Mandatory = $true)]
        [string]$OutputFilePath = $null,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {
        #Construct the body 
        $requestbody = $null

        if (-not [string]::IsNullOrWhiteSpace($UserPrincipalName))
        {
            $requestbody = @{
                userPrincipalName = $UserPrincipalName
            }
        }
        #first post call would just return the status 'ACCEPTED' and Location in Headers
        #keep calling Get Location Uri until the job gets finished and once the job gets finished it returns http 'OK' and SAS uri otherwise 'ACCEPTED'
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/exportHiddenUserData?api-version={apiVersion}";

        #Kick-off the job
        $getUserDataJobKickOffResponse = InvokeApiNoParseContent -Route $route -Method POST -Body $requestbody -ThrowOnFailure -ApiVersion $ApiVersion

        $statusUrl = $getUserDataJobKickOffResponse.Headers['Location']

        #Wait until job is completed
        if (-not [string]::IsNullOrWhiteSpace($statusUrl))
        {
            while($getJobCompletedResponse.StatusCode -ne 200) 
            {
                Start-Sleep -s 3
                $getJobCompletedResponse = InvokeApiNoParseContent -Route $statusUrl -Method GET -ThrowOnFailure
            }

            CreateHttpResponse($getJobCompletedResponse)

            $responseBody = ConvertFrom-Json $getJobCompletedResponse.Content

            try {
                $downloadCsvResponse = Invoke-WebRequest -Uri $responseBody -OutFile $OutputFilePath
                Write-Host "Downloaded to specified file"
            } catch {
                Write-Host "Error while downloading"
                $response = $_.Exception.Response
                if ($_.ErrorDetails)
                {
                    $errorResponse = ConvertFrom-Json $_.ErrorDetails;
                    $code = $response.StatusCode
                    $message = $errorResponse.error.message
                    Write-Verbose "Status Code: '$code'. Message: '$message'" 
                }
            }
        }
    }
}

#internal, helper function
function Get-FilteredCustomConnectors
{
     param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$CreatedBy,

        [Parameter(Mandatory = $false)]
        [object]$ConnectorResult
    )

    $patternCreatedBy = BuildFilterPattern -Filter $CreatedBy
    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($connector in $ConnectorResult.Value)
    {
        if ($patternCreatedBy.IsMatch($connector.properties.createdBy.displayName) -or
            $patternCreatedBy.IsMatch($connector.properties.createdBy.email) -or 
            $patternCreatedBy.IsMatch($connector.properties.createdBy.id) -or 
            $patternCreatedBy.IsMatch($connector.properties.createdBy.userPrincipalName))
        {
            if ($patternFilter.IsMatch($connector.name) -or
                $patternFilter.IsMatch($connector.properties.displayName))
            {
                CreateCustomConnectorObject -CustomConnectorObj $connector
            }
        }
    }
}

#internal, helper function
function CreateCustomConnectorObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$CustomConnectorObj
    )
    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value $CustomConnectorObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorId -Value $CustomConnectorObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name ApiDefinitions -Value $CustomConnectorObj.properties.apiDefinitions `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $CustomConnectorObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $CustomConnectorObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -Value $CustomConnectorObj.properties.createdBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $CustomConnectorObj.properties.changedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $CustomConnectorObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $CustomConnectorObj.properties;
}

#internal, helper function
function CreateCustomConnectorRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectorRoleAssignmentObj,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    If($ConnectorRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    elseif($ConnectorRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectorRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $ConnectorRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    elseif($ConnectorRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectorRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectorRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectorRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectorRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectorRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectorRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectorRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectorRoleAssignmentObj;
    }
    else {
        return $null
    }
}

function New-AdminPowerAppEnvironment
{
<#
 .SYNOPSIS
 Creates an Environment.
 .DESCRIPTION
 The New-AdminPowerAppEnvironment cmdlet creates a new Environment by the logged in user.
 Use Get-Help New-AdminPowerAppEnvironment -Examples for more detail.
 .PARAMETER DisplayName
 The display name of the new Environment.
 .PARAMETER LocationName
 The location of the new Environment. Use Get-AdminPowerAppEnvironmentLocations to see the valid locations.
 .PARAMETER EnvironmentSku
 The Environment type (Trial or Production).
 .EXAMPLE
 New-AdminPowerAppEnvironment -DisplayName 'HQ Apps' -Location unitedstates -EnvironmentSku Trial
 Creates a new Trial Environment in the United States with the display name 'HQ Apps'
 .EXAMPLE
 New-AdminPowerAppEnvironment -DisplayName 'Asia Dev' -Location asia -EnvironmentSku Production
 Creates a new Production Environment in Asia with the display name 'Asia Dev'
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$DisplayName,

        [Parameter(Mandatory = $true, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$LocationName,

        [ValidateSet("Trial", "Production")]
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$EnvironmentSku,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2018-01-01"
    )
    process
    {
        $postEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/environments`?api-version={apiVersion}&id=/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments";

        $environment = @{
            location = $LocationName
            properties = @{
                displayName = $DisplayName
                environmentSku = $EnvironmentSku
            }
        }
    
        $response = InvokeApi -Method POST -Route $postEnvironmentUri -ApiVersion $ApiVersion -Body $environment

        if ($response.StatusCode -eq "BadRequest")
        {
            #Write-Error "An error occured."
            CreateHttpResponse($response)
        }
        else
        {
            CreateEnvironmentObject -EnvObject $response -ReturnCdsDatabaseType $false
        }
    }
}

function Set-AdminPowerAppEnvironmentDisplayName
{
<#
 .SYNOPSIS
 Updates the Environment display name.
 .DESCRIPTION
 The Set-EnvironmentDisplayName cmdlet updates the display name field of the specified Environment. 
 Use Get-Help Set-EnvironmentDisplayName -Examples for more detail.
 .PARAMETER EnvironmentName
 Updates a specific environment.
 .PARAMETER NewDisplayName
 The new display name of the Environment.
 .EXAMPLE
 Set-EnvironmentDisplayName -EnvironmentName 8d996ece-8558-4c4e-b459-a51b3beafdb4 -NewDisplayName Applications
 Updates the display name of Environment '8d996ece-8558-4c4e-b459-a51b3beafdb4' to be called 'Applications'.
 .EXAMPLE
 Set-EnvironmentDisplayName -EnvironmentName 8d996ece-8558-4c4e-b459-a51b3beafdb4 -NewDisplayName 'Main Organization Apps'
 Updates the display name to be 'Main Organization Apps'
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$NewDisplayName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;
    
        $requestBody = @{
            properties = @{
                displayName = $NewDisplayName
            }
        }

        $response = InvokeApi -Method PATCH -Route $route -Body $requestBody

        CreateHttpResponse($response)
    }
}

function Get-AdminPowerAppEnvironmentLocations
{
    <#
    .SYNOPSIS
    Returns all supported environment locations.
    .DESCRIPTION
    The Get-AdminPowerAppEnvironmentLocations cmdlet returns all supported locations to create an environment in PowerApps.
    Use Get-Help Get-AdminPowerAppEnvironmentLocations -Examples for more detail.
    .PARAMETER Filter
    Finds locations matching the specified filter (wildcards supported).
    .EXAMPLE
    Get-AdminPowerAppEnvironmentLocations
    Returns all locations.
    .EXAMPLE
    Get-AdminPowerAppEnvironmentLocations *unitedstates*
    Returns the US location
    #>
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Filter,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    $getLocationsUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/locations?api-version={apiVersion}"
    
    $locationsResult = InvokeApi -Method GET -Route $getLocationsUri -ApiVersion $ApiVersion

    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($location in $locationsResult.Value)
    {
        if ($patternFilter.IsMatch($location.name) -or
            $patternFilter.IsMatch($location.properties.displayName))
        {
            CreateEnvironmentLocationObject -EnvironmentLocationObject $location
        }
    }
}


function Get-AdminPowerAppCdsDatabaseCurrencies
{
    <#
    .SYNOPSIS
    Returns all supported CDS database currencies.
    .DESCRIPTION
    The Get-AdminPowerAppCdsDatabaseCurrencies cmdlet returns all supported database currencies, which is required to provision a new instance.
    Use Get-Help Get-AdminPowerAppCdsDatabaseCurrencies -Examples for more detail.
    .PARAMETER Filter
    Finds currencies matching the specified filter (wildcards supported).
    .PARAMETER LocationName
    The location of the current environment. Use Get-AdminPowerAppEnvironmentLocations to see the valid locations.
    .EXAMPLE
    Get-AdminPowerAppCdsDatabaseCurrencies
    Returns all currencies.
    .EXAMPLE
    Get-AdminPowerAppCdsDatabaseCurrencies *USD*
    Returns the US dollar currency
    #>
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Filter,

        [Parameter(Mandatory = $true, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$LocationName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    $getCurrenciesUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/locations/{location}/environmentCurrencies?api-version={apiVersion}" `
    | ReplaceMacro -Macro "{location}" -Value $LocationName;
    
    $currenciesResult = InvokeApi -Method GET -Route $getCurrenciesUri -ApiVersion $ApiVersion

    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($currency in $currenciesResult.Value)
    {
        if ($patternFilter.IsMatch($currency.name) -or
            $patternFilter.IsMatch($currency.properties.code))
        {
            CreateCurrencyObject -CurrencyObject $currency
        }
    }
}


function Get-AdminPowerAppCdsDatabaseLanguages
{
    <#
    .SYNOPSIS
    Returns all supported CDS database languages.
    .DESCRIPTION
    The Get-AdminPowerAppCdsDatabaseLanguages cmdlet returns all supported database languages, which is required to provision a new instance.
    Use Get-Help Get-AdminPowerAppCdsDatabaseLanguages -Examples for more detail.
    .PARAMETER Filter
    Finds langauges matching the specified filter (wildcards supported).
    .PARAMETER LocationName
    The location of the current environment. Use Get-AdminPowerAppEnvironmentLocations to see the valid locations.
    .EXAMPLE
    Get-AdminPowerAppCdsDatabaseLanguages
    Returns all languages.
    .EXAMPLE
    Get-AdminPowerAppCdsDatabaseLanguages *English*
    Returns all English language options
    #>
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]$Filter,

        [Parameter(Mandatory = $true, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$LocationName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    $getLanguagesUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/locations/{location}/environmentLanguages?api-version={apiVersion}" `
    | ReplaceMacro -Macro "{location}" -Value $LocationName;
    
    $languagesResult = InvokeApi -Method GET -Route $getLanguagesUri -ApiVersion $ApiVersion

    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($languages in $languagesResult.Value)
    {
        if ($patternFilter.IsMatch($languages.name) -or
            $patternFilter.IsMatch($languages.properties.displayName) -or
            $patternFilter.IsMatch($languages.properties.localizedName))
        {
            CreateLanguageObject -LanguageObject $languages
        }
    }
}

function New-AdminPowerAppCdsDatabase
{
    <#
    .SYNOPSIS
    Creates a Common Data Service For Apps database for the specified environment.
    .DESCRIPTION
    The New-AdminPowerAppCdsDatabase cmdlet creates a Common Data Service For Apps database for the specified environment with teh specified default language and currency.
    Use Get-Help New-AdminPowerAppCdsDatabase -Examples for more detail.
    .PARAMETER EnvironmentName
    The environment name
    .PARAMETER CurrencyName
    The default currency for the database, use Get-AdminPowerAppCdsDatabaseCurrencies to get the supported values
    .PARAMETER LanguageName
    The default languages for the database, use Get-AdminPowerAppCdsDatabaseLanguages to get the support values
    .PARAMETER WaitUntilFinished
    Default is true.  If set to true, then the function will not return a value until provisioning the database is complete (as either a success or failure)
    .EXAMPLE
    New-AdminPowerAppCdsDatabase -EnvironmentName 8d996ece-8558-4c4e-b459-a51b3beafdb4 -CurrencyName USD -LanguageName 1033
    Creates a database with the US dollar currency and Environment (US) language
    #>
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$CurrencyName,
    
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$LanguageName,

        [Parameter(Mandatory = $false)]
        [bool]$WaitUntilFinished = $true,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ApiVersion = "2018-01-01"
    )
    process
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/environments/{environmentName}/provisionInstance`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;
    
        $requestBody = @{
            baseLanguage = $LanguageName
            currency = @{
                code = $CurrencyName
            }
        }

        # By default we poll until the CDS database is finished provisioning
        If($WaitUntilFinished)
        {
            $response = InvokeApiNoParseContent -Method POST -Route $route -Body $requestBody -ApiVersion $ApiVersion
            $statusUrl = $response.Headers['Location']

            if ($response.StatusCode -eq "BadRequest")
            {
                #Write-Error "An error occured."
                CreateHttpResponse($response)
            }
            else
            {
                $currentTime = Get-Date -format HH:mm:ss
                $nextTime = Get-Date -format HH:mm:ss
                $TimeDiff = New-TimeSpan $currentTime $nextTime
                $timeoutInSeconds = 300
        
                #Wait until the environment has been deleted, there is an error, or we hit a timeout
                while(($response.StatusCode -ne 200) -and ($response.StatusCode -ne 404) -and ($response.StatusCode -ne 500) -and ($TimeDiff.TotalSeconds -lt $timeoutInSeconds))
                {
                    Start-Sleep -s 5
                    $response = InvokeApiNoParseContent -Route $statusUrl -Method GET -ApiVersion $ApiVersion
                    $nextTime = Get-Date -format HH:mm:ss
                    $TimeDiff = New-TimeSpan $currentTime $nextTime
                }
    
                $parsedResponse = ConvertFrom-Json $response.Content
                CreateEnvironmentObject -EnvObject $parsedResponse
            }
        }
        # optionally the caller can choose to NOT wait until provisioning is complete and get the provisioning status by polling on Get-AdminPowerAppEnvironment and looking at the provisioning status field
        else
        {
            $response = InvokeApi -Method POST -Route $route -Body $requestBody -ApiVersion $ApiVersion

            if ($response.StatusCode -eq "BadRequest")
            {
                #Write-Error "An error occured."
                CreateHttpResponse($response)
            }
            else
            {
                CreateEnvironmentObject -EnvObject $response
            }
        }
    }
}

function Get-AdminPowerAppEnvironment
{
 <#
 .SYNOPSIS
 Returns information about one or more PowerApps environments where the calling uses is an Environment Admin. If the calling user is a tenant admin, all envionments within the tenant will be returned.
 .DESCRIPTION
 The Get-AdminPowerAppEnvironment cmdlet looks up information about =one or more environments depending on parameters. 
 Use Get-Help Get-AdminPowerAppEnvironment -Examples for more detail.
 .PARAMETER Filter
 Finds environments matching the specified filter (wildcards supported).
 .PARAMETER EnvironmentName
 Finds a specific environment.
 .PARAMETER Default
 Finds the default environment.
 .PARAMETER CreatedBy
 Limit environments returned to only those created by the specified user (you can specify a email address or object id)
 .EXAMPLE
 Get-AdminPowerAppEnvironment
 Finds all environments within the tenant where the user is an Environment Admin.
 .EXAMPLE
 Get-AdminPowerAppEnvironment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 .EXAMPLE
 Get-AdminPowerAppEnvironment *Test*
 Finds all environments that contain the string "Test" in their display name where the user is an Environment Admin.
 .EXAMPLE
 Get-AdminPowerAppEnvironment -CreatedBy 7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Finds all environments that were created by the user with an object of 7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "User")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Default")]
        [Switch]$Default,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$CreatedBy,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [bool]$ReturnCdsDatabaseType = $true
    )
    process
    {
        if ($Default)
        {
            $getEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/~default?`$expand=permissions&api-version={apiVersion}"
        
            $environmentResult = InvokeApi -Method GET -Route $getEnvironmentUri -ApiVersion $ApiVersion
        
            CreateEnvironmentObject -EnvObject $environmentResult -ReturnCdsDatabaseType $ReturnCdsDatabaseType
        }
        elseif (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $getEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}?`$expand=permissions&api-version={apiVersion}" `
                | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;
        
            $environmentResult = InvokeApi -Method GET -Route $getEnvironmentUri -ApiVersion $ApiVersion
        
            CreateEnvironmentObject -EnvObject $environmentResult -ReturnCdsDatabaseType $ReturnCdsDatabaseType
        }
        else
        {
            $getAllEnvironmentsUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?`$expand=permissions&api-version={apiVersion}"
        
            $environmentsResult = InvokeApi -Method GET -Route $getAllEnvironmentsUri -ApiVersion $ApiVersion
        
            Get-FilteredEnvironments -Filter $Filter -CreatedBy $CreatedBy -EnvironmentResult $environmentsResult -ReturnCdsDatabaseType $ReturnCdsDatabaseType
        }
    }
}

function Remove-AdminPowerAppEnvironment
{
    <#
    .SYNOPSIS
    Deletes the specific environment.  This operation can take some time depending on how many resources are stored in the environment. If the operation returns witha  404 NotFound, then the environment has been successfully deleted.
    .DESCRIPTION
    Remove-AdminPowerAppEnvironment cmdlet deletes an environment. 
    Use Get-Help Remove-AdminPowerAppEnvironment -Examples for more detail.
    .PARAMETER Filter
    Finds environments matching the specified filter (wildcards supported).
    .EXAMPLE
    Remove-AdminPowerAppEnvironment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Deletes environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 and all of the environment's resources
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,


        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2018-01-01"
    )

    process
    {    
        $validateEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}/validateDelete`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;

        $validateResponse = InvokeApi -Method POST -Route $validateEnvironmentUri -ApiVersion $ApiVersion

        if (-not $validateResponse.canInitiateDelete)
        {
            #Write-Host "Unable to delete this environment."
            CreateHttpResponse($validateResponse)
        }
        else {

            $deleteEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}`?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{environmentName}" -Value $EnvironmentName;

            $resources = $validateResponse.Content.resourcesToBeDeleted | Group type
            #Write-Host "Deleting..."
            foreach ($type in $resources)
            {
                #Write-Host $type.Name: $type.Count
            }

            #Kick-off delete
            $deleteEnvironmentResponse = InvokeApiNoParseContent -Route $deleteEnvironmentUri -Method DELETE -ThrowOnFailure -ApiVersion $ApiVersion
            $deleteStatusUrl = $deleteEnvironmentResponse.Headers['Location']

            #If there is no status Url then the environment likely does not exist
            if(!$deleteStatusUrl)
            {
                CreateHttpResponse($deleteEnvironmentResponse)     
            }
            else 
            {
                # Don't poll on delete

                # $currentTime = Get-Date -format HH:mm:ss
                # $nextTime = Get-Date -format HH:mm:ss
                # $TimeDiff = New-TimeSpan $currentTime $nextTime
                # $timeoutInSeconds = 300
        
                # #Wait until the environment has been deleted, there is an error, or we hit a timeout
                # while($deleteEnvironmentResponse.StatusCode -ne 404 -and $deleteEnvironmentResponse.StatusCode -ne 500 -and ($TimeDiff.Seconds -lt 300))
                # {
                #     Start-Sleep -s 5
                #     $deleteEnvironmentResponse = InvokeApiNoParseContent -Route $deleteStatusUrl -Method GET -ApiVersion $ApiVersion
                #     $nextTime = Get-Date -format HH:mm:ss
                #     $TimeDiff = New-TimeSpan $currentTime $nextTime
                # }
                
                CreateHttpResponse($deleteEnvironmentResponse)   
            }
        }
    }
}

function Get-AdminPowerAppEnvironmentRoleAssignment
{
    <#
    .SYNOPSIS
    Returns the environment role assignments for environments without a Common Data Service For Apps database instance.
    .DESCRIPTION
    The Get-AdminPowerAppEnvironmentRoleAssignment returns environment role assignments for environments with a Common Data Service For Apps database instance.  This includes which users are assigned as an Environment Admin or Environment Maker in each environment.
    Use Get-Help Get-AdminPowerAppEnvironmentRoleAssignment -Examples for more detail.
    .PARAMETER EnvironmentName
    Limit roles returned to those in a specified environment.
    .PARAMETER UserId
    A objectId of the user you want to filter by.
    .EXAMPLE
    Get-AdminPowerAppEnvironmentRoleAssignment
    Returns all environment role assignments across all environments. where the calling users is an Environment Admin.
    .EXAMPLE
    Get-AdminPowerAppEnvironmentRoleAssignment -UserId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all environment role assignments across all environments (where the calling users is an Environment Admin) for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-AdminPowerAppEnvironmentRoleAssignment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -UserId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all environment role assignments for the environment  3c2f7648-ad60-4871-91cb-b77d7ef3c239  for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-AdminPowerAppEnvironmentRoleAssignment  -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Returns all environment role assignments for the environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "Environment", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Environment")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$UserId,

        [Parameter(Mandatory = $false, ParameterSetName = "Environment")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {    

        $environments = @();

        if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
        {
            $environments += @{
                EnvironmentName = $EnvironmentName
            }
        }
        else {
            $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false
        }

        foreach($environment in $environments)
        {                 
            $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}/roleAssignments?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{environmentName}" -Value $environment.EnvironmentName;
            
            $envRoleAssignmentResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            #Write-Host $envRoleAssignmentResult.StatusCode #Returns 'Forbidden' for CDS 2.0 orgs

            $pattern = BuildFilterPattern -Filter $UserId

            foreach ($envRole in $envRoleAssignmentResult.Value)
            {
                if ($pattern.IsMatch($envRole.properties.principal.id ) -or
                    $pattern.IsMatch($envRole.properties.principal.email))
                {
                    CreateEnvRoleAssignmentObject -EnvRoleAssignmentObj $envRole -EnvObj $environment
                }
            }
        }
    }
}

function Set-AdminPowerAppEnvironmentRoleAssignment
{
<#
 .SYNOPSIS
 Sets permissions to an environment without a Common Data Service For Apps database instance. If you make this call to an environment with a Common Data Service for Apps database instance you will get a 403 Forbidden error.
 .DESCRIPTION
 The Set-AdminPowerAppEnvironmentRoleAssignment set up permission to environment depending on parameters. 
 Use Get-Help Set-AdminPowerAppEnvironmentRoleAssignment -Examples for more detail.
 .PARAMETER EnvironmentName
 The environmnet id.
 .PARAMETER RoleName
 Specifies the permission level given to the environment: Environment Admin or Environment Maker.
 .PARAMETER PrincipalType
 Specifies the type of principal this environment is being shared with; a user, a security group, the entire tenant.
 .PARAMETER PrincipalObjectId
 If this environment is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
 .EXAMPLE
 Set-AdminPowerAppEnvironmentRoleAssignment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -RoleName EnvironmentAdmin -PrincipalType User -PrincipalObjectId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 Assigns the Environment Admin role privileges to the the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3 in the environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239  
 .EXAMPLE
 Set-AdminPowerAppEnvironmentRoleAssignment -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -RoleName EnvironmentMaker -PrincipalType Tenant
 Assigns everyone Environment Maker role privileges in the environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239  
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("EnvironmentAdmin", "EnvironmentMaker")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2016-11-01"
    )
        
    process 
    {
        $TenantId = $Global:currentSession.tenantId

        if($PrincipalType -ne "Tenant") 
        {
            $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
            $PrincipalEmail = $userOrGroup.Mail
        }

        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environment}/modifyRoleAssignments`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body 
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{ 
                add = @(
                    @{ 
                        properties = @{
                            roleDefinition = @{
                                id = "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/$EnvironmentName/roleDefinitions/$RoleName"
                            }      
                            principal = @{
                                email = ""
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = $TenantId
                            }          
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{ 
                add = @(
                    @{ 
                        properties = @{
                            roleDefinition = @{
                                id = "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/$EnvironmentName/roleDefinitions/$RoleName"
                            }      
                            principal = @{
                                email = $PrincipalEmail
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = "null"
                            }          
                        }
                    }
                )
            }
        }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Remove-AdminPowerAppEnvironmentRoleAssignment
{
<#
 .SYNOPSIS
 Deletes specific role assignment of an environment.
 .DESCRIPTION
 Deletes specific role assignment of an environment.
 Use Get-Help Remove-AdminPowerAppEnvironmentRoleAssignment -Examples for more detail.
 .PARAMETER EnvironmentName
 The environment id
 .PARAMETER RoleId
 Specifies the role assignment id.
 .EXAMPLE
 Remove-AdminPowerAppEnvironmentRoleAssignment -RoleId "4d1f7648-ad60-4871-91cb-b77d7ef3c239" -EnvironmentName "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877"
 Deletes the role named 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in Environment Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
 #>
    [CmdletBinding(DefaultParameterSetName="App")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environment}/modifyRoleAssignments`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            #Construct the body 
        $requestbody = $null
        
        $requestbody = @{ 
            remove = @(
                @{ 
                    id = $RoleId
                }
            )
        }


        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Get-AdminPowerAppConnection
{
 <#
 .SYNOPSIS
 Returns information about one or more connection.
 .DESCRIPTION
 The Get-AdminPowerAppConnection looks up information about one or more connections depending on parameters. 
 Use Get-Help Get-AdminPowerAppConnection -Examples for more detail.
 .PARAMETER Filter
 Finds connection matching the specified filter (wildcards supported).
 .PARAMETER ConnectorName
 Limit connections returned to those of a specified connector.
 .PARAMETER EnvironmentName
 Limit connections returned to those in a specified environment.
 .PARAMETER CreatedBy
 Limit connections returned to those created by by the specified user (email or AAD object id)
 .EXAMPLE
 Get-AdminPowerAppConnection
 Returns all connection from all environments where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminPowerAppConnection *PowerApps*
 Returns all connection with the text "PowerApps" in the display namefrom all environments where the calling user is an Environment Admin  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminPowerAppConnection -CreatedBy foo@bar.onmicrosoft.com
 Returns all apps created by the user with an email of "foo@bar.onmicrosoft.com" from all environment where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminPowerAppConnection -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds connections within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
  .EXAMPLE
 Get-AdminPowerAppConnection -ConnectorName shared_runtimeservice
 Finds all connections created against the shared_runtimeservice (CDS) connector from all environments where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminPowerAppConnection -ConnectorName shared_runtimeservice -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds connections within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment that are created against the shared_runtimeservice (CDS) connector.
 .EXAMPLE
 Get-AdminPowerAppConnection *Foobar* -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 
 Finds all connections in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 that contain the string "Foobar" in their display name.
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "User")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Connector", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$CreatedBy,

        [Parameter(Mandatory = $false, ParameterSetName = "Connector")]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        # If the connector name is specified, only return connections for that connector
        if (-not [string]::IsNullOrWhiteSpace($ConnectorName))
        {
            $environments = @();
 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $environments += @{
                    EnvironmentName = $EnvironmentName
                }
            }
            else 
            {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false
            }

            foreach($environment in $environments)
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connectorName}/connections?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{connectorName}" -Value $ConnectorName `
                | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

                $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                Get-FilteredConnections -Filter $Filter -CreatedBy $CreatedBy -ConnectionResult $connectionResult
            }
        }
        else
        {
            # If the caller passed in an environment scope, filter the query to only that environment 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/connections?api-version={apiVersion}" `
                | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;    

                $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                Get-FilteredConnections -Filter $Filter -CreatedBy $CreatedBy -ConnectionResult $connectionResult
            }
            # otherwise search for the apps acroos all environments for this calling user
            else 
            {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false

                foreach($environment in $environments)
                {
                    $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/connections?api-version={apiVersion}" `
                    | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;    
    
                    $connectionResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion
    
                    Get-FilteredConnections -Filter $Filter -CreatedBy $CreatedBy -ConnectionResult $connectionResult                 
                }
            }
        }
    }
}


function Remove-AdminPowerAppConnection
{
 <#
 .SYNOPSIS
 Deletes the connection.
 .DESCRIPTION
 The Remove-AdminPowerAppConnection permanently deletes the connection. 
 Use Get-Help Remove-AdminPowerAppConnection -Examples for more detail.
 .PARAMETER ConnectionName
 The connection identifier.
 .PARAMETER ConnectorName
 The connection's connector name.
 .PARAMETER EnvironmentName
 The connection's environment.
 .EXAMPLE
 Remove-AdminPowerAppConnection -ConnectionName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -ConnectorName shared_twitter -EnvironmentName Default-efecdc9a-c859-42fd-b215-dc9c314594dd
 Deletes the connection with name 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ConnectionName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/connections/{connection}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        $removeResult = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        If($removeResult -eq $null)
        {
            return $null
        }
        
        CreateHttpResponse($removeResult)
    }
}

function Get-AdminPowerAppConnectionRoleAssignment
{
 <#
 .SYNOPSIS
 Returns the connection role assignments for a user or a connection. Owner role assignments cannot be deleted without deleting the connection resource.
 .DESCRIPTION
 The Get-AdminPowerAppConnectionRoleAssignment functions returns all roles assignments for an connection or all connection roles assignments for a user (across all of their connections).  A connection's role assignments determine which users have access to the connection for using or building apps and flows and with which permission level (CanUse, CanUseAndShare) . 
 Use Get-Help Get-AdminPowerAppConnectionRoleAssignment -Examples for more detail.
 .PARAMETER ConnectionName
 The connection identifier.
 .PARAMETER EnvironmentName
 The connections's environment. 
 .PARAMETER ConnectorName
 The connection's connector identifier.
 .PARAMETER PrincipalObjectId
 The objectId of a user or group, if specified, this function will only return role assignments for that user or group.
 .EXAMPLE
 Get-AdminPowerAppConnectionRoleAssignment
 Returns all connection role assignments for the calling user.
 .EXAMPLE
 Get-AdminPowerAppConnectionRoleAssignment -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c
 Returns all role assignments for the connection with name 3b4b9592607147258a4f2fb33517e97ain environment with name ee1eef10-ba55-440b-a009-ce379f86e20c for the connector named shared_sharepointonline
 .EXAMPLE
 Get-AdminPowerAppConnectionRoleAssignment -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_sharepointonline -EnvironmentName ee1eef10-ba55-440b-a009-ce379f86e20c -PrincipalObjectId 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all role assignments for the user, or group with an object of 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the connection with name 3b4b9592607147258a4f2fb33517e97ain environment with name ee1eef10-ba55-440b-a009-ce379f86e20c for the connector named shared_sharepointonline
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$PrincipalObjectId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $selectedObjectId = $null

        if (-not [string]::IsNullOrWhiteSpace($ConnectionName))
        {
            if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
            {
                $selectedObjectId = $PrincipalObjectId;
            }
        }

        $pattern = BuildFilterPattern -Filter $selectedObjectId

        if (-not [string]::IsNullOrWhiteSpace($ConnectionName))
        {

            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/connections/{connection}/permissions?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
            | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $connectionRoleResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            foreach ($connectionRole in $connectionRoleResult.Value)
            {
                if (-not [string]::IsNullOrWhiteSpace($PrincipalObjectId))
                {
                    if ($pattern.IsMatch($connectionRole.properties.principal.id ) -or
                        $pattern.IsMatch($connectionRole.properties.principal.email) -or 
                        $pattern.IsMatch($connectionRole.properties.principal.tenantId))
                    {
                        CreateConnectionRoleAssignmentObject -ConnectionRoleAssignmentObj $connectionRole -EnvironmentName $EnvironmentName
                    }
                }
                else 
                {    
                    CreateConnectionRoleAssignmentObject -ConnectionRoleAssignmentObj $connectionRole -EnvironmentName $EnvironmentName
                }
            }
        }
        else 
        {
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $connections = Get-AdminPowerAppConnection -EnvironmentName $EnvironmentName -ConnectorName $ConnectorName -ApiVersion $ApiVersion
            }
            else 
            {
                $connections = Get-AdminPowerAppConnection -ApiVersion $ApiVersion           
            }

            foreach($connection in $connections)
            {
                Get-AdminPowerAppConnectionRoleAssignment `
                    -ConnectionName $connection.ConnectionName `
                    -ConnectorName $connection.ConnectorName `
                    -EnvironmentName $connection.EnvironmentName `
                    -PrincipalObjectId $selectedObjectId `
                    -ApiVersion $ApiVersion
            }
        }
    }
}

function Set-AdminPowerAppConnectionRoleAssignment
{
    <#
    .SYNOPSIS
    Sets permissions to the connection.
    .DESCRIPTION
    The Set-AdminPowerAppConnectionRoleAssignment set up permission to connection depending on parameters. 
    Use Get-Help Set-AdminPowerAppConnectionRoleAssignment -Examples for more detail.
    .PARAMETER ConnectionName
    The connection identifier.
    .PARAMETER EnvironmentName
    The connections's environment. 
    .PARAMETER ConnectorName
    The connection's connector identifier.
    .PARAMETER RoleName
    Specifies the permission level given to the connection: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
    .PARAMETER PrincipalType
    Specifies the type of principal this connection is being shared with; a user, a security group, the entire tenant.
    .PARAMETER PrincipalObjectId
    If this connection is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
    .EXAMPLE
    Set-AdminPowerAppConnectionRoleAssignment -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -ConnectionName 3b4b9592607147258a4f2fb33517e97a -ConnectorName shared_vsts -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
    Give the specified security group CanEdit permissions to the connection with name 3b4b9592607147258a4f2fb33517e97a
    #> 
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $TenantId = $Global:currentSession.tenantId

        # if($PrincipalType -ne "Tenant") 
        # {
        #     $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
        #     $PrincipalEmail = $userOrGroup.Mail
        # }

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/connections/{connection}/modifyPermissions?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body 
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{ 
                delete = @()
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            principal = @{
                                id = $TenantId
                                tenantId = $TenantId
                            }          
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{ 
                delete = @()
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            principal = @{
                                id = $PrincipalObjectId
                            }               
                        }
                    }
                )
            }
        }
        
        $setConnectionRoleResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($setConnectionRoleResult)
    }
}

function Remove-AdminPowerAppConnectionRoleAssignment
{
 <#
 .SYNOPSIS
 Deletes a connection role assignment record.
 .DESCRIPTION
 The Remove-AdminPowerAppConnectionRoleAssignment deletes the specific connection role assignment
 Use Get-Help Remove-AdminPowerAppConnectionRoleAssignment -Examples for more detail.
 .PARAMETER RoleId
 The id of the role assignment to be deleted.
 .PARAMETER ConnectionName
 The app identifier.
 .PARAMETER ConnectorName
 The connection's associated connector name
 .PARAMETER EnvironmentName
 The connection's environment. 
 .EXAMPLE
 Remove-AdminPowerAppConnectionRoleAssignment -ConnectionName a2956cf95ba441119d16dc2ef0ca1ff9 -EnvironmentName 08b4e32a-4e0d-4a69-97da-e1640f0eb7b9 -ConnectorName shared_twitter -RoleId /providers/Microsoft.PowerApps/apis/shared_twitter/connections/a2956cf95ba441119d16dc2ef0ca1ff9/permissions/7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Deletes the app role assignment with an id of /providers/Microsoft.PowerApps/apps/f8d7a19d-f8f9-4e10-8e62-eb8c518a2eb4/permissions/tenant-efecdc9a-c859-42fd-b215-dc9c314594dd
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectionName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$ConnectorName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2017-06-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apis/{connector}/connections/{connection}/modifyPermissions`?api-version={apiVersion" `
        | ReplaceMacro -Macro "{connector}" -Value $ConnectorName `
        | ReplaceMacro -Macro "{connection}" -Value $ConnectionName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body 
        $requestbody = $null
        
        $requestbody = @{ 
            delete = @(
                @{ 
                    id = $RoleId
                }
            )
        }
    
        $removeResult = InvokeApi -Method POST -Body $requestbody -Route $route -ApiVersion $ApiVersion

        If($removeResult -eq $null)
        {
            return $null
        }
        
        CreateHttpResponse($removeResult)
    }
}


function Get-AdminPowerApp
{
 <#
 .SYNOPSIS
 Returns information about one or more apps.
 .DESCRIPTION
 The Get-AdminPowerApp looks up information about one or more apps depending on parameters. 
 Use Get-Help Get-AdminPowerApp -Examples for more detail.
 .PARAMETER Filter
 Finds apps matching the specified filter (wildcards supported).
 .PARAMETER AppName
 Finds a specific id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 .PARAMETER Owner
 Limit apps returned to those owned by the specified user (you can specify a email address or object id)
 .EXAMPLE
 Get-AdminPowerApp 
 Returns all apps from all environments where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminPowerApp *PowerApps*
 Returns all apps with the text "PowerApps" from all environments where the calling user is an Environment Admin  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminPowerApp -CreatedBy foo@bar.onmicrosoft.com
 Returns all apps created by the user with an email of "foo@bar.onmicrosoft.com" from all environment where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
  .EXAMPLE
 Get-AdminPowerApp -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds apps within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-AdminPowerApp *Foobar* -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 
 Finds all app in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 that contain the string "Foobar" in their display name.
 .EXAMPLE
 Get-AdminPowerApp -AppName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns the details for the app named 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in Environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "User")]
        [string[]]$Filter,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$Owner,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        # If the app name is specified, just return the details for that app
        if (-not [string]::IsNullOrWhiteSpace($AppName))
        {
            $top = 250
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}?api-version={apiVersion}&top={top}&`$expand=unpublishedAppDefinition" `
            | ReplaceMacro -Macro "{appName}" -Value $AppName `
            | ReplaceMacro -Macro "{top}" -Value $top `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $appResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            CreateAppObject -AppObj $appResult;
        }
        else
        {
            $userId = $Global:currentSession.userId
            $expandPermissions = "permissions(`$filter=maxAssignedTo(`'$userId`'))"

            # If the caller passed in an environment scope, filter the query to only that environment 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $top = 250
                
                $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps?api-version={apiVersion}&`$expand={expandPermissions}" `
                | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions `
                | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

                $appResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                Get-FilteredApps -Filter $Filter -Owner $Owner -AppResult $appResult
            }
            # otherwise search for the apps across all environments for this calling user
            else 
            {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false

                foreach($environment in $environments)
                {
                    $top = 250
                
                    $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps?api-version={apiVersion}&`$expand={expandPermissions}" `
                    | ReplaceMacro -Macro "{expandPermissions}" -Value $expandPermissions `
                    | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

                    $appResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                    Get-FilteredApps -Filter $Filter -Owner $Owner -AppResult $appResult                    
                }
            }
        }
    }
}

function Remove-AdminPowerApp
{
<#
 .SYNOPSIS
 Deletes an app.
 .DESCRIPTION
 The Delete-AdminPowerApp deletes an app. 
 Use Delete-Help Get-AdminPowerApp -Examples for more detail.
 .PARAMETER AppName
 Specifies the app id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 Delete-AdminPowerApp -AppName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Deletes the app named 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in Environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="App")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $result = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }            
}

function Get-AdminPowerAppRoleAssignment
{
<#
 .SYNOPSIS
 Returns permission information about one or more apps.
 .DESCRIPTION
 The Get-AdminPowerAppRoleAssignment returns permission information about one or more apps.
 Use Get-Help Get-AdminPowerAppRoleAssignment -Examples for more detail.
 .PARAMETER AppName
 Finds a specific id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 .PARAMETER UserId
 A objectId of the user you want to filter by.
 .EXAMPLE
 Get-AdminPowerAppRoleAssignments -UserId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 Returns all app role assignments across all environments for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 .EXAMPLE
 Get-AdminPowerAppRoleAssignments -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -UserId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 Returns all app role assignemtns within environment with id 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 .EXAMPLE
 Get-AdminPowerAppRoleAssignments -AppName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -UserId 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 Returns all role assignments for the app with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
 .EXAMPLE
 Get-AdminPowerAppRoleAssignments -AppName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns all role assignments for the app with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Environment", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [Parameter(Mandatory = $true, ParameterSetName = "Environment")]
        [string]$UserId,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Environment")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        if (-not [string]::IsNullOrWhiteSpace($AppName))
        {
            $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}/permissions?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
            | ReplaceMacro -Macro "{appName}" -Value $AppName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $appRoleAssignmentResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            $pattern = BuildFilterPattern -Filter $UserId

            foreach ($appRole in $appRoleAssignmentResult.Value)
            {
                if ($pattern.IsMatch($appRole.properties.principal.id ) -or
                    $pattern.IsMatch($appRole.properties.principal.email))
                {
                    CreateAppRoleAssignmentObject -AppRoleAssignmentObj $appRole
                }
            }
        }
        else
        {
            $environments = @();
 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $environments += @{
                    EnvironmentName = $EnvironmentName
                }
            }
            else {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false
            }

            foreach($environment in $environments)
            {                        
                $appResult = Get-AdminPowerApp -EnvironmentName $environment.EnvironmentName
    
                foreach ($app in $appResult)
                {
                    $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}/permissions?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
                    | ReplaceMacro -Macro "{appName}" -Value $app.AppName `
                    | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;
                    
                    $appRoleAssignmentResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                    $pattern = BuildFilterPattern -Filter $UserId

                    foreach ($appRole in $appRoleAssignmentResult.Value)
                    {
                        if ($pattern.IsMatch($appRole.properties.principal.id ) -or
                            $pattern.IsMatch($appRole.properties.principal.email))
                        {
                            CreateAppRoleAssignmentObject -AppRoleAssignmentObj $appRole
                        }
                    }
                }
            }
        }
    }
}

function Remove-AdminPowerAppRoleAssignment
{
<#
 .SYNOPSIS
 Deletes specific role of an app.
 .DESCRIPTION
 Deletes specific role of an app.
 Use Get-Help Remove-AdminPowerAppRoleAssignment -Examples for more detail.
 .PARAMETER AppName
 Specifies the app id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 .PARAMETER RoleId
 Specifies the role assignment id.
 Remove-AdminPowerAppRoleAssignment -RoleId "4d1f7648-ad60-4871-91cb-b77d7ef3c239" -EnvironmentName "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877" -AppName "73691d1f-0ff5-442c-87ce-1e3e2fba58dc"
 Deletes the role named 4d1f7648-ad60-4871-91cb-b77d7ef3c239 for app id 73691d1f-0ff5-442c-87ce-1e3e2fba58dc in Environment Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
 #>
    [CmdletBinding(DefaultParameterSetName="App")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}/modifyPermissions?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

            #Construct the body 
        $requestbody = $null
    
        $requestbody = @{ 
            delete = @(
                @{ 
                    id = $RoleId
                 }
             )
             }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Set-AdminPowerAppRoleAssignment
{
<#
 .SYNOPSIS
 sets permissions to the app.
 .DESCRIPTION
 The Set-AdminPowerAppRoleAssignment set up permission to app depending on parameters. 
 Use Get-Help Set-AdminPowerAppRoleAssignment -Examples for more detail.
 .PARAMETER AppName
 App name for the one which you want to set permission.
 .PARAMETER EnvironmentName
 Limit app returned to those in a specified environment.
 .PARAMETER RoleName
 Specifies the permission level given to the app: CanView, CanViewWithShare, CanEdit. Sharing with the entire tenant is only supported for CanView.
 .PARAMETER PrincipalType
 Specifies the type of principal this app is being shared with; a user, a security group, the entire tenant.
 .PARAMETER PrincipalObjectId
 If this app is being shared with a user or security group principal, this field specified the ObjectId for that principal. You can use the Get-UsersOrGroupsFromGraph API to look-up the ObjectId for a user or group in Azure Active Directory.
 .EXAMPLE
 Set-AdminPowerAppRoleAssignment -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -AppName 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
 Give the specified security group CanEdit permissions to the app with name 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 
 #> 
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [ValidateSet("CanView", "CanViewWithShare", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [ValidateSet("User", "Group", "Tenant")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Tenant")]
        [string]$ApiVersion = "2016-11-01"
    )
        
    process 
    {
        $TenantId = $Global:currentSession.tenantId

        if($PrincipalType -ne "Tenant") 
        {
            $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
            $PrincipalEmail = $userOrGroup.Mail
        }

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}/modifyPermissions`?api-version={apiVersion}&`$filter=environment%20eq%20'{environment}'" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        #Construct the body 
        $requestbody = $null

        If ($PrincipalType -eq "Tenant")
        {
            $requestbody = @{ 
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = ""
                                id = "null"
                                type = $PrincipalType
                                tenantId = $TenantId
                            }          
                        }
                    }
                )
            }
        }
        else
        {
            $requestbody = @{ 
                put = @(
                    @{ 
                        properties = @{
                            roleName = $RoleName
                            capabilities = @()
                            NotifyShareTargetOption = "Notify"
                            principal = @{
                                email = $PrincipalEmail
                                id = $PrincipalObjectId
                                type = $PrincipalType
                                tenantId = "null"
                            }               
                        }
                    }
                )
            }
        }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Set-AdminPowerAppOwner
{
<#
 .SYNOPSIS
 Sets the app owner and changes the current owner to "Can View" role type.
 .DESCRIPTION
 The Set-AppOwner Sets the app owner and changes the current owner to "Can View" role type. 
 Use Get-Help Set-AppOwner -Examples for more detail.
 .PARAMETER AppName
 App name for the one which you want to set permission.
 .PARAMETER EnvironmentName
 Limit app returned to those in a specified environment.
 .PARAMETER AppOwner
 Id of new owner which you want to set.
 .EXAMPLE
 Set-AppOwner -AppName "73691d1f-0ff5-442c-87ce-1e3e2fba58dc" -EnvironmentName "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877" -AppOwner "1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488"
 Sets the app owner to "1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488" and changes the current owner to "Can View" role type.
 #>
    [CmdletBinding(DefaultParameterSetName="App")]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App")]
        [string]$AppOwner
    )
        
    process 
    {

        $route = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/scopes/admin/environments/{environment}/apps/{appName}/modifyAppOwner?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{appName}" -Value $AppName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        #Construct the body 
        $requestbody = $null

        $requestbody =
                @{ 
                    newAppOwner = $AppOwner
                    roleForOldAppOwner = "CanView"
                    }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)

    }
}

function Get-AdminFlow
{
<#
 .SYNOPSIS
 Returns information about one or more flows.
 .DESCRIPTION
 The Get-AdminFlow looks up information about one or more flows depending on parameters. 
 Use Get-Help Get-AdminFlow -Examples for more detail.
 .PARAMETER Filter
 Finds flows matching the specified filter (wildcards supported).
 .PARAMETER FlowName
 Finds a specific id.
 .PARAMETER EnvironmentName
 Limit flows returned to those in a specified environment.
 .PARAMETER CreatedBy
 Limit flows returned to those created by the specified user (you must specify a user's object id)
  .EXAMPLE
 Get-AdminFlow 
 Returns all flow from all environments where the current user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminFlow -CreatedBy dbfad833-1e1e-4665-a20c-96391a1a39f0
 Returns all apps created by the user with an object of "dbfad833-1e1e-4665-a20c-96391a1a39f0" from all environment where the calling user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminFlow *Flows*
 Returns all flows with the text "Flows" from all environments where the current user is an Environment Admin.  For Global admins, this will search across all environments in the tenant.
 .EXAMPLE
 Get-AdminFlow -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds flows within the 3c2f7648-ad60-4871-91cb-b77d7ef3c239 environment
 .EXAMPLE
 Get-AdminFlow *Foobar* -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 
 Finds all flows in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 that contain the string "Foobar" in their display name.
 .EXAMPLE
 Get-AdminFlow -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Returns the details for the flow named 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in Environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 #>
    [CmdletBinding(DefaultParameterSetName="Filter")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter")]
        [string[]]$Filter,

        [Parameter(Mandatory = $false, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "App", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$CreatedBy,

        [Parameter(Mandatory = $false, ParameterSetName = "App")]
        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )

    process 
    {
        if (-not [string]::IsNullOrWhiteSpace($FlowName))
        {
            $top = 50
            $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

            $flowResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            CreateFlowObject -FlowObj $flowResult;
        }
        else
        {
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $top = 50
                
                $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows?api-version={apiVersion}&`top={top}" `
                | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName `
                | ReplaceMacro -Macro "{top}" -Value $top;

                $flowResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                Get-FilteredFlows -Filter $Filter -CreatedBy $CreatedBy -FlowResult $flowResult
            }
            else {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false

                foreach($environment in $environments)
                {
                    $top = 50
                
                    $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows?api-version={apiVersion}&`top={top}" `
                    | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName `
                    | ReplaceMacro -Macro "{top}" -Value $top;

                    $flowResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                    Get-FilteredFlows -Filter $Filter -CreatedBy $CreatedBy -FlowResult $flowResult
                }
            }
        }
    }
}


function Enable-AdminFlow 
{
<#
 .SYNOPSIS
 Starts the specific flow.
 .DESCRIPTION
 The Enable-AdminFlow starts the specific flow.
 Use Delete-Help Enable-AdminFlow -Examples for more detail.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 Enable-AdminFlow -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877 -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239
 Starts the 4d1f7648-ad60-4871-91cb-b77d7ef3c239 flow in environment "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877"
 #>
    [CmdletBinding(DefaultParameterSetName="Flow")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $FlowName,

        [Parameter(Mandatory = $false, ParameterSetName = "Flow")]
        [string] $ApiVersion = "2016-11-01"
    )
    process 
    {
        if ($ApiVersion -eq $null -or $ApiVersion -eq "")
        {
            Write-Error "Api Version must be set."
            throw
        }

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/start?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $result = InvokeApi -Method POST -Route $route -Body @{} -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Disable-AdminFlow 
{
<#
 .SYNOPSIS
 Stops the specific flow.
 .DESCRIPTION
 The Disable-AdminFlow stops the specific flow.
 Use Delete-Help Disable-AdminFlow -Examples for more detail.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 Disable-AdminFlow -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877 -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239
 Stops the 4d1f7648-ad60-4871-91cb-b77d7ef3c239 flow in environment "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877"
 #>
    [CmdletBinding(DefaultParameterSetName="Flow")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $EnvironmentName,


        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $FlowName,

        [Parameter(Mandatory = $false, ParameterSetName = "Flow")]
        [string] $ApiVersion = "2016-11-01"
    )
    process 
    {
        if ($ApiVersion -eq $null -or $ApiVersion -eq "")
        {
            Write-Error "Api Version must be set."
            throw
        }

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/stop?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $result = InvokeApi -Method POST -Route $route -Body @{} -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Remove-AdminFlow 
{
<#
 .SYNOPSIS
 Delete the specific flow.
 .DESCRIPTION
 The Remove-AdminFlow deletes the specific flow.
 Use Delete-Help Remove-AdminFlow -Examples for more detail.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER EnvironmentName
 Limit apps returned to those in a specified environment.
 Remove-AdminFlow -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877 -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239
 Deletes the 4d1f7648-ad60-4871-91cb-b77d7ef3c239 flow in environment "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877"
 #>
    [CmdletBinding(DefaultParameterSetName="Flow")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string] $FlowName,

        [Parameter(Mandatory = $false, ParameterSetName = "Flow")]
        [string] $ApiVersion = "2016-11-01"
    )
    process 
    {
        if ($ApiVersion -eq $null -or $ApiVersion -eq "")
        {
            Write-Error "Api Version must be set."
            throw
        }

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}?api-version={apiVersion}"`
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $result = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Set-AdminFlowOwnerRole
{
<#
 .SYNOPSIS
 sets owner permissions to the flow.
 .DESCRIPTION
 The Set-AdminFlowOwnerRole set up permission to flow depending on parameters. 
 Use Get-Help Set-AdminFlowOwnerRole -Examples for more detail.
 .PARAMETER EnvironmentName
 Limit app returned to those in a specified environment.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER RoleName
 Specifies the access level for the user on the flow; CanView or CanEdit
 .PARAMETER PrincipalType
 Specifies the type of principal that is being added as an owner; User or Group (security group)
 .PARAMETER PrincipalObjectId
 Specifies the principal object Id of the user or security group.
 .EXAMPLE
 Set-AdminFlowOwnerRole -PrincipalType Group -PrincipalObjectId b049bf12-d56d-4b50-8176-c6560cbd35aa -RoleName CanEdit -FlowName 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 -EnvironmentName Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877
 Add the specified security group as an owner fo the flow with name 1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488 
 #> 
    [CmdletBinding(DefaultParameterSetName="User")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [ValidateSet("User", "Group")]
        [string]$PrincipalType,

        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [ValidateSet("CanView", "CanEdit")]
        [string]$RoleName,

        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [string]$PrincipalObjectId = $null,

        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$ApiVersion = "2016-11-01"
    )
        
    process 
    {
        $userOrGroup = Get-UsersOrGroupsFromGraph -ObjectId $PrincipalObjectId
        $PrincipalDisplayName = $userOrGroup.DisplayName
        $PrincipalEmail = $userOrGroup.Mail

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/modifyPermissions?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        #Construct the body 
        $requestbody = $null

        $requestbody = @{ 
            put = @(
                @{ 
                    properties = @{
                        principal = @{
                            email = $PrincipalEmail
                            id = $PrincipalObjectId
                            type = $PrincipalType
                            displayName = $PrincipalDisplayName
                        }         
                        roleName = $RoleName      
                    }
                }
            )
        }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}

function Remove-AdminFlowOwnerRole
{
<#
 .SYNOPSIS
 Removes owner permissions to the flow.
 .DESCRIPTION
 The Remove-AdminFlowOwnerRole sets up permission to flow depending on parameters. 
 Use Get-Help Remove-AdminFlowOwnerRole -Examples for more detail.
 .PARAMETER EnvironmentName
 The environment of the flow.
 .PARAMETER FlowName
 Specifies the flow id.
 .PARAMETER RoleId
 Specifies the role id of user or group or tenant.
 .EXAMPLE
 Remove-AdminFlowOwnerRole -EnvironmentName "Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877" -FlowName $flow.FlowName -RoleId "/providers/Microsoft.ProcessSimple/environments/Default-55abc7e5-2812-4d73-9d2f-8d9017f8c877/flows/791fc889-b9cc-4a76-9795-ae45f75d3e48/permissions/1ec3c80c-c2c0-4ea6-97a8-31d8c8c3d488"
 deletes flow permision for the given RoleId, FlowName and Environment name.
 #>
    [CmdletBinding(DefaultParameterSetName="Owner")]
    param
    (
        [Parameter(Mandatory = $false, ParameterSetName = "Owner")]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Owner", ValueFromPipelineByPropertyName = $true)]
        [string]$RoleId
    )

    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/modifyPermissions?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
        | ReplaceMacro -Macro "{environment}" -Value (ResolveEnvironment -OverrideId $EnvironmentName);

        $requestbody = $null

        $requestbody = @{ 
            delete = @(
                @{ 
                    id = $RoleId
                    }
                )
                }

        $result = InvokeApi -Method POST -Route $route -Body $requestbody -ApiVersion $ApiVersion

        CreateHttpResponse($result)
    }
}


function Remove-AdminFlowApprovals
{
 <#
 .SYNOPSIS
 Removes all active and inactive Flow Approvals.
 .DESCRIPTION
 The Remove-AdminFlowApprovals removes all Approval  
 Use Get-Help Remove-AdminFlowApprovals -Examples for more detail.
 .PARAMETER EnvironmentName
 Limits approvals deleted to the specified environment
 .EXAMPLE
 Remove-AdminFlowApprovals -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
 Finds all approvals assigned to the user in the current environment.
 #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        $currentEnvironment = ResolveEnvironment -OverrideId $EnvironmentName;

        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environmentName}/users/{currentUserId}/approvals" `
        | ReplaceMacro -Macro "{environmentName}" -Value $currentEnvironment `
        | ReplaceMacro -Macro "{currentUserId}" -Value $global:currentSession.UserId;

        $approvalRequests = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($approvalRequests);
    }
}

function Get-AdminFlowOwnerRole
{
<#
    .SYNOPSIS
    Gets owner permissions to the flow.
    .DESCRIPTION
    The Get-AdminFlowOwnerRole 
    Use Get-Help Get-AdminFlowOwnerRole -Examples for more detail.
    .PARAMETER EnvironmentName
    The environment of the flow.
    .PARAMETER FlowName
    Specifies the flow id.
    .PARAMETER Owner
    A objectId of the user you want to filter by.
    .EXAMPLE
    Get-AdminFlowOwnerRole -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions across all environments for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-AdminFlowOwnerRole -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions within environment with id 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-AdminFlowOwnerRole -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239 -Owner 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    Returns all flow permissions for the flow with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239 for the user with an object id of 53c0a918-ce7c-401e-98f9-1c60b3a723b3
    .EXAMPLE
    Get-AdminFlowOwnerRole -FlowName 4d1f7648-ad60-4871-91cb-b77d7ef3c239 -EnvironmentName 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    Returns all permissions for the flow with id 4d1f7648-ad60-4871-91cb-b77d7ef3c239 in environment 3c2f7648-ad60-4871-91cb-b77d7ef3c239
    #>
    [CmdletBinding(DefaultParameterSetName="Flow")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Environment", ValueFromPipelineByPropertyName = $true)]
        [string]$EnvironmentName,

        [Parameter(Mandatory = $true, ParameterSetName = "Flow", ValueFromPipelineByPropertyName = $true)]
        [string]$FlowName,

        [Parameter(Mandatory = $false, ParameterSetName = "Flow")]
        [Parameter(Mandatory = $true, ParameterSetName = "User")]
        [Parameter(Mandatory = $true, ParameterSetName = "Environment")]
        [string]$Owner,

        [Parameter(Mandatory = $false, ParameterSetName = "Flow")]
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [Parameter(Mandatory = $false, ParameterSetName = "Environment")]
        [string]$ApiVersion = "2016-11-01"
    )

    process
    {
        if (-not [string]::IsNullOrWhiteSpace($FlowName))
        {
            $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/permissions?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{flowName}" -Value $FlowName `
            | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

            $flowRoleAssignmentResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

            $pattern = BuildFilterPattern -Filter $Owner

            foreach ($flowRole in $flowRoleAssignmentResult.Value)
            {
                if ($pattern.IsMatch($flowRole.properties.principal.id))
                {
                    CreateFlowRoleAssignmentObject -FlowRoleAssignmentObj $flowRole
                }
            }
        }
        else
        {
            $environments = @();
 
            if (-not [string]::IsNullOrWhiteSpace($EnvironmentName))
            {
                $environments += @{
                    EnvironmentName = $EnvironmentName
                }
            }
            else {
                $environments = Get-AdminPowerAppEnvironment -ReturnCdsDatabaseType $false
            }

            foreach($environment in $environments)
            {                        
                $flowResult = Get-AdminFlow -EnvironmentName $environment.EnvironmentName
    
                foreach ($flow in $flowResult)
                {
                    $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/environments/{environment}/flows/{flowName}/permissions?api-version={apiVersion}" `
                    | ReplaceMacro -Macro "{flowName}" -Value $flow.FlowName `
                    | ReplaceMacro -Macro "{environment}" -Value $environment.EnvironmentName;

                    
                    $flowRoleAssignmentResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

                    $pattern = BuildFilterPattern -Filter $Owner

                    foreach ($flowRole in $flowRoleAssignmentResult.Value)
                    {
                        if ($pattern.IsMatch($flowRole.properties.principal.id ))
                        {
                            CreateFlowRoleAssignmentObject -FlowRoleAssignmentObj $flowRole
                        }
                    }
                }
            }
        }
    }
}


function Get-AdminFlowUserDetails
{
<#
 .SYNOPSIS
 Returns the Flow user details for the input user Id.
 .DESCRIPTION
 The Get-AdminFlowUserDetails returns the values for ConsentTime, ConsentBusinessAppPlatformTime, IsDisallowedForInternalPlans, ObjectId, Puid, ServiceSettingsSelectionTime, and TenantId. 
 Use Get-Help Get-AdminFlowUserDetails -Examples for more detail.
 .PARAMETER UserId
 ID of the user query.
 .EXAMPLE
 Get-AdminFlowUserDetails -UserId 7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Retrieves the user details associated with the user Id 7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$UserId = $Global:currentSession.userId,

        
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/users/{userId}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{userId}" -Value $userId `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

        $response = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

        CreateFlowUserDetailsObject($response)
    }
}

function Remove-AdminFlowUserDetails
{
<#
 .SYNOPSIS
 Removes the Flow user details for the input user Id. It will throw an error if the input user is an owner of any flows in the tenant.
 .DESCRIPTION
 The Remove-AdminFlowUserDetails deletes the Flow user details assocaited with the input user Id from the Flow database. 
 Use Get-Help Remove-AdminFlowUserDetails -Examples for more detail.
 .PARAMETER UserId
 Object Id of the user to delete.
 .EXAMPLE
 Remove-AdminFlowUserDetails -UserId 7557f390-5f70-4c93-8bc4-8c2faabd2ca0
 Removes the details associated with the input user Id 7557f390-5f70-4c93-8bc4-8c2faabd2ca0.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$UserId,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01"
    )
    process
    {
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/scopes/admin/users/{userId}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{userId}" -Value $userId `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

        $response = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        if ($response.StatusCode -eq "BadRequest")
        {
            Write-Error "All flows for this user must be deleted before user details can be deleted"
        }
        else
        {
            CreateHttpResponse($response)
        }
    }
}

function Set-AdminPowerAppAsFeatured
{
<#
 .SYNOPSIS
 Updates the input PowerApp to be a featured application for the tenant.
 .DESCRIPTION
 The Set-AdminPowerAppAsFeatured changes the isFeaturedApp flag of a PowerApp to true. 
 Use Get-Help Set-AdminPowerAppAsFeatured -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Set-AdminPowerAppAsFeatured -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to be a featured application of that tenant.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion
        $powerApp.properties.isFeaturedApp = $true

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}

function Clear-AdminPowerAppAsFeatured
{
<#
 .SYNOPSIS
 Removes the input PowerApp as a featured application for the tenant. The input app must not be set as a hero app to unset it as a featured app.
 .DESCRIPTION
 The Unset-AdminPowerAppAsFeatured changes the isFeaturedApp flag of a PowerApp to false. 
 Use Get-Help Unset-AdminPowerAppAsFeatured -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Unset-AdminPowerAppAsFeatured -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to be a regular (not featured) application of that tenant.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (    
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion

        if($powerApp.properties.isHeroApp -eq $true)
        {
            Write-Error "Must unset the app as a Hero before unsetting the app as featured."
            return
        }

        $powerApp.properties.isFeaturedApp = $false

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}

function Set-AdminPowerAppAsHero
{
<#
 .SYNOPSIS
 Identifies the input PowerApp as a hero application. The input app must be set as a featured app to be set as a hero.
 .DESCRIPTION
 The Set-AdminPowerAppAsHero changes the isHero flag of a PowerApp to true. 
 Use Get-Help Set-AdminPowerAppAsHero -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Set-AdminPowerAppAsHero -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to be the hero application of that tenant.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion

        if($powerApp.properties.isFeaturedApp -ne $true)
        {
            Write-Error "Must set the app as a Featured app before setting it as a Hero."
            return
        }

        $powerApp.properties.isHeroApp = $true

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}

function Clear-AdminPowerAppAsHero
{
<#
 .SYNOPSIS
 Removes the input PowerApp as a hero application.
 .DESCRIPTION
 The Unset-AdminPowerAppAsHero changes the isHero flag of a PowerApp to false. 
 Use Get-Help Unset-AdminPowerAppAsHero -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Unset-AdminPowerAppAsHero -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to be a regular application.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion
        $powerApp.properties.isHeroApp = $false

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}


function Set-AdminPowerAppApisToBypassConsent
{
<#
 .SYNOPSIS
 Sets the consent bypass flag so users are not required to authorize API connections for the input PowerApp.
 .DESCRIPTION
 The Set-AdminPowerAppApisToBypassConsent changes the bypassConsent flag of a PowerApp to true. 
 Use Get-Help Set-AdminPowerAppApisToBypassConsent -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Set-AdminPowerAppApisToBypassConsent -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to not require consent for APIs in the production tenant of the logged in user.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion
        $powerApp.properties.bypassConsent = $true

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}

function Clear-AdminPowerAppApisToBypassConsent
{
<#
 .SYNOPSIS
 Removes the consent bypass so users are required to authorize API connections for the input PowerApp.
 .DESCRIPTION
 The Clear-AdminPowerAppApisToBypassConsent changes the bypassConsent flag of a PowerApp to false. 
 Use Get-Help Clear-AdminPowerAppApisToBypassConsent -Examples for more detail.
 .PARAMETER AppName
 App Id of PowerApp to operate on.
 .PARAMETER ApiVersion
 PowerApps Api version date, defaults to "2017-05-01"
 .PARAMETER ForceLease
 Forces the lease when overwriting the PowerApp fields. Defaults to false if no input is provided.
 .EXAMPLE
 Clear-AdminPowerAppApisToBypassConsent -PowerAppName c3dba9c8-0f42-4c88-8110-04b582f20735
 Updates the input PowerApp to require consent in the production tenant of the logged in user.
 #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Name")]
        [string]$AppName,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2017-05-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Boolean]$ForceLease
    )
    process
    {
        $getPowerAppUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

        $powerApp = InvokeApi -Route $getPowerAppUri -Method Get -ThrowOnFailure -ApiVersion $ApiVersion

        $powerApp.properties.bypassConsent = $false

        AcquireLeaseAndPutApp -AppName $AppName -ApiVersion $ApiVersion -PowerApp $powerApp -ForceLease $ForceLease
    }
}


function Get-AdminDlpPolicy
{
    <#
    .SYNOPSIS
    Retrieves api policy objects and provides the option to print out the connectors in each data group.
    .DESCRIPTION
    Get-AdminDlpPolicy cmdlet gets policy objects for the logged in admin's tenant. 
    Use Get-Help Get-AdminDlpPolicy -Examples for more detail.
    .PARAMETER PolicyName
    Retrieves the policy with the input name (identifier).
    .PARAMETER ShowHbi
    Prints out the hbi/business data group api connections if true.
    .PARAMETER ApiVersion
    Specifies the Api version that is called.
    .EXAMPLE
    Get-AdminDlpPolicy
    Retrieves all policies in the tenant.
    Get-AdminDlpPolicy -PolicyName 
    Retrieves details on the policy 78d6c98c-aaa0-4b2b-91c3-83d211754d8a.
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Filter", ValueFromPipelineByPropertyName = $true)]
        [string]$PolicyName,

        [Parameter(Mandatory = $false)]
        [string]$CreatedBy,

        [Parameter(Mandatory = $false, ParameterSetName = "Filter")]
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [object]$ApiVersion = "2016-11-01"
    )
    process
    {
        # get all policies
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

        $response = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

        # filter and returns policies that match parameters
        Get-FilteredApiPolicies -PolicyName $PolicyName -ApiPolicyResult $response -Filter $Filter -CreatedBy $CreatedBy
    }
}

function New-AdminDlpPolicy
{
    <#
    .SYNOPSIS
    Creates and inserts a new api policy into the tenant. By default the environment filter is off, and all api connections are in the no business data group (lbi).
    .DESCRIPTION
    New-AdminDlpPolicy cmdlet creates a new DLP policy for the logged in admin's tenant. 
    Use Get-Help New-AdminDlpPolicy -Examples for more detail.
    .PARAMETER DisplayName
    Creates the policy with the input display name.
    .PARAMETER ApiVersion
    Specifies the Api version that is called.
    .PARAMETER SchemaVersion
    Specifies the schema version to use, 2016-11-01 or 2018-11-01 (HTTP connectors included).
    .EXAMPLE
    New-AdminDlpPolicy -DisplayName "MetroBank Policy"
    Creates a new policy with the display name 'MetroBank Policy' in the tenant.
    .EXAMPLE
    New-AdminDlpPolicy -DisplayName "MRA Digital" -SchemaVersion 2018-11-01
    Creates a new policy with the display name 'MRA Digital' and schema version '2018-11-01' (includes HTTP connectors).
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$DisplayName,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [ValidateSet("2016-10-01-preview", "2018-11-01")][string]$SchemaVersion = "2016-10-01-preview"
    )
    process
    {
        $createApiPolicyRoute = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;
        
        $EnvironmentName = Get-AdminPowerAppEnvironment -Default | Select -Expand EnvironmentName
         
        $getAllConnectorsRoute = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apis?showApisWithToS=true&api-version={apiVersion}&`$expand=permissions(`$filter=maxAssignedTo(%27{userId}%27))&`$filter=environment%20eq%20`'{environment}`'" `
        | ReplaceMacro -Macro "{userId}" -Value $Global:currentSession.userId `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion `
        | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

        $schema = "https://schema.management.azure.com/providers/Microsoft.BusinessAppPlatform/schemas/{schemaVersion}/apiPolicyDefinition.json#" `
        | ReplaceMacro -Macro "{schemaVersion}" -Value $SchemaVersion;

        $lbi = InvokeApi -Method GET -Route $getAllConnectorsRoute -ApiVersion "2017-06-01" | Select -Expand value | `
            %{ New-Object -TypeName PSObject -Property @{ id = $_.id; name = $_.properties.displayName; type = $_.type } } 

        $newPolicy = @{ 
            id = ""
            name = ""
            type = "Microsoft.BusinessAppPlatform/scopes/apiPolicies"
            tags = @{}
            properties = @{
                displayName = $DisplayName
                definition = @{
                    "`$schema" = $schema
                    defaultApiGroup = "lbi"
                    constraints = @{}
                    apiGroups = @{
                        hbi = @{
                            apis = @()
                            description = "Business data only"
                        }
                        lbi = @{
                            apis = $lbi
                            description = "No business data allowed"
                        }
                    }
                    rules = @{
                        dataFlowRule = @{
                            actions = @{
                                blockAction = @{
                                    type = "Block"
                                }
                            }
                            parameters = @{
                                destinationApiGroup = "lbi"
                                sourceApiGroup = "hbi"
                            }
                            type = "DataFlowRestriction"
                        }
                    }
                }               
            }
        }      

        $response = InvokeApi -Method POST -Route $createApiPolicyRoute -Body $newPolicy -ApiVersion "2017-11-01"

        CreateHttpResponse($response)
    }
}


function Remove-AdminDlpPolicy
{
    <#
    .SYNOPSIS
    Deletes the specific Api policy. Delete is successful if it returns a 202 response, 204 means it did not delete.
    .DESCRIPTION
    Remove-AdminDlpPolicy cmdlet deletes a DLP policy. 
    Use Get-Help Remove-AdminDlpPolicy -Examples for more detail.
    .PARAMETER Name
    Finds policy matching the specified filter.
    .PARAMETER ApiVersion
    Specifies the Api version that is called.
    .EXAMPLE
    Remove-AdminDlpPolicy -Name 8c02d657-ad72-4bb9-97c5-afedc4bcf24b
    Deletes policy 8c02d657-ad72-4bb9-97c5-afedc4bcf24b from tenant.
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Name", ValueFromPipelineByPropertyName = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$ApiVersion = "2016-11-01"
    )
    process
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policy}?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{policy}" -Value $Name `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;
        
        $response = InvokeApi -Method DELETE -Route $route -ApiVersion $ApiVersion

        CreateHttpResponse($response)
    }
}

function Set-AdminDlpPolicy
{
    <#
    .SYNOPSIS
    Updates a policy's environment and default api group settings. Upserts the environment list input (does not append).
    .DESCRIPTION
    Set-AdminDlpPolicy cmdlet updates details on the policy, such as environment filter and default api group. 
    Use Get-Help Set-AdminDlpPolicy -Examples for more detail.
    .PARAMETER PolicyName
    Policy name that will be updated.
    .PARAMETER FilterType
    Identifies which filter type the policy will have, none, include or exclude.
    .PARAMETER Environments
    Comma seperated string list used as input environments to either include or exclude, depending on the FilterType.
    .PARAMETER DefaultGroup
    The default group setting, hbi or lbi.
    .PARAMETER ApiVersion
    Specifies the Api version that is called.
    .PARAMETER SchemaVersion
    Specifies the schema version to use, 2016-11-01-preview or 2018-11-01 (HTTP connectors included).
    .EXAMPLE
    Set-AdminDlpPolicy -PolicyName 78d6c98c-aaa0-4b2b-91c3-83d211754d8a -FilterType None
    Clears the environment filter for the policy 78d6c98c-aaa0-4b2b-91c3-83d211754d8a.
    .EXAMPLE
    Set-AdminDlpPolicy -PolicyName 78d6c98c-aaa0-4b2b-91c3-83d211754d8a -FilterType Include -Environments "febb5387-84d7-4717-8345-334a34402f3d,83d98843-bfd7-47ef-bfcd-dc628810ae7b"
    Only applies the policy to the environments febb5387-84d7-4717-8345-334a34402f3d and 83d98843-bfd7-47ef-bfcd-dc628810ae7b.
    .EXAMPLE
    Set-AdminDlpPolicy -PolicyName 78d6c98c-aaa0-4b2b-91c3-83d211754d8a -FilterType Exclude -Environments "febb5387-84d7-4717-8345-334a34402f3d,83d98843-bfd7-47ef-bfcd-dc628810ae7b"
    Applies the policy to all environments except febb5387-84d7-4717-8345-334a34402f3d and 83d98843-bfd7-47ef-bfcd-dc628810ae7b.
    .EXAMPLE
    Set-AdminDlpPolicy -PolicyName 78d6c98c-aaa0-4b2b-91c3-83d211754d8a -DefaultGroup hbi
    Sets the default data group attribute to be hbi (Business data only)
    .EXAMPLE
    Set-AdminDlpPolicy -PolicyName 78d6c98c-aaa0-4b2b-91c3-83d211754d8a -SchemaVersion 2018-11-01
    Sets the DLP Policy to schema version '2018-11-01', allowing for the use of HTTP connectors.
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$PolicyName,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [ValidateSet("None","Include","Exclude")][string]$FilterType,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [ValidateSet("hbi","lbi")][string]$DefaultGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [string]$Environments,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2016-11-01",

        [Parameter(Mandatory = $false, ParameterSetName = "Name")]
        [ValidateSet("2016-11-01-preview","2018-11-01")][string]$SchemaVersion
    )
    process
    {
        $route = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/{policyname}?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{policyname}" -Value $PolicyName `
        | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

        $policy = InvokeApi -Route $route -Method GET -ApiVersion $ApiVersion

        if ($FilterType -eq "None")
        {
            $policy.properties.definition.constraints = @{}
        }
        elseif (-not [string]::IsNullOrWhiteSpace($FilterType))
        {
            if ([string]::IsNullOrWhiteSpace($Environments))
            {
                Write-Error "Environments parameter cannot be empty if assigning included or excluded environments to a policy"
                return
            }

            $getEnvironmentUri = "https://{bapEndpoint}/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/{environmentName}?`$expand=permissions&api-version={apiVersion}";

            $environmentInput = (($Environments -replace "` ","") -split ",") | %{ InvokeApi -Method GET -Route ($getEnvironmentUri | ReplaceMacro -Macro "{environmentName}" -Value $_) -ApiVersion $ApiVersion } `
            | %{ New-Object -TypeName PSObject -Property @{ id = $_.id; name = $_.name; type = $_.type } }

            $constraints = @{
                environmentFilter1 = @{
                    parameters = @{
                        environments = @($environmentInput)
                        filterType = $FilterType.toLower()
                    }
                    type = "environmentFilter"
                }
            }

            $policy.properties.definition.constraints = $constraints
        }

        if (-not [string]::IsNullOrWhiteSpace($DefaultGroup))
        {
            $policy.properties.definition.defaultApiGroup = $DefaultGroup
        }
        if (-not [string]::IsNullOrWhiteSpace($SchemaVersion))
        {
            $schema = "https://schema.management.azure.com/providers/Microsoft.BusinessAppPlatform/schemas/{schemaVersion}/apiPolicyDefinition.json#" `
            | ReplaceMacro -Macro "{schemaVersion}" -Value $SchemaVersion;

            $policy.properties.definition."`$schema" = $schema
        }

        $response = InvokeApi -Method PUT -Route $route -Body $policy -ApiVersion $ApiVersion

        CreateHttpResponse($response)
    }
}

#internal, helper function
function Get-FilteredEnvironments
{
    param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$CreatedBy,

        [Parameter(Mandatory = $false)]
        [object]$EnvironmentResult,

        [Parameter(Mandatory = $false)]
        [bool]$ReturnCdsDatabaseType = $false
    )

    $patternOwner = BuildFilterPattern -Filter $CreatedBy
    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($env in $EnvironmentResult.Value)
    {
        if ($patternOwner.IsMatch($env.properties.createdBy.displayName) -or
            $patternOwner.IsMatch($env.properties.createdBy.email) -or 
            $patternOwner.IsMatch($env.properties.createdBy.id) -or 
            $patternOwner.IsMatch($env.properties.createdBy.userPrincipalName))
        {
            if ($patternFilter.IsMatch($env.name) -or
                $patternFilter.IsMatch($env.properties.displayName))
            {
                CreateEnvironmentObject -EnvObject $env -ReturnCdsDatabaseType $ReturnCdsDatabaseType
            }
        }
    }
}

#internal, helper function
function Get-FilteredApiPolicies
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ApiPolicyResult,
        
        [Parameter(Mandatory = $false)]
        [string]$CreatedBy,
        
        [Parameter(Mandatory = $false)]
        [string]$PolicyName,
        
        [Parameter(Mandatory = $false)]
        [string]$Filter
    )

    $patternPolicyName = BuildFilterPattern -Filter $PolicyName
    $patternOwner = BuildFilterPattern -Filter $CreatedBy
    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($pol in $ApiPolicyResult.Value)
    {
        if ($patternPolicyName.IsMatch($pol.name))
        {
            if ($patternOwner.IsMatch($pol.properties.createdBy.displayName) -or
                $patternOwner.IsMatch($pol.properties.createdBy.email) -or 
                $patternOwner.IsMatch($pol.properties.createdBy.id) -or 
                $patternOwner.IsMatch($pol.properties.createdBy.userPrincipalName))
            {
                if ($patternFilter.IsMatch($pol.name) -or
                    $patternFilter.IsMatch($pol.properties.displayName))
                { 
                    CreateApiPolicyObject -PolicyObject $pol
                }
            }
        }
    }
}

#internal, helper function
function Get-CdsOneDatabase(
    [string]$ApiVersion = "2016-11-01",
    [string]$EnvironmentName = "2016-11-01"
    
)
{
    $route = "https://{cdsOneEndpoint}/providers/Microsoft.CommonDataModel/namespaces?api-version={apiVersion}&`$filter=environment%20eq%20%27{environment}%27" `
    | ReplaceMacro -Macro "{environment}" -Value $EnvironmentName;

    $databaseResult = InvokeApi -Method GET -Route $route -ApiVersion $ApiVersion

    CreateCdsOneDatabasObject -DatabaseObject $databaseResult.Value
}

#internal, helper function
function Get-FilteredApps
{
     param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$Owner,

        [Parameter(Mandatory = $false)]
        [object]$AppResult
    )

    $patternOwner = BuildFilterPattern -Filter $Owner
    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($app in $AppResult.Value)
    {
        if ($patternOwner.IsMatch($app.properties.owner.displayName) -or
            $patternOwner.IsMatch($app.properties.owner.email) -or 
            $patternOwner.IsMatch($app.properties.owner.id) -or 
            $patternOwner.IsMatch($app.properties.owner.userPrincipalName))
        {
            if ($patternFilter.IsMatch($app.name) -or
                $patternFilter.IsMatch($app.properties.displayName))
            {
                CreateAppObject -AppObj $app
            }
        }
    }
}

#internal, helper function
function Get-FilteredConnections
{
     param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$CreatedBy,

        [Parameter(Mandatory = $false)]
        [object]$ConnectionResult
    )

    $patternCreatedBy = BuildFilterPattern -Filter $CreatedBy
    $patternFilter = BuildFilterPattern -Filter $Filter
            
    foreach ($connection in $ConnectionResult.Value)
    {
        if ($patternCreatedBy.IsMatch($connection.properties.createdBy.displayName) -or
            $patternCreatedBy.IsMatch($connection.properties.createdBy.email) -or 
            $patternCreatedBy.IsMatch($connection.properties.createdBy.id) -or 
            $patternCreatedBy.IsMatch($connection.properties.createdBy.userPrincipalName))
        {
            if ($patternFilter.IsMatch($connection.name) -or
                $patternFilter.IsMatch($connection.properties.displayName))
            {
                CreateConnectionObject -ConnectionObj $connection
            }
        }
    }
}

#internal, helper function
function Get-FilteredFlows
{
    param
    (
        [Parameter(Mandatory = $false)]
        [object]$Filter,

        [Parameter(Mandatory = $false)]
        [object]$CreatedBy,

        [Parameter(Mandatory = $false)]
        [object]$FlowResult
    )

    if (-not [string]::IsNullOrWhiteSpace($CreatedBy))
    {
        $pattern = BuildFilterPattern -Filter $CreatedBy
            
        foreach ($flow in $FlowResult.Value)
        {
            if ($pattern.IsMatch($flow.properties.creator.objectId) -or
                $pattern.IsMatch($flow.properties.creator.userId))
            {
                CreateFlowObject -FlowObj $flow
            }
        }

    }
    else
    {
        $pattern = BuildFilterPattern -Filter $Filter

        foreach ($flow in $flowResult.Value)
        {
            if ($pattern.IsMatch($flow.name) -or
                $pattern.IsMatch($flow.properties.displayName))
            {
                CreateFlowObject -FlowObj $flow
            }
        }
    }   
}

#internal, helper function
function CreateHttpResponse
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ResponseObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name Code -Value $ResponseObject.StatusCode `
        | Add-Member -PassThru -MemberType NoteProperty -Name Description -Value $ResponseObject.StatusDescription `
        | Add-Member -PassThru -MemberType NoteProperty -Name Error -Value $ResponseObject.error `
        | Add-Member -PassThru -MemberType NoteProperty -Name Errors -Value $ResponseObject.errors `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $ResponseObject;
}

#internal, helper function
function CreateEnvironmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$EnvObject,

        [Parameter(Mandatory = $false)]
        [bool]$ReturnCdsDatabaseType
    )

    If($ReturnCdsDatabaseType)
    {
        $cdsDatabaseType = "None"

        # this property will be set if the environment has linked CDS 2.0 database
        $LinkedCdsTwoInstanceType = $EnvObject.properties.linkedEnvironmentMetadata.type;

        if($LinkedCdsTwoInstanceType -eq "Dynamics365Instance")
        {
            $cdsDatabaseType = "Common Data Service for Apps"
        }
        else
        {
            #unfortunately there is no other way to determine if an environment has a database other than making a separate REST API call
            $cdsOneDatabase = Get-CdsOneDatabase -ApiVersion $ApiVersion -EnvironmentName $EnvObject.name

            if ($cdsOneDatabase.EnvironmentName -eq $EnvObject.name)
            {
                $cdsDatabaseType = "Common Data Service (Previous Version)"
            }       
        }
    }
    else {
        $cdsDatabaseType = "Unknown"
    }

    

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $EnvObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsDefault -Value $EnvObject.properties.isDefault `
        | Add-Member -PassThru -MemberType NoteProperty -Name Location -Value $EnvObject.location `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $EnvObject.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -value $EnvObject.properties.createdBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $EnvObject.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedBy -value $EnvObject.properties.lastModifiedBy.userPrincipalName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreationType -value $EnvObject.properties.creationType `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentType -value $EnvObject.properties.environmentSku `
        | Add-Member -PassThru -MemberType NoteProperty -Name CommonDataServiceDatabaseProvisioningState -Value $EnvObject.properties.provisioningState `
        | Add-Member -PassThru -MemberType NoteProperty -Name CommonDataServiceDatabaseType -Value $cdsDatabaseType `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $EnvObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name InternalCds -value $cdsOneDatabase;
}

#internal, helper function
function CreateEnvironmentLocationObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$EnvironmentLocationObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name LocationName -Value $EnvironmentLocationObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name LocationDisplayName -Value $EnvironmentLocationObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $EnvironmentLocationObject;
}

#internal, helper function
function CreateCurrencyObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$CurrencyObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name CurrencyName -Value $CurrencyObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name CurrencyCode -Value $CurrencyObject.properties.code `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsTenantDefaultCurrency -Value $CurrencyObject.properties.isTenantDefault `
        | Add-Member -PassThru -MemberType NoteProperty -Name CurrencySymbol -Value $CurrencyObject.properties.symbol `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $CurrencyObject;
}

#internal, helper function
function CreateLanguageObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$LanguageObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name LanguageName -Value $LanguageObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name LanguageDisplayName -Value $LanguageObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsTenantDefaultLanguage -Value $LanguageObject.properties.isTenantDefault `
        | Add-Member -PassThru -MemberType NoteProperty -Name LanguageLocalizedDisplayName -Value $LanguageObject.properties.localizedName `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $LanguageObject;
}

#internal, helper function
function CreateCdsOneDatabasObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$DatabaseObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name DatabaseId -Value $DatabaseObject.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name DatabaseName -Value $DatabaseObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $DatabaseObject.properties.environmentId `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $DatabaseObject.properties.createdDateTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $DatabaseObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name ProvisioningState -Value $DatabaseObject.properties.provisioningState `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -value $DatabaseObject;
}

#internal, helper function
function CreateAppObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$AppObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value $AppObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $AppObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $AppObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name Owner -Value $AppObj.properties.owner `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $AppObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $AppObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name UnpublishedAppDefinition -Value $AppObj.properties.unpublishedAppDefinition `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsFeaturedApp -Value $AppObj.properties.isFeaturedApp `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsHeroApp -Value $AppObj.properties.isHeroApp `
        | Add-Member -PassThru -MemberType NoteProperty -Name BypassConsent -Value $AppObj.properties.bypassConsent `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppObj;
        #bypassConsent
}

#internal, helper function
function CreateFlowObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$FlowObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value $FlowObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Enabled -Value ($FlowObj.properties.state -eq 'Started') `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $FlowObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name UserType -Value $FlowObj.properties.userType `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $FlowObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -Value $FlowObj.properties.creator `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $FlowObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $FlowObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowObj;
}

#internal, helper function
function CreateAppRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$AppRoleAssignmentObj
    )
        
    If($AppRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    elseif($AppRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $AppRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $AppRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    elseif($AppRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $AppRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $AppRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $AppRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $AppRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $AppRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $AppRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name AppName -Value ((($AppRoleAssignmentObj.properties.scope -split "/apps/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($AppRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $AppRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateFlowRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$FlowRoleAssignmentObj
    )
        
    if($FlowRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $FlowRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $FlowRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $FlowRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $FlowRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $FlowRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value ((($FlowRoleAssignmentObj.id -split "/flows/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($FlowRoleAssignmentObj.id -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowRoleAssignmentObj;
    }
    elseif($FlowRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $FlowRoleAssignmentObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $FlowRoleAssignmentObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $FlowRoleAssignmentObj.properties.principal.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $FlowRoleAssignmentObj.properties.principal.type `
        | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $FlowRoleAssignmentObj.properties.roleName `
        | Add-Member -PassThru -MemberType NoteProperty -Name FlowName -Value ((($FlowRoleAssignmentObj.id -split "/flows/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($FlowRoleAssignmentObj.id -split "/environments/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $FlowRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateEnvRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$EnvRoleAssignmentObj,

        [Parameter(Mandatory = $false)]
        [object]$EnvObj
    )
        
    If($EnvRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $EnvRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $EnvRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $EnvRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $EnvRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $EnvRoleAssignmentObj.properties.roleDefinition.name`
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($EnvRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentObject -Value $EnvObj `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $EnvRoleAssignmentObj;
    }
    elseif($EnvRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $EnvRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $EnvRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $EnvRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $EnvRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $EnvRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $EnvRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $EnvRoleAssignmentObj.properties.roleDefinition.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($EnvRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentObject -Value $EnvObj `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $EnvRoleAssignmentObj;
    }
    elseif($EnvRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $EnvRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $EnvRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $EnvRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $EnvRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $EnvRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $EnvRoleAssignmentObj.properties.roleDefinition.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value ((($EnvRoleAssignmentObj.properties.scope -split "/environments/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentObject -Value $EnvObj `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $EnvRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateConnectionObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectionObj
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value $ConnectionObj.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionId -Value $ConnectionObj.id `
        | Add-Member -PassThru -MemberType NoteProperty -Name FullConnectorName -Value $ConnectionObj.properties.apiId `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionObj.properties.apiId -split "/apis/")[1]) -split "/")[0] `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $ConnectionObj.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $ConnectionObj.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -Value $ConnectionObj.properties.createdBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $ConnectionObj.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $ConnectionObj.properties.environment.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name Statuses -Value $ConnectionObj.properties.statuses `
        | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionObj;
}

#internal, helper function
function CreateConnectionRoleAssignmentObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ConnectionRoleAssignmentObj,

        [Parameter(Mandatory = $false)]
        [string]$EnvironmentName
    )

    If($ConnectionRoleAssignmentObj.properties.principal.type -eq "Tenant")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.tenantId `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/connections/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    elseif($ConnectionRoleAssignmentObj.properties.principal.type -eq "User")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectionRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $ConnectionRoleAssignmentObj.properties.principal.email `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/connections/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    elseif($ConnectionRoleAssignmentObj.properties.principal.type -eq "Group")
    {
        return New-Object -TypeName PSObject `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleId -Value $ConnectionRoleAssignmentObj.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleName -Value $ConnectionRoleAssignmentObj.name `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalDisplayName -Value $ConnectionRoleAssignmentObj.properties.principal.displayName `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalEmail -Value $null `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalObjectId -Value $ConnectionRoleAssignmentObj.properties.principal.id `
            | Add-Member -PassThru -MemberType NoteProperty -Name PrincipalType -Value $ConnectionRoleAssignmentObj.properties.principal.type `
            | Add-Member -PassThru -MemberType NoteProperty -Name RoleType -Value $ConnectionRoleAssignmentObj.properties.roleName `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectionName -Value ((($ConnectionRoleAssignmentObj.id -split "/permission/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name ConnectorName -Value ((($ConnectionRoleAssignmentObj.id -split "/apis/")[1]) -split "/")[0] `
            | Add-Member -PassThru -MemberType NoteProperty -Name EnvironmentName -Value $EnvironmentName `
            | Add-Member -PassThru -MemberType NoteProperty -Name Internal -Value $ConnectionRoleAssignmentObj;
    }
    else {
        return $null
    }
}

#internal, helper function
function CreateFlowUserDetailsObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$FlowUserObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConsentBusinessAppPlatformTime -Value $FlowUserObject.consentBusinessAppPlatformTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name ConsentTime -Value $FlowUserObject.consentTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name IsDisallowedForInternalPlans -Value $FlowUserObject.isDisallowedForInternalPlans `
        | Add-Member -PassThru -MemberType NoteProperty -Name ObjectId -Value $FlowUserObject.objectId `
        | Add-Member -PassThru -MemberType NoteProperty -Name Puid -Value $FlowUserObject.puid `
        | Add-Member -PassThru -MemberType NoteProperty -Name ServiceSettingsSelectionTime -Value $FlowUserObject.serviceSettingsSelectionTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name TenantId -Value $FlowUserObject.tenantId;
}

#internal, helper method
function CreateApiPolicyObject
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$PolicyObject
    )

    return New-Object -TypeName PSObject `
        | Add-Member -PassThru -MemberType NoteProperty -Name PolicyName -Value $PolicyObject.name `
        | Add-Member -PassThru -MemberType NoteProperty -Name DisplayName -Value $PolicyObject.properties.displayName `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedTime -Value $PolicyObject.properties.createdTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name CreatedBy -Value $PolicyObject.properties.createdBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedTime -Value $PolicyObject.properties.lastModifiedTime `
        | Add-Member -PassThru -MemberType NoteProperty -Name LastModifiedBy -Value $PolicyObject.properties.lastModifiedBy `
        | Add-Member -PassThru -MemberType NoteProperty -Name Constraints -Value $PolicyObject.properties.definition.constraints `
        | Add-Member -PassThru -MemberType NoteProperty -Name BusinessDataGroup -Value $PolicyObject.properties.definition.apiGroups.hbi.apis`
        | Add-Member -PassThru -MemberType NoteProperty -Name NonBusinessDataGroup -Value $PolicyObject.properties.definition.apiGroups.lbi.apis`
        | Add-Member -PassThru -MemberType NoteProperty -Name FilterType -Value $PolicyObject.properties.definition.constraints.environmentFilter1.parameters.filterType `
        | Add-Member -PassThru -MemberType NoteProperty -Name Environments -Value $PolicyObject.properties.definition.constraints.environmentFilter1.parameters.environments;
}

#internal, helper method
function AcquireLeaseAndPutApp(
    [CmdletBinding()]
    
    [string]$AppName,
    [string]$ApiVersion,
    [Object]$PowerApp,
    [Boolean]$ForceLease
)
{
    if ($ApiVersion -eq $null -or $ApiVersion -eq "")
    {
        Write-Error "Api Version must be set."
        throw
    }
    
    $apiVersionsBeforePublishSave = @("2016-11-01", "2017-02-01", "2017-04-01")
    foreach ($apiVersionPrefix in $apiVersionsBeforePublishSave)
    {
        $doesNotNeedPublish = $ApiVersion -Match $apiVersionPrefix
        if ($doesNotNeedPublish)
        {
            Write-Warning "Older API version, please use 2017-05-01 or newer."
            break;
        }
    }

    if ($ForceLease)
    {
        $forceLeaseFlag = "true"
    }
    else
    {
        $forceLeaseFlag = "false" 
    }

    $powerAppBaseUri = "https://{powerAppsEndpoint}/providers/Microsoft.PowerApps/apps/{appName}" `
        | ReplaceMacro -Macro "{powerAppsEndpoint}" -Value $Global:currentSession.powerAppsEndpoint `
        | ReplaceMacro -Macro "{appName}" -Value $AppName;

    $acquireLeaseUri = "{powerAppBaseUri}/acquireLease`?api-version={apiVersion}&forceLeaseAcquisition={forceLeaseFlag}" `
        | ReplaceMacro -Macro "{powerAppBaseUri}" -Value $powerAppBaseUri `
        | ReplaceMacro -Macro "{forceLeaseFlag}" -Value $forceLeaseFlag;
        
    $releaseLeaseUri = "{powerAppBaseUri}/releaseLease`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{powerAppBaseUri}" -Value $powerAppBaseUri;

    $putPowerAppUri = "{powerAppBaseUri}/`?api-version={apiVersion}" `
        | ReplaceMacro -Macro "{powerAppBaseUri}" -Value $powerAppBaseUri;

    $leaseResponse = InvokeApi -Route $acquireLeaseUri -Method Post -ThrowOnFailure -ApiVersion $ApiVersion

    if ($doesNotNeedPublish)
    {
        $response = InvokeApi -Route $putPowerAppUri -Method Put -Body $PowerApp -ThrowOnFailure -ApiVersion $ApiVersion
    }
    else
    {
        $powerApp.Properties.LifeCycleId = "Draft"
        $response = InvokeApi -Route $putPowerAppUri -Method Put -Body $PowerApp -ThrowOnFailure -ApiVersion $ApiVersion

        $publishPowerAppUri = "{powerAppBaseUri}/publish`?api-version={apiVersion}" `
            | ReplaceMacro -Macro "{powerAppBaseUri}" -Value $powerAppBaseUri `
            | ReplaceMacro -Macro "{apiVersion}" -Value $ApiVersion;

        $publishResponse = InvokeApi -Route $publishPowerAppUri -Method Post -ThrowOnFailure -ApiVersion $ApiVersion
    }

    $response = InvokeApi -Route $releaseLeaseUri -Method Post -Body $leaseResponse -ThrowOnFailure -ApiVersion $ApiVersion
    CreateHttpResponse($response)
}