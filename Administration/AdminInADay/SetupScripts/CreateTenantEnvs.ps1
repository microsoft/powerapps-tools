
$CDSlocation = "canada"
#all three users can be the same if you have limit raised by support otherwise must be 3 diff accounts
$firstadminuser = "admin@M365x452945.onmicrosoft.com"
$firstadminpassword = "test@word1"
$secondadminuser = "admin1@M365x452945.onmicrosoft.com"
$secondadminpassword = "test@word1"
$thirdadminuser = "admin2@M365x452945.onmicrosoft.com"
$thirdadminpassword = "test@word1"

Import-Module Microsoft.PowerShell.Utility

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force 
Install-Module -Name Microsoft.PowerApps.PowerShell  -Scope CurrentUser -AllowClobber -Force 

$securepassword = ConvertTo-SecureString -String $firstadminpassword -AsPlainText -Force
Add-PowerAppsAccount -Username $firstadminuser -Password $securepassword -Verbose
               
$envDev = New-AdminPowerAppEnvironment -DisplayName  "Device Ordering Development" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Power Platform COE" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$securepassword = ConvertTo-SecureString -String $secondadminpassword -AsPlainText -Force
Add-PowerAppsAccount -Username $secondadminuser -Password $securepassword -Verbose

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Thrive Hr - Prod" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Thrive Hr - Dev" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$securepassword = ConvertTo-SecureString -String $thirdadminpassword -AsPlainText -Force
Add-PowerAppsAccount -Username $thirdadminuser -Password $securepassword -Verbose

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Thrive Hr - UAT" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Thrive Hr - Test" -LocationName $CDSlocation -EnvironmentSku Production -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

$envDev = New-AdminPowerAppEnvironment -DisplayName  "My Sandbox" -LocationName $CDSlocation -EnvironmentSku Trial -Verbose

$envDev = New-AdminPowerAppEnvironment -DisplayName  "Trying CDS" -LocationName $CDSlocation -EnvironmentSku Trial -Verbose
New-AdminPowerAppCdsDatabase -EnvironmentName  $envDev.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false

