#Create-CDSUsers -Tenant ig18a -Count 2 -TenantRegion US -password "Air@lift19" -userprefix "labadmin"

Set-PSRepository PSGallery -InstallationPolicy Trusted
#Install-Module Microsoft.Xrm.OnlineManagementAPI -Scope CurrentUser


Install-Module -Name MSOnline -Scope CurrentUser
Import-Module MSOnline

$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential

function Create-CDSUsers
{
   param
    (
    [Parameter(Mandatory = $true)]
    [string]$Tenant,
    [Parameter(Mandatory = $true)]
    [int]$Count,
    [Parameter(Mandatory = $false)]
    [string]$TenantRegion="GB",
    [Parameter(Mandatory = $false)]
    [string]$password=$UserPassword,
     [Parameter(Mandatory = $false)]
    [string]$userprefix="labadmin"
    )

    $DomainName = $Tenant+".onmicrosoft.com"


    
    Write-Host "Tenant: " $Tenant
    Write-Host "Domain Name: " $DomainName
    Write-Host "Count: " $Count
    Write-Host "Licence Plans: " (Get-MsolAccountSku).AccountSkuId
    Write-Host "TenantRegion: " $TenantRegion
    Write-Host "CDSlocation: " $CDSlocation
    Write-Host "password: " $password

  
    $securepassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    
 
       Write-Host "creating users " -ForegroundColor Green
   
       for ($i=1;$i -lt $Count+1; $i++) {
       


        $firstname = "Lab"
        $lastname = "Admin" + $i
        $displayname = "Lab Admin " + $i
        $email = ($userprefix + $i + "@" + $DomainName).ToLower()
       
         
         New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $Tenant":DYN365_ENTERPRISE_PLAN1" -PasswordNeverExpires $true -ForceChangePassword $false  
         
         Set-MsolUserLicense -UserPrincipalName $email -AddLicenses $Tenant":ENTERPRISEPREMIUM" -Verbose

#         Add-RoleGroupMember “Compliance Management” -Member  $email

      #  $firstname = "Lab"
      #  $lastname = "Back Office" + $i
      #  $displayname = "Lab Back Office " + $i
      #  $email = ("labbackoffice" + $i + "@" + $DomainName).ToLower()
       
         
      #   New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $Tenant":POWERFLOW_P2" -PasswordNeverExpires $true -ForceChangePassword $false  
  
     #   $firstname = "Lab"
      #  $lastname = "Employee" + $i
      #  $displayname = "Lab Employee " + $i
      #  $email = ("labemployee" + $i + "@" + $DomainName).ToLower()
       
         
      #   New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $Tenant":POWERFLOW_P1" -PasswordNeverExpires $true -ForceChangePassword $false  
  
         
        }
        Write-Host "*****************Lab Users Created ***************" -ForegroundColor Green
        Get-MsolUser | where {$_.UserPrincipalName -like 'labadmin*'}|fl displayname,licenses

}