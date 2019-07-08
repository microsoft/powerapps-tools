   $Tenant = "M365x452945"
   $DomainName ="M365x452945.onmicrosoft.com"
   $TenantRegion = "CA"
   $password = "test@word1"

   #change if you want to use a different type of license for employee all that is required is p1
   $labemployeelicense =":POWERFLOW_P1"
   #$labemployeelicense =":POWERFLOW_P2"
   
   $UserCredential = Get-Credential   

   Install-Module -Name MSOnline -Scope CurrentUser
   
   Import-Module MSOnline

   Connect-MsolService -Credential $UserCredential

   install-module azuread
   import-module azuread

   Connect-AzureAD -Credential $UserCredential

   
   $firstname = "Service"
   $lastname = "Account"
   $displayname = "Service Account"
   $email = ("serviceaccount"+ "@" + $DomainName).ToLower()
       
         
   New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $Tenant":POWERFLOW_P2" -PasswordNeverExpires $true -ForceChangePassword $false  
 
   Set-MsolUserLicense -UserPrincipalName $email -AddLicenses $Tenant":ENTERPRISEPREMIUM" -Verbose
   


   $firstname = "Lab"
   $lastname = "Back Office"
   $displayname = "Lab Back Office"
   $email = ("labbackoffice"+ "@" + $DomainName).ToLower()
       
         
   New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $Tenant":POWERFLOW_P2" -PasswordNeverExpires $true -ForceChangePassword $false  
 
   $firstname = "Lab"
   $lastname = "Employee" 
   $displayname = "Lab Employee"
   $email = ("labemployee" + "@" + $DomainName).ToLower()
      
   $license = $Tenant+$labemployeelicense         
   New-MsolUser -DisplayName $displayname -FirstName $firstname -LastName $lastname -UserPrincipalName $email -UsageLocation $TenantRegion -Password $password -LicenseAssignment $license -PasswordNeverExpires $true -ForceChangePassword $false  
  


   $appGroup = New-AzureADGroup -Description "Device Ordering App Users" -DisplayName "Device Ordering App " -MailEnabled $false -SecurityEnabled $true -MailNickName "DeviceOrderingUsers"

   
   $users = Get-MsolUser | where {$_.UserPrincipalName -like 'labemployee*'} | Sort-Object UserPrincipalName


    ForEach ($user in $users) { 

        write-host "adding user "  $user.UserPrincipalName  " to group " + $appGroup.DisplayName

        Add-AzureADGroupMember -ObjectId $appGroup.ObjectId -RefObjectId $user.ObjectId

        
    }

   $mdGroup = New-AzureADGroup -Description "Backoffice Users" -DisplayName "Device Procurement App " -MailEnabled $false -SecurityEnabled $true -MailNickName "DeviceProcurement"

   
   $users = Get-MsolUser | where {$_.UserPrincipalName -like 'labbackoffice*'} | Sort-Object UserPrincipalName


    ForEach ($user in $users) { 

        write-host "adding user "  $user.UserPrincipalName  " to group " + $mdGroup.DisplayName

        Add-AzureADGroupMember -ObjectId $mdGroup.ObjectId -RefObjectId $user.ObjectId

        
    }