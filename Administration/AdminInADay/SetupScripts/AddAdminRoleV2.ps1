
$userprefix = 'labadmin*'
$userSuffix = "@m365x452945.onmicrosoft.com"
$tenantName = "m365x452945"
$connectionhost ="https://admin.services.crm3.dynamics.com"
$orgurl = "https://orgbbc3e925.crm3.dynamics.com"

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Microsoft.Xrm.OnlineManagementAPI -Scope CurrentUser



Install-Module -Name MSOnline -Scope CurrentUser
Import-Module MSOnline

Install-Module -Name Microsoft.Xrm.Data.Powershell -Scope CurrentUser
Import-Module Microsoft.Xrm.Data.Powershell


[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$cred = Get-Credential

Connect-MsolService -Credential $cred


$role = 'System Administrator'

$conn = Connect-CrmOnline -Credential $cred -ServerUrl $orgurl
$conn.IsReady,$conn.ConnectedOrgFriendlyName

$cdsInstances = Get-CrmInstances -ApiUrl $connectionhost -Credential $cred 

#$envlist=Get-AdminPowerAppEnvironment | where {$_.EnvironmentType  -ne 'Default'} | where {$_.DisplayName -like '*Thrive*' -or $_.DisplayName -like '*My Sandbox*' -or $_.DisplayName -like '*Trying*' -or $_.DisplayName -like '*Device Ordering Development*' }
$envlist=$cdsInstances.Where({$_.EnvironmentType  -ne 'Default'}).Where({$_.FriendlyName -like '*Thrive*' -or $_.FriendlyName -like '*My Sandbox*' -or $_.FriendlyName -like '*Trying*' -or $_.FriendlyName -like '*Device Ordering Development*' -or $_.FriendlyName -like '*Power Platform COE*' })

Write-Host "Found " $envlist.length " environments to process"

    ForEach ($environemnt in $envlist) { 
     
     Write-Host "Processing environment :" $environemnt.FriendlyName


     $conn = Connect-CrmOnline -Credential $cred -ServerUrl $environemnt.ApplicationUrl
     $conn.IsReady,$conn.ConnectedOrgFriendlyName
    
   
    $users = Get-CrmRecords `
           -EntityLogicalName systemuser `
           -Fields domainname,systemuserid, fullname `
           -conn $conn

 $users = $users.CrmRecords | where {$_.domainname -like $userprefix} | Sort-Object domainname


    ForEach ($user in $users) { 

        write-host "adding user "  $user.domainname  " to group sysadmin"

            try
        {
            Add-CrmSecurityRoleToUser `
               -UserId $user.systemuserid `
               -SecurityRoleName $role `
               -conn $conn
 
         }
        Catch
        {
            $ErrorMessage = $_.Exception.Message        
            write-output $ErrorMessage
        
        }
   

        
        }

    
    }   




