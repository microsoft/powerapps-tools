

$userSuffix = "@admininadaytest.onmicrosoft.com"
$tenantName = "admininadaytest"
$connectionhost ="https://admin.services.crm3.dynamics.com"
$orgurl = "https://orgbbc3e925.crm3.dynamics.com"

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Microsoft.Xrm.OnlineManagementAPI -Scope CurrentUser

InstallTooling

Install-Module -Name MSOnline -Scope CurrentUser
Import-Module MSOnline
Import-Module Microsoft.Xrm.Data.Powershell


[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

$cred = Get-Credential

Connect-MsolService -Credential $cred


$role = 'System Administrator'

$cdsInstances = Get-CrmInstances -ApiUrl $connectionhost -Credential $cred 



    
     $conn = Connect-CrmOnline -Credential $cred -ServerUrl $orgurl
     $conn.IsReady,$conn.ConnectedOrgFriendlyName

   
   
    $users = Get-CrmRecords `
           -EntityLogicalName systemuser `
           -Fields domainname,systemuserid, fullname `
           -conn $conn

 $users = $users.CrmRecords | where {$_.domainname -like 'labadmin*'} | Sort-Object domainname


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

    



function InstallTooling
{

    $sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    $targetNugetExe = ".\nuget.exe"
    Remove-Item .\Tools -Force -Recurse -ErrorAction Ignore
    Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
    Set-Alias nuget $targetNugetExe -Scope Global -Verbose
    ##
    ##Download package deployer powershell
    ##
    ./nuget install  Microsoft.CrmSdk.XrmTooling.PackageDeployment.PowerShell -O .\Tools
    md .\Tools\Deployer
    $pdFolder = Get-ChildItem ./Tools | Where-Object {$_.Name -match 'Microsoft.CrmSdk.XrmTooling.PackageDeployment.PowerShell.'}
    move .\Tools\$pdFolder\tools\*.* .\Tools\Deployer
    Remove-Item .\Tools\$pdFolder -Force -Recurse
    # register XrmTooling modules
    cd .\tools\Deployer\
    .\RegisterXRMPackageDeployment.ps1
    cd ..\..\

}