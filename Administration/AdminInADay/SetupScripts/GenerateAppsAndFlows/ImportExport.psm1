
Import-Module (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "PowerApps-RestClientModule.psm1") -Force
Import-Module (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "PowerApps-AuthModule.psm1") -Force
Import-Module (Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "Microsoft.PowerApps.Administration.PowerShell.psm1") -Force


function Invoke-OAuthDialogJames(
    [string] $ConsentLinkUri
)
{
    # windows forms dependencies
    Add-Type -AssemblyName System.Windows.Forms 
    Add-Type -AssemblyName System.Web

    # create window for embedded browser
    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=640;Height=480}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=640;Height=480}

    # global for collecting authorization code response
    $Global:redirect_uri = $null
    
    $web_Navigated = {
        $Global:redirect_uri = $web.Url.AbsoluteUri  
        #Write-Host $Global:redirect_uri 

        if ($_.Url.AbsoluteURI.Contains("code=")) { 
            $form.Close()
        }
        #if ($_.Url.AbsoluteURI -match "error=[^&]*|code=[^&]*") { $form.Close()}
        #if ($Global:redirect_uri -match "error=[^&]*|code=[^&]*") { $form.Close()}
    }

    $web.ScriptErrorsSuppressed = $true
    $web.Anchor = "Left,Top,Right,Bottom"
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $web.add_Navigated($web_Navigated)        
    
    $web.Navigate("https://web.powerapps.com/oauth/")
    $web.Navigate($consentLink)
    $form.ShowDialog() | Out-Null

    if(-not $Global:redirect_uri) {
        #Write-Host "WebBrowser: redirect_uri is null"
        return $null
    }

    if(-not $Global:redirect_uri.Contains("code=")) {
        #Write-Host "WebBrowser: connection authorization failed"
        return $null
    }

    $consentCodeUrl = $Global:redirect_uri
    $index = $consentCodeUrl.IndexOf('code=') + 5
    return $consentCodeUrl.Substring($index)
}

function Export-ResourcePackage(
    [ValidateSet("app", "flow")]
    [string] $ResourceType,
    [string] $ResourceName,
    [string] $SourceEnvironmentName,
    [string] $PackageName,
    [string] $PackageDescription,
    [string] $CreatorName,
    [string] $ExportZipFilePath,
    [string] $ApiVersion = "2016-11-01"
)
{
    #Endpoints of the PowerApps service
    $listPackageResourcesUrl = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/$SourceEnvironmentName/listPackageResources`?api-version=$ApiVersion"
    $exportUrl = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/$SourceEnvironmentName/exportPackage`?api-version=$ApiVersion"
    
    Switch($ResourceType)
    {
        "app"
        {  
            #Call list package resources for the app
            $requestbody = @{ 
                baseResourceIds = @("/providers/Microsoft.PowerApps/apps/" + $ResourceName) 
            }
        }
        "flow"
        {
            #Call list package resources for the flow
            $requestbody = @{ 
                baseResourceIds = @("/providers/Microsoft.Flow/flows/" + $ResourceName) 
            }
        }
    }  

    #Write-Host "Listing the dependent resources for this app..."
    $listPackageResourcesResponse = Invoke-Request -Uri $listPackageResourcesUrl -Method POST -Body $requestbody -ParseContent -ThrowOnFailure 
    
    #Configure the suggested creation type for each resources
    $configuredResources = Configure-ExportResourcesObject -resources $listPackageResourcesResponse.resources

    #Construct the export request
    $exportRequestBody = @{ 
        includedResourceIds = $configuredResources.resourceIds
        details = @{ 
            displayName = $PackageName
            description = $PackageDescription 
            creator = $CreatorName
            sourceEnvironment = $SourceEnvironmentName
        }
        resources = $configuredResources.resources
    }

    #Write-Host "Starting export..."

    #Kick-off export
    $exportResponse = Invoke-Request -Uri $exportUrl -Method POST -Body $exportRequestBody -ThrowOnFailure
    $exportStatusUrl = $exportResponse.Headers['Location']

    #Wait until the package has been generated
    while($exportResponse.StatusCode -ne 200) 
    {
        Start-Sleep -s 5
        $exportResponse = Invoke-Request -Uri $exportStatusUrl -Method GET -ThrowOnFailure
    }

    $exportResponseBody = ConvertFrom-Json $exportResponse.Content
    
    if(($exportResponseBody.errors).Length -gt 0)
    {
        Write-Host "Package export failed with the following errors `n" + $exportResponseBody.errors
        throw
    }

    
    Switch($ResourceType)
    {
        "app"
        {  
            $exportPackageBlobUrl = $exportResponseBody.properties.packageLink.value
        }
        "flow"
        {
            $exportPackageBlobUrl = $exportResponseBody.packageLink.value
        }
    }  

    $downloadZipResponse = $null

    #Write-Host "Downloading export file..."

    try {
        $downloadZipResponse = Invoke-WebRequest -Uri $exportPackageBlobUrl -OutFile $ExportZipFilePath
    } catch {
        $response = $_.Exception.Response
        if ($_.ErrorDetails)
        {
            $errorResponse = ConvertFrom-Json $_.ErrorDetails;
            $code = $response.StatusCode
            $message = $errorResponse.error.message
            Write-Verbose "Status Code: '$code'. Message: '$message'" 
        }
    }

    #Return the blog URL for the Export package
    return $exportResponseBody
}


function Import-Package(
    [string] $EnvironmentName,
    [string] $ImportPackageFilePath,
    [string] $ApiVersion = "2016-11-01",
    [bool] $DefaultToExportSuggestions = $false,
    [bool] $AutoSelectDataSourcesOnImport = $false,
    [string] $ResourceName
)
{
    #---------------------Upload the file to blob storage---------------------

    $blobUri = Upload-FileToBlogStorage -EnvironmentName $EnvironmentName -FilePath $ImportPackageFilePath -ApiVersion $ApiVersion

    #---------------------List the import package resources ---------------------
    
    $parsedListParametersResponse = Get-ImportPackageResources -EnvironmentName $EnvironmentName -ImportPackageBlobUri $blobUri -ApiVersion $ApiVersion
    
    #---------------------Configure the import parameters for each package resource  ---------------------

    #Configure the suggested creation type for each resource
    $includedResources = Configure-ImportResourcesObject -resources $parsedListParametersResponse.properties.resources -EnvironmentName $EnvironmentName -DefaultToExportSuggestions $DefaultToExportSuggestions -AutoSelectDataSourcesOnImport $AutoSelectDataSourcesOnImport -ResourceName $ResourceName

    #Write-Host "Configuration complete..."

    #---------------------Validate the import package  ---------------------

    #Call to validate the import package
    $validateImportPackageUri = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/" + $EnvironmentName + "/validateImportPackage`?api-version=" + $ApiVersion

    #Generate the request body
    $validateImportPackageBody = @{ 
        details = $parsedListParametersResponse.properties.details
        packageLink = $parsedListParametersResponse.properties.packageLink
        resources = $includedResources.resources
    }

    # Write-Host "Validating package..."

    $validateImportPackageResponse = Invoke-Request -Uri $validateImportPackageUri -Method POST -Body $validateImportPackageBody -ThrowOnFailure

    #Parse the response content
    $parsedValidateImportResponse = ConvertFrom-Json $validateImportPackageResponse.Content

    if(($parsedValidateImportResponse.errors).Length -gt 0)
    {
        Write-Host "Package failed validation with the following errors \n" + $parsedValidateImportResponse.errors
        throw
    }
    
    #---------------------If there are no errors, start the import  ---------------------

    # Write-Host "Package validation complete, starting import..."

    #Call to import the  package
    $importPackageUri = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/" + $EnvironmentName + "/importPackage`?api-version=" + $ApiVersion

    $importPackageResponse = Invoke-Request -Uri $importPackageUri -Method POST -Body $validateImportPackageBody -ThrowOnFailure
    $importStatusUri= $importPackageResponse.Headers['Location']

    #Wait until import is completed
    while($importPackageResponse.StatusCode -ne 200) 
    {
        Start-Sleep -s 5
        $importPackageResponse = Invoke-Request -Uri $importStatusUri -Method GET -ThrowOnFailure
    }

    #Parse the response content
    $parsedImportPackageResponse = ConvertFrom-Json $importPackageResponse.Content

    if(($parsedImportPackageResponse.properties.errors).Length -gt 0)
    {
        Write-Host "Package failed import with the following errors " + $parsedImportPackageResponse.properties.errors
    }
    # else {
    #     Write-Host "Import successful"        
    # }

    return $parsedImportPackageResponse
}

function Configure-ExportResourcesObject(
    $Resources
)
{
    $includedResourceIds = @()
    $includedSuggestedResourceIds = @()
    $includedResources = $Resources
    $numResources = 0
    
        #Add the 'suggestedCreationType' property to each resources object
        foreach ($resource in Get-Member -InputObject $includedResources -MemberType NoteProperty)
        {
            #Increase Count
            $numResources = $numResources + 1 
            
            #Grab the value of this resource
            $property = 'Name'
            $propertyvalue = $resource.$property

            #add id to the list if it is not null
            If($includedResources.$propertyvalue.id -ne $null -and $includedResources.$propertyvalue.id -ne "")
            {
                $includedResourceIds = $includedResourceIds + $includedResources.$propertyvalue.id
            }

            #add suggested id to the suggestedId
            If(!$includedSuggestedResourceIds.$propertyvalue.suggestedId)
            {
                $includedSuggestedResourceIds = $includedSuggestedResourceIds + $includedSuggestedResourceIds.$propertyvalue.suggestedId
            }
    
            #Next we need determine the type of this resource
            $type = $null
            
            ## For an app let's just create a new app
            if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apps")
            {
                $type = "New"
            }
            
            ## For a flow let's just create a new flow
            if ($includedResources.$propertyvalue.type -eq "Microsoft.Flow/flows")
            {
                $type = "New"
            }	
    
            ## For a custom connector select 'choose existing'
            if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apis" -and $includedResources.$propertyvalue.name.Contains("."))
            {
                $type = "Existing"
            }
    
            ## For a connection select 'choose existing'
            if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apis/connections")
            {
                $type = "Existing"
            }
    
            ## For a picklist select 'Merge'
            if ($includedResources.$propertyvalue.type -eq "Microsoft.CommonDataModel/environments/namespaces/enumerations" -and $includedResources.$propertyvalue.configurableBy -eq "User")
            {
                $type = "Merge"
            }
    
            ## For a entity select 'Merge'
            if ($includedResources.$propertyvalue.type -eq "Microsoft.CommonDataModel/environments/namespaces/entities" -and $includedResources.$propertyvalue.configurableBy -eq "User")
            {
                $type = "Merge"
            }
    
            #Set the suggested Creation type for the resource
            If($type)
            {
                If($includedResources.$propertyvalue.suggestedCreationType)
                {
                    $includedResources.$propertyvalue.suggestedCreationType = $type
                }
                else
                {
                    $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name suggestedCreationType -value $type
                }
            }
        }
        
        # Write-Host "Found $numResources dependent resources..."

        $responseObject = @{
            resources = $includedResources
            resourceIds = $includedResourceIds
            suggestedResourceIds = $includedSuggestedResourceIds
        } 

        return $responseObject
}

function Configure-ImportResourcesObject(
    $Resources,
    $EnvironmentName = $null,
    [bool]$DefaultToExportSuggestions = $false,
    [bool] $AutoSelectDataSourcesOnImport = $false,
    [string] $ResourceName
)
{
    $includedResourceIds = @()
    $includedSuggestedResourceIds = @()
    $includedResources = $Resources
    $numResources = 0

    $env = Get-AdminPowerAppEnvironment -EnvironmentName $EnvironmentName
    $environmentDisplayName = $env.DisplayName

    $selectedCommonDataServiceOption = $null

    #Add the 'suggestedCreationType' property to each resources object
    foreach ($resource in Get-Member -InputObject $includedResources -MemberType NoteProperty)
    {
        #Increase Count
        $numResources = $numResources + 1 
        
        #Grab the value of this resource
        $property = 'Name'
        $propertyvalue = $resource.$property

        #add id to the list if it is not null
        If($includedResources.$propertyvalue.id -ne $null -and $includedResources.$propertyvalue.id -ne "")
        {
            $includedResourceIds = $includedResourceIds + $includedResources.$propertyvalue.id
        }

        #add suggested id to the suggestedId
        If(!$includedSuggestedResourceIds.$propertyvalue.suggestedId)
        {
            $includedSuggestedResourceIds = $includedSuggestedResourceIds + $includedSuggestedResourceIds.$propertyvalue.suggestedId
        }

        #Next we need determine the type of this resource
        $type = $null
        
        if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apps")
        {
            $result = $null
            $selection = $null

            if($AutoSelectDataSourcesOnImport)
            {
                $type = "New"
                $includedResources.$propertyvalue.details.displayName = $ResourceName
            }
            else 
            {
                if($DefaultToExportSuggestions -and ($includedResources.$propertyvalue.suggestedCreationType -ne $null))
                {
                    $result = Configure-AppResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -AppResourceObject $includedResources.$propertyvalue -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType
                    $selection = $result.selection
                }
                else {
                    
                    $result = Configure-AppResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -AppResourceObject $includedResources.$propertyvalue
                    $selection = $result.selection
                }

                Switch ($selection) {
                    "New"
                    {
                        $type = "New"

                        $includedResources.$propertyvalue.details.displayName = $result.displayName
                    } 
                    "Update" 
                    {
                        $type = "Update"

                        $selectedResource = $result.selectedResource
                        
                        #$includedResources.$propertyvalue.id = $selectedResource.id
                        #$includedResources.$propertyvalue.details.displayName = $selectedResource.displayName
                        
                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name id -value $selectedResource.id
                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name name -value $selectedResource.name
                    }
                    Default 
                    {
                        return
                    }
                }
            }          
        }
        
        if ($includedResources.$propertyvalue.type -eq "Microsoft.Flow/flows")
        {
            $result = $null
            $selection = $null

            if($AutoSelectDataSourcesOnImport)
            {
                $type = "New"
                $includedResources.$propertyvalue.details.displayName = $ResourceName
            }
            else 
                {
                if($DefaultToExportSuggestions -and ($includedResources.$propertyvalue.suggestedCreationType -ne $null))
                {
                    $result = Configure-FlowResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -FlowResourceObject $includedResources.$propertyvalue -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType
                    $selection = $result.selection
                }
                else {
                    
                    $result = Configure-FlowResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -FlowResourceObject $includedResources.$propertyvalue
                    $selection = $result.selection
                }

                # $result = Configure-FlowResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -FlowResourceObject $includedResources.$propertyvalue
                # $selection = $result.selection

                $type = $null

                Switch ($selection) {
                    "New"
                    {
                        $type = "New"

                        $includedResources.$propertyvalue.details.displayName = $result.displayName
                    } 
                    "Update" 
                    {
                        $type = "Update"

                        $selectedResource = $result.selectedResource
                        
                        #$includedResources.$propertyvalue.id = $selectedResource.id
                        #$includedResources.$propertyvalue.details.displayName = $selectedResource.displayName

                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name id -value $selectedResource.id
                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name name -value $selectedResource.name
                    }
                    Default 
                    {
                        return
                    }
                }
            }
        }	

        if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apis")
        {
            #if the name of the connector is not null then it is a shared connector, not a custom connector
            if ($includedResources.$propertyvalue.name -eq $null)
            {
                $result = $null
                $selection = $null
                
                # if($AutoSelectDataSourcesOnImport)
                # {
                    # $type = "Existing"
                #     $result = Configure-ConnectorResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectorResourceObject $includedResources.$propertyvalue -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType -AutoSelectDataSourcesOnImport $AutoSelectDataSourcesOnImport
                # }
                # else
                if($DefaultToExportSuggestions -and ($includedResources.$propertyvalue.suggestedCreationType -ne $null))
                {
                    $result = Configure-ConnectorResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectorResourceObject $includedResources.$propertyvalue -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType
                    $selection = $result.selection
                }
                else {
                    
                    $result = Configure-ConnectorResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectorResourceObject $includedResources.$propertyvalue
                    $selection = $result.selection
                }
    
                Switch ($selection) {
                    "Existing" 
                    {
                        $type = "Existing"
                        $selectedResource = $result.selectedResource
    
                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name id -value $selectedResource.id
                        $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name name -value $selectedResource.name
                    }
                }
            }
            #If the connector is a shared connector then set its selected creation type to Existing
            else {                
                $type = "Existing"
            }
        }

        if ($includedResources.$propertyvalue.type -eq "Microsoft.PowerApps/apis/connections")
        {
            $result = $null
            $selection = $null
            
            $dependsOnResourceId = $includedResources.$propertyvalue.dependsOn[0]
            If($dependsOnResourceId -ne $null)
            {
                $parentResource = $includedResources.$dependsOnResourceId
            }   

            if($AutoSelectDataSourcesOnImport)
            {
                $type = "Existing"
                $result = Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectionResourceObject $includedResources.$propertyvalue -ParentResource $parentResource -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType -AutoSelectDataSourcesOnImport $AutoSelectDataSourcesOnImport
                $selection = $result.selection
            }
            elseif($DefaultToExportSuggestions -and ($includedResources.$propertyvalue.suggestedCreationType -ne $null))
            {
                $result = Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectionResourceObject $includedResources.$propertyvalue -ParentResource $parentResource -PreselectedOption $includedResources.$propertyvalue.suggestedCreationType
                $selection = $result.selection
            }
            else {
                
                $result = Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $environmentDisplayName -ConnectionResourceObject $includedResources.$propertyvalue -ParentResource $parentResource 
                $selection = $result.selection
            }

            Switch ($selection) {
                "Existing" 
                {
                    $type = "Existing"
                    $selectedResource = $result.selectedResource

                    $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name id -value $selectedResource.id
                    $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name name -value $selectedResource.name
                }
            }
        }

        if ($includedResources.$propertyvalue.type -eq "Microsoft.CommonDataModel/environments/namespaces/enumerations" -or $includedResources.$propertyvalue.type -eq "Microsoft.CommonDataModel/environments/namespaces/entities")
        { 
            if ($includedResources.$propertyvalue.configurableBy -eq "User")
            {
                if($DefaultToExportSuggestions -and ($includedResources.$propertyvalue.suggestedCreationType -ne $null))
                {
                    $type = $includedResources.$propertyvalue.suggestedCreationType
                }
                else {
                    If($selectedCommonDataServiceOption -eq $null)
                    {
                        $result = Configure-CommonDataServiceResources
                        $selection = $result.selection

                        $selectedCommonDataServiceOption = $selection
                        $type = $selectedCommonDataServiceOption
                    }
                    else {
                        $type = $selectedCommonDataServiceOption
                    }
                }
            }
            # If it's a system entity/enum just default to the suggested creation type
            else {
                $type =  $includedResources.$propertyvalue.suggestedCreationType
            }
        }

        #Set the suggested Creation type & selected creation type for the resource
        If($type)
        {    
            
            If($includedResources.$propertyvalue.suggestedCreationType)
            {
                $includedResources.$propertyvalue.suggestedCreationType = $type
            }
            else
            {
                $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name suggestedCreationType -value $type
            }
            
            $includedResources.$propertyvalue | Add-Member -MemberType NoteProperty -name selectedCreationType -value $type
        }
    }
    
    # Write-Host "Found $numResources dependent resources..."

    $responseObject = @{
        resources = $includedResources
        resourceIds = $includedResourceIds
        suggestedResourceIds = $includedSuggestedResourceIds
    } 

    return $responseObject
}


