
#Setup
Import-Module .\ImportExport.psm1 -Force
Import-Module .\PowerApps-RestClientModule.psm1 -Force
Import-Module .\PowerApps-AuthModule.psm1 
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.dll
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll
Import-Module .\Microsoft.PowerApps.Administration.PowerShell.psm1 -Force


$pass = ConvertTo-SecureString "test@word1" -AsPlainText -Force
Add-PowerAppsAccount -Username "admin@admininadaytest.onmicrosoft.com" -Password $pass


$ApiVersion = "2016-11-01"

# #----------------------Import the flow---------------------------------#

Write-Host "Select target environment for importing your flow package"

$environmentDisplayName = "Admin In A Day (default)"
$targetEnvironment = Get-AdminPowerAppEnvironment "*$environmentDisplayName*"
$targetEnvironmentName = $targetEnvironment.EnvironmentName


$importPackageFilePath = ($pwd).path + "\flowExportPackage.zip"

Write-Host "------------------------Importing the flow------------------------"

$flowNames = Get-Content -Path .\FlowNames.txt
foreach($fname in $flowNames)
{
    Write-Host "Creating " $fname
    $resourceName = $fname

    $importAppResponse = Import-Package -EnvironmentName $targetEnvironmentName -ApiVersion $ApiVersion -ImportPackageFilePath $importPackageFilePath -DefaultToExportSuggestions $true -AutoSelectDataSourcesOnImport $true -ResourceName $resourceName;

    Write-Host "Import complete"

    $flowName = $null
    foreach ($resource in Get-Member -InputObject $importAppResponse.properties.resources -MemberType NoteProperty)
    {
        $property = 'Name'
        $propertyvalue = $resource.$property

        if ($importAppResponse.properties.resources.$propertyvalue.type -eq "Microsoft.Flow/flows")
        {
            $flowName = $importAppResponse.properties.resources.$propertyvalue.name
        }
    }
    Write-Host "Found flow name = $flowName"
} 



#----------------------Import the app---------------------------------#

Write-Host "Select target environment for importing your app package"

#$environmentDisplayName = "Ignite Demo Production"
$targetEnvironment = Get-AdminPowerAppEnvironment "*$environmentDisplayName*"
$targetEnvironmentName = $targetEnvironment.EnvironmentName

$importPackageFilePath = ($pwd).path + "\appExportPackage.zip"

Write-Host "------------------------Importing the app------------------------"

$appNames = Get-Content -Path .\AppNames.txt
foreach($aName in $appNames)
{
    Write-Host $aName
    $resourceName = $aName

    $importAppResponse = Import-Package -EnvironmentName $targetEnvironmentName -ApiVersion $ApiVersion -ImportPackageFilePath $importPackageFilePath -DefaultToExportSuggestions $true -AutoSelectDataSourcesOnImport $true -ResourceName $resourceName;

        Write-Host "Import complete"

        $appName = $null
        foreach ($resource in Get-Member -InputObject $importAppResponse.properties.resources -MemberType NoteProperty)
        {
            $property = 'Name'
            $propertyvalue = $resource.$property
        
            if ($importAppResponse.properties.resources.$propertyvalue.type -eq "Microsoft.PowerApps/apps")
            {
                $appName = $importAppResponse.properties.resources.$propertyvalue.name
            }
        }
        Write-Host "Found $resourceName with an appid = $appName"
} 

