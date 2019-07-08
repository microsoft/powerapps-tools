
#Setup
Import-Module .\ImportExport.psm1 -Force
Import-Module .\PowerApps-RestClientModule.psm1 -Force
Import-Module .\PowerApps-AuthModule.psm1 
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.dll
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll
Import-Module .\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll
Import-Module .\Microsoft.PowerApps.Administration.PowerShell.psm1 -Force

#sign-in
#Add-PowerAppsAccount

$pass = ConvertTo-SecureString "password" -AsPlainText -Force
Add-PowerAppsAccount -Username "username" -Password $pass

$ApiVersion = "2016-11-01"

#----------------------Export the flow---------------------------------#
Write-Host "Select source environment for exporting a flow"
$environmentDisplayName = "Ignite Demo UAT"
$sourceEnvironment = Get-AdminPowerAppEnvironment "*$environmentDisplayName*"
$sourceEnvironmentName = $sourceEnvironment.EnvironmentName

Write-Host "Select the flow you want to export"
$flowDisplayName = "Send out my meeting notes"
$flow = $sourceEnvironment | Get-AdminFlow "*$flowDisplayName*"
$flowId = $flow.FlowName

#$exportZipFilePath = "C:\Users\jamesol\Desktop\PowerShell\Ignite\Output\exportPackage.zip"
$exportZipFilePath = ($pwd).path + "\flowExportPackage.zip"

$packageName = "Package name here"
$packageDescription = "Package description here"
$creatorName = "Creator name here"

Write-Host "------------------------Exporting the flow------------------------"
$exportFlowResponse = Export-ResourcePackage -ResourceType flow -ResourceName $flowId -SourceEnvironmentName $sourceEnvironmentName -PackageName $packageName -PackageDescription $packageDescription -CreatorName $creatorName -ExportZipFilePath $exportZipFilePath -ApiVersion $ApiVersion

Write-Host "Export complete"

#----------------------Export the app---------------------------------#
Write-Host "Select source environment for exporting a app"
$environmentDisplayName = "Ignite Demo UAT"
$sourceEnvironment = Get-AdminPowerAppEnvironment "*$environmentDisplayName*"
$sourceEnvironmentName = $sourceEnvironment.EnvironmentName

Write-Host "Select the app you want to export"
$appDisplayName = "Source app"
$app = $sourceEnvironment | Get-AdminPowerApp "*$appDisplayName*"
$appId = $app.AppName

#$exportZipFilePath = "C:\Users\jamesol\Desktop\PowerShell\Ignite\Output\exportPackage.zip"
$exportZipFilePath = ($pwd).path + "\appExportPackage.zip"

$packageName = "Package name here"
$packageDescription = "Package description here"
$creatorName = "Creator name here"

Write-Host "------------------------Exporting the app------------------------"
$exportAppResponse = Export-ResourcePackage -ResourceType app -ResourceName $appId -SourceEnvironmentName $sourceEnvironmentName -PackageName $packageName -PackageDescription $packageDescription -CreatorName $creatorName -ExportZipFilePath $exportZipFilePath -ApiVersion $ApiVersion

Write-Host "Export complete"