function Upload-FileToBlogStorage(
    [string] $EnvironmentName,
    [string] $FilePath,
    [string] $ApiVersion = "2016-11-01"
)
{
    # Write-Host "Reading file..."
    
    try {
        #Read the import package file
        $fileBinary = [IO.File]::ReadAllBytes($FilePath);
        $encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1");
        $file = $encoding.GetString($fileBinary)
    } catch {
        Write-Host "Failed to read the file"
        throw
    }

    # Write-Host "Finding file upload location..."

    #Find a location to upload the package to
    $generateResourceStorageUrl = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/" + $EnvironmentName + "/generateResourceStorage`?api-version=" + $ApiVersion

    #Retrieve the Blob storage Uri
    $generateResourceStorageResponse = Invoke-Request -Uri $generateResourceStorageUrl -Method POST -ParseContent -ThrowOnFailure
    $originalBlobUri = $generateResourceStorageResponse.sharedAccessSignature
    
    $uri = [System.Uri] $originalBlobUri 
    $filename = "filename.zip"
    $uriHost = $uri.Host
    $uriPath = $uri.AbsolutePath
    $uriQuery = $uri.Query
    
    #Generate the blob Uris to upload the package
    $tempBlobUri = "https://$uriHost$uriPath/$fileName$uriQuery"
    $commitBlobUri =  "$tempBlobUri&comp=blocklist"
    $uploadBlobUri = "$tempBlobUri&comp=block"

    #generate Azure Blob storage block id and append it to your upload Uri
    $BlockId = "BlockId"
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($BlockId)
    $EncodedBlockId =[Convert]::ToBase64String($Bytes)
    $uploadBlobUri =  "$uploadBlobUri&blockid=$EncodedBlockId"

    # Write-Host "Uploading file to blob storage..."

    try {
        #call storage to upload the blob
        $uploadFiletoBLog = Invoke-WebRequest -Uri $uploadBlobUri -Method Put -ContentType "application/json" -Body $file -UseBasicParsing
    
        #Call Storage to commit the blob
        $commitBody = "<?xml version=`"1.0`" encoding=`"utf-8`"?><BlockList><Latest>$EncodedBlockId</Latest></BlockList>"
        $commitFiletoBLog = Invoke-WebRequest -Uri $commitBlobUri -Method Put -ContentType "application/json" -Body $commitBody -UseBasicParsing
    } catch {
        Write-Host "Failed to upload the file to blob storage"
        throw
    }

    return $tempBlobUri
}

function Get-ImportPackageResources(
    [string] $EnvironmentName,
    [string] $ImportPackageBlobUri,
    [string] $ApiVersion = "2016-11-01"
)
{
    #Call list package resources for the app
    $listParametersUri = "https://management.azure.com/providers/Microsoft.BusinessAppPlatform/environments/" + $EnvironmentName + "/listImportParameters`?api-version=" + $ApiVersion

    #Generate the request body
    $listParametersBody = @{ 
        packageLink = @{
            value = $ImportPackageBlobUri
        } 
    }

    #Write-Host "Listing the package resources..."

    $listParametersResponse = Invoke-Request -Uri $listParametersUri -Method POST -Body $listParametersBody -ThrowOnFailure
    $statusUri= $listParametersResponse.Headers['Location']

    #Wait until the package has been generated
    while($listParametersResponse.StatusCode -ne 200) 
    {
        Start-Sleep -s 5
        $listParametersResponse = Invoke-Request -Uri $statusUri -Method GET -ThrowOnFailure
    }

    #Parse the request content
    $parsedListParametersResponse = ConvertFrom-Json $listParametersResponse.Content
    
    return $parsedListParametersResponse
}


function Configure-CommonDataServiceResources(
)
{
    $title="Your package contains one or more Common Data Service resourses. Choose the import setup option for these resources."

    $menu="
    1 Merge - If there's an entity or picklist with the same name, new fields or entries will be added, but missing fields or entries won’t be removed. If there’s no matching entity or picklist, a new resource will be created.
    2 Overwrite - If there's a resource with the same name, this import will replace it. If there isn’t a matching resource, a new resource will be created. Applies to entities, picklists, roles, and permission sets.`n"
    #Q Quit"

    Do {
        #use a Switch construct to take action depending on what menu choice
        #is selected.
        Switch (Invoke-Menu -menu $menu -title $title) {
            "1"
            {
                $response = @{
                    selection = "Merge"
                }
                return $response
            } 
            "2" 
            {
                #Write-Host "Overwrite"    
                
                $response = @{
                    selection = "Overwrite"
                }
                return $response
            }
            Default 
            {
                Write-Warning "Invalid Choice. Try again."
                sleep -milliseconds 100
            }
        } #switch
    } While ($True)
}

function Configure-ConnectorResource(
    [ValidateNotNullOrEmpty()]
    $EnvironmentName,
    [ValidateNotNullOrEmpty()]
    $EnvironmentDisplayName,
    [ValidateNotNullOrEmpty()]
    $ConnectorResourceObject,
    $PreselectedOption
)
{
    $resourceDisplayName = $ConnectorResourceObject.details.displayName
    $resourceType = $ConnectorResourceObject.type

    $selection = $null

    If($PreselectedOption -ne $null)
    {
        Write-Host "Selecting the default option of '$PreselectedOption' for the resource named '$resourceDisplayName' with a resource type of '$resourceType'"                
        
        $selection = $PreselectedOption
    }
    else {

        $title="Choose the import setup option for the connection resource named $resourceDisplayName with a connector type of $resourceType"
        
        $menu="
        1 Existing - The connection or custom API already exists in the environment and must be selected when this package is imported.`n"
        #Q Quit"
    
        
        Do {
            #use a Switch construct to take action depending on what menu choice
            #is selected.
            Switch (Invoke-Menu -menu $menu -title $title) {
                "1"
                {
                    $selection = "Existing"
                } 
                Default 
                {
                    Write-Warning "Invalid Choice. Try again."
                    sleep -milliseconds 100
                }
            } #switch
        } While ($selection -eq $null)
    }


    Switch ($selection) {
        "Existing" 
        {
            #Write-Host "Existing" 
            $connectors = Get-Connectors -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion -FilterSharedConnectors $true
            
            if(($connectors.value).Count -eq 0)
            {
                Write-Host "There are were no resources found of resource type '$resourceType', please create one or select another setup option for this resource."
                return Configure-ConnectorResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -ConnectorResourceObject $ConnectorResourceObject
            }
            
            $result = Select-ExistingResource -EnvironmentDisplayName $EnvironmentDisplayName -ResourceTable $connectors.value -ResourceName connector

            If($result -eq "User quit")
            {
                return Configure-ConnectorResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -ConnectorResourceObject $ConnectorResourceObject
            }
    
            $response = @{
                selection = "Existing"
                selectedResource = $result
            }

            return $response   
        }
    } #switch
}

function Configure-ConnectionResource(
    [ValidateNotNullOrEmpty()]
    $EnvironmentName,
    [ValidateNotNullOrEmpty()]
    $EnvironmentDisplayName,
    [ValidateNotNullOrEmpty()]
    $ConnectionResourceObject,
    $ParentResource,
    $PreselectedOption,
    [bool] $AutoSelectDataSourcesOnImport = $false
)
{
    $resourceDisplayName = $ConnectionResourceObject.details.displayName
    $resourceType = $ConnectionResourceObject.type

    if($ParentResource -eq $null)
    {
        $resourceId = $ConnectionResourceObject.suggestedId

        #get the connector provider name for this connection
        $searchString = "/connections"
        $searchIndex = $resourceId.IndexOf($searchString)
        $providerName = $resourceId.SubString(0, $searchIndex)
    }
    else {
        $providerName = "/providers/Microsoft.PowerApps/apis/" + $ParentResource.name
    }

    $selection = $null

    If($PreselectedOption -ne $null)
    {
        Write-Host "Selecting the default option of '$PreselectedOption' for the resource named '$resourceDisplayName' with a resource type of '$resourceType'"                
        
        $selection = $PreselectedOption
    }
    else {

        $title="Choose the import setup option for the connection resource named $resourceDisplayName with a connector type of $providerName"
        
        $menu="
        1 Existing - The connection or custom API already exists in the environment and must be selected when this package is imported.
        2 New - Create a new connection.`n"
    
        
        Do {
            #use a Switch construct to take action depending on what menu choice
            #is selected.
            Switch (Invoke-Menu -menu $menu -title $title) {
                "1"
                {
                    $selection = "Existing"
                } 
                "2"
                {
                    $selection = "New"
                } 
                Default 
                {
                    Write-Warning "Invalid Choice. Try again."
                    sleep -milliseconds 100
                }
            } #switch
        } While ($selection -eq $null)
    }


    Switch ($selection) {
        "Existing" 
        {
            $connections = Get-Connections -EnvironmentName $environmentName -ReturnFlowConnections $false -ApiIdFilter $providerName
            
            #if(($connections.value).Count -eq 0)
            if(($connections).Count -eq 0)
            {
                Write-Host "There are no resources found of resource type '$resourceType', please create one or select another setup option for this resource."
                return Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -ConnectionResourceObject $ConnectionResourceObject -ParentResource $ParentResource
            }
            elseif($AutoSelectDataSourcesOnImport)
            {
                #just choose the first one in the auto-install case
                $result = $connections[0];
            }
            else {            
                $result = Select-ExistingResource -EnvironmentDisplayName $EnvironmentDisplayName -ResourceTable $connections -ResourceName connection
            }

            If($result -eq "User quit")
            {
                return Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -ConnectionResourceObject $ConnectionResourceObject -ParentResource $ParentResource
            }

            $response = @{
                selection = "Existing"
                selectedResource = $result
            }

            return $response  
        }
        "New"
        {
            $connection = Create-Connection -EnvironmentName $environmentName -ConnectorName $providerName

            If(($connection -eq $null) -or ($connection -eq ""))
            {
                Write-Host "Connection creation failed"
                return Configure-ConnectionResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -ConnectionResourceObject $ConnectionResourceObject -ParentResource $ParentResource
            }

            $entry = @{
                name = $connection.name
                id = $connection.id
                displayName = $connection.properties.displayName
            } 

            $response = @{
                selection = "Existing"
                selectedResource = $entry
            }
            return $response
        }
    } 
}

function Configure-AppResource(
    [ValidateNotNullOrEmpty()]
    $EnvironmentName,
    [ValidateNotNullOrEmpty()]
    $EnvironmentDisplayName,
    [ValidateNotNullOrEmpty()]
    $AppResourceObject,
    $PreselectedOption
)
{   
    $resourceDisplayName = $AppResourceObject.details.displayName
    $resourceType = $AppResourceObject.type

    $selection = $null

    If($PreselectedOption -ne $null)
    {
        Write-Host "Selecting the default option of '$PreselectedOption' for the resource named '$resourceDisplayName' with a resource type of '$resourceType'"                
        
        $selection = $PreselectedOption
    }
    else {
        $title="Choose the import setup option for the resource named $resourceDisplayName with a resource type of $resourceType"

        $menu="
        1 New - This app will be new to the environment when the package is imported.
        2 Update - The app already exists in the environment and will be updated when this package is imported.`n"
        #Q Quit"
        
        Do {
            #use a Switch construct to take action depending on what menu choice
            #is selected.
            Switch (Invoke-Menu -menu $menu -title $title) {
                "1"
                {
                    $selection = "New"
                } 
                "2" 
                {  
                    $selection = "Update"
                }
                Default 
                {
                    Write-Warning "Invalid Choice. Try again."
                    sleep -milliseconds 100
                }
            } #switch
        } While ($selection -eq $null)
    }

    Switch ($selection) {
        "New"
        {
            $result = Read-Host -Prompt "Enter the display name for this new resource.  The current resource display name is '$resourceDisplayName'"

            $response = @{
                selection = "New"
                displayName = $result
            }
            return $response
        }
        "Update"
        {
            $pageSize = 250
            $appsResponse = Get-Apps -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion -top $pageSize

            if($appsResponse.name -eq $null)
            {
                if(($appsResponse.value).Count -eq 0)
                {
                    Write-Host "There were no resources found of resource type '$resourceType', please create one or select another setup option for this resource."
                    return Configure-AppResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -AppResourceObject $AppResourceObject
                }
            }
            
            $result = Select-ExistingResource -EnvironmentDisplayName $EnvironmentDisplayName -ResourceTable $appsResponse -ResourceName app

            If($result -eq "User quit")
            {
                return Configure-AppResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -AppResourceObject $AppResourceObject
            }

            $response = @{
                selection = "Update"
                selectedResource = $result
            }

            return $response   
        }
    }
}

function Configure-FlowResource(
    [ValidateNotNullOrEmpty()]
    $EnvironmentName,
    [ValidateNotNullOrEmpty()]
    $EnvironmentDisplayName,
    [ValidateNotNullOrEmpty()]
    $FlowResourceObject,
    $PreselectedOption
)
{
    $resourceDisplayName = $FlowResourceObject.details.displayName
    $resourceType = $FlowResourceObject.type

    $selection = $null

    If($PreselectedOption -ne $null)
    {
        Write-Host "Selecting the default option of '$PreselectedOption' for the resource named '$resourceDisplayName' with a resource type of '$resourceType'"                
        
        $selection = $PreselectedOption
    }
    else {
        
        $title="Choose the import setup option for the resource named '$resourceDisplayName' with a resource type of '$resourceType'"

        $menu="
        1 New - This flow will be new to the environment when the package is imported.
        2 Update - The flow already exists in the environment and will be updated when this package is imported.`n"
        #Q Quit"

        Do {
            #use a Switch construct to take action depending on what menu choice
            #is selected.
            Switch (Invoke-Menu -menu $menu -title $title) {
                "1"
                {
                    $selection = "New"
                } 
                "2" 
                {  
                    $selection = "Update"
                }
                Default 
                {
                    Write-Warning "Invalid Choice. Try again."
                    sleep -milliseconds 100
                }
            } #switch
        } While ($selection -eq $null)
    }

    Switch ($selection) {
        "New"
        {
            $result = Read-Host -Prompt "Enter the display name for this new resource.  The current resource display name is '$resourceDisplayName'"

            $response = @{
                selection = "New"
                displayName = $result
            }
            return $response
        } 
        "Update" 
        { 
            $pageSize = 25
            $flowsResponse = Get-Flows -EnvironmentName $EnvironmentName -ApiVersion $ApiVersion -top $pageSize
            
            if($flowsResponse.name -eq $null)
            {
                if(($flowsResponse.value).Count -eq 0)
                {
                    Write-Host "There were no resources found of resource type '$resourceType', please create one or select another setup option for this resource."
                    return Configure-FlowResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -FlowResourceObject $FlowResourceObject 
                }
            }
            
            $result = Select-ExistingResource -EnvironmentDisplayName $EnvironmentDisplayName -ResourceTable $flowsResponse -ResourceName flow

            If($result -eq "User quit")
            {
                return Configure-FlowResource -EnvironmentName $EnvironmentName -EnvironmentDisplayName $EnvironmentDisplayName -FlowResourceObject $FlowResourceObject 
            }

            $response = @{
                selection = "Update"
                selectedResource = $result
            }

            return $response  
        }
        Default 
        {
            Write-Warning "Invalid Choice. Try again."
            sleep -milliseconds 100
        }
    } 
}

function Select-Environment(
    [string] $ApiVersion = "2016-11-01",
    [string] $MenuTitle = ""
)
{
    $env = Get-AdminPowerAppEnvironment -ApiVersion $ApiVersion

    if($env.id -ne $null)
    {
        $env = @{
            value = $env
        }
    }
    elseif(($env.value).Count -eq 0)
    {
        Write-Host "There were no environments found for this user."
        throw
    }

    $title = $null
    If ($MenuTitle -eq "")
    {
        $title = "There were environments found. Please select one."
    }
    else {
        $title = $MenuTitle
    }

    $resources=@()
    $menu=""

    foreach( $resource in $env.value)
    {
        $index = $resources.Length
        $entry = $resource
        $resources += $entry
        $menu += "$index " + $entry.properties.displayName + " with id " + $entry.id + "`n"
    }

    $menu += "B Back`n"

    Do {
        $result = Invoke-Menu -menu $menu -title $title
        If($result -eq "B" -or $result -eq "b")
        {
            return "User quit"
        }

        $index = [int] $result
        
        If($index -ge $resources.Length -or $index -eq $null)
        {
            Write-Warning "Invalid Choice. Try again."
            continue
        }

        $selectedEntry = $resources[$index]

        Return $selectedEntry

    } While ($True)
}

function Select-ExistingResource(
    [ValidateNotNullOrEmpty()]
    $EnvironmentDisplayName,
    [ValidateNotNullOrEmpty()]
    $ResourceTable,
    [ValidateSet("app", "flow", "connector", "connection")]
    $ResourceName
)
{
    $title = "There are $ResourceName" + "s in environment '$EnvironmentDisplayName.' Please select one"

    $resources=@()
    $menu=""

    foreach( $resource in $ResourceTable)
    {
        $index = $resources.Length
        $entry = @{
            name = $resource.name
            id = $resource.id
            displayName = $resource.properties.displayName
        } 
        $resources += $entry
        $menu += "$index " + $entry.displayName + " with id " + $entry.id + "`n"
    }

    $menu += "B Back`n"
    Do {
        
        $result = Invoke-Menu -menu $menu -title $title

        If($result -eq "B" -or $result -eq "b")
        {
            return "User quit"
        }
        
        $index = [int] $result

        If($index -ge $resources.Length -or $index -eq $null -or (0..10000) -notcontains $index)
        {
            Write-Warning "Invalid Choice. Try again."
            continue
        }

        $selectedEntry = $resources[$index]

        return $selectedEntry

    } While ($True)
}

Function Invoke-Menu {
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter your menu text")]
        [ValidateNotNullOrEmpty()]
        [string]$Menu,
        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$Title = "My Menu",
        [Alias("cls")]
        [switch]$ClearScreen
    )
     
    #clear the screen if requested
    if ($ClearScreen) { 
     Clear-Host 
    }
     
    #build the menu prompt
    $menuPrompt="`n"
    $menuPrompt+=$title
    #add a return
    $menuprompt+="`n"
    #add an underline
    $menuprompt+="-"*$title.Length
    #add another return
    $menuprompt+="`n"
    #add the menu
    $menuPrompt+=$menu
     
    Read-Host -Prompt $menuprompt
     
} #end function


#Returns connections for a given user in the specified environment
function Get-Connections(
    [string]$EnvironmentName = $null,
    [string]$ApiVersion = "2016-11-01",
    [bool]$ReturnFlowConnections = $false,
    [string]$ApiIdFilter
)
{
    if ($ApiVersion -eq $null -or $ApiVersion -eq "")
    {
        Write-Error "Api Version must be set."
        throw
    }

    $getConnectionsUri = "https://management.azure.com/providers/Microsoft.PowerApps/connections`?api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27" 
    
    $getConnectionsResponse = Invoke-Request -Uri $getConnectionsUri -Method GET -ParseContent -ThrowOnFailure
    
    if($ReturnFlowConnections)
    {
        return $getConnectionsResponse.value
    }

    $filteredConnectionList = @()
    
    foreach($connection in $getConnectionsResponse.value) {
        if(-not ($connection.properties.apiId -eq "/providers/Microsoft.PowerApps/apis/shared_logicflows"))
        {
            if( -not ($ApiIdFilter -eq "" -or $ApiIdFilter -eq $null))
            {
                # Write-Host $ApiIdFilter " ----- " $connection.properties.apiId 
                # Write-Host ($connection.properties.apiId -match $ApiIdFilter)
                if($connection.properties.apiId -match $ApiIdFilter)
                {
                    $filteredConnectionList = $filteredConnectionList + $connection   
                }    
            }
            else 
            {
                $filteredConnectionList = $filteredConnectionList + $connection                
            }
        }
    }

    #$filteredResponse = @{
    #    value = $filteredConnectionList
    #}

    return $filteredConnectionList
}

#Returns connectors for a given user in the specified environment
function Get-Connectors(
    [string]$EnvironmentName = $null,
    [string]$ApiVersion = "2017-06-01",
    [bool]$FilterSharedConnectors
)
{
    if ($ApiVersion -eq $null -or $ApiVersion -eq "")
    {
        Write-Error "Api Version must be set."
        throw
    }

    $getConnectorsUri = "https://management.azure.com/providers/Microsoft.PowerApps/apis`?showApisWithToS=true&api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27"
    
    $getConnectorsResponse = Invoke-Request -Uri $getConnectorsUri -Method GET -ParseContent -ThrowOnFailure

    if(($FilterSharedConnectors -eq $null) -or (-not $FilterSharedConnectors))
    {
        return $getConnectorsResponse
    }

    $connectorArray = @()
    
    foreach($connector in $getConnectorsResponse.value) {
        $connectorSource = $connector.properties.metadata.source
    
        if($connectorSource -ne "marketplace" -and $connectorSource -ne $null)
        {
            $connectorArray += $connector
        }
    }
    
    $responseHash = @{
        value = $connectorArray
    }
    
    return $responseHash
}

#Returns connectors details for a given user in the specified environment
function Get-ConnectorDetails(
    [string]$EnvironmentName = $null,
    [string]$ConnectorName = $null,
    [string]$ApiVersion = "2016-11-01"
)
{
    if ($ApiVersion -eq $null -or $ApiVersion -eq "")
    {
        Write-Error "Api Version must be set."
        throw
    }

    $getConnectorUri = "https://management.azure.com$ConnectorName`?api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27"
    
    return Invoke-Request -Uri $getConnectorUri -Method GET -ParseContent -ThrowOnFailure
}

#Creates a connection, but does not authorize the connection (if the connector is Oauth)
function Create-Connection(
    [string]$EnvironmentName = $null,
    [string]$ConnectorName = $null,
    [string]$ApiVersion = "2016-11-01",
    $ConnectorParameters = @{}
)
{   
    if ($ApiVersion -eq $null -or $ApiVersion -eq "")
    {
        Write-Error "Api Version must be set."
        throw
    }
    
    $newGuid = [System.Guid]::NewGuid().Guid
    $newId = $newGuid -replace '-'

    $createConnectionUri = "https://management.azure.com$ConnectorName/connections/$newId`?api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27"
    $createConnectionBody = @{
        properties = @{
            connectionParameters = $ConnectorParameters
            environment = @{
                id = "/providers/Microsoft.PowerApps/environments/$EnvironmentName"
                name = $EnvironmentName
            }
        }
    }
    
    $createConnectionResponse = Invoke-Request -Uri $createConnectionUri -Body $createConnectionBody -Method PUT -ParseContent -ThrowOnFailure

    $requiresAuthentication = $false

    If(-not ($createConnectionResponse.properties.statuses -eq $null)) 
    {
        foreach($status in $createConnectionResponse.properties.statuses) 
        {
            if($status.status -eq "Error") 
            {
                if($status.error.code -eq "Unauthenticated")
                {
                    $requiresAuthentication = $true
                }
            }
        }
        
    }

    if(-not $requiresAuthentication)
    {
        return $createConnectionResponse
    }

    $newGuid = [System.Guid]::NewGuid().Guid

    $getConsentLinkUri = "https://management.azure.com$ConnectorName/connections/$newId/getConsentLink`?api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27"
    $getConsentLinkBody = @{
        redirectUrl = "https://web.powerapps.com/oauth/redirect?oauthPopupId=$newGuid"
    }

    $getConsentLinkResponse = Invoke-Request -Uri $getConsentLinkUri -Body $getConsentLinkBody -Method POST -ParseContent -ThrowOnFailure
    $consentLink = $getConsentLinkResponse.consentLink

    $consentCode = Invoke-OAuthDialogJames -ConsentLinkUri $consentLink
    if(-not $consentCode)
    {
        return
    }
    
    $confirmConsentCodeUri = "https://management.azure.com$ConnectorName/connections/$newId/confirmConsentCode?api-version=$ApiVersion&`$filter=environment%20eq%20%27$EnvironmentName%27"
    $confirmConsentCodeBody = @{
        code = $consentCode
    }

    $confirmConsentResponse = Invoke-Request -Uri $confirmConsentCodeUri -Body $confirmConsentCodeBody -Method POST -ParseContent -ThrowOnFailure

    return $createConnectionResponse
}