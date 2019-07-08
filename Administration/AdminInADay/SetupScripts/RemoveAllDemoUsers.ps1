Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Microsoft.Xrm.OnlineManagementAPI -Scope CurrentUser


Install-Module -Name MSOnline -Scope CurrentUser
Import-Module MSOnline

$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
function Delete-CDSUsers{

    #remove users
    Get-MsolUser | where {$_.UserPrincipalName -notlike 'admin*'}|Remove-MsolUser -Force

    Write-Host "*****************Old Users Deleted ***************" -ForegroundColor Green
    Get-MsolUser |fl displayname,licenses

}