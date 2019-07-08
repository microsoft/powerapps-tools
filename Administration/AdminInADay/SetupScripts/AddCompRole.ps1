
$Tenant = 'm365x452945'
$userprefix ='labadmin*'


   Set-ExecutionPolicy RemoteSigned
   
   $UserCredential = Get-Credential

   $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

   Import-PSSession $Session -DisableNameChecking -AllowClobber

   Install-Module -Name MSOnline -Scope CurrentUser
   
   Import-Module MSOnline

   Connect-MsolService -Credential $UserCredential

   
   $users = Get-MsolUser | where {$_.UserPrincipalName -like $userprefix} | Sort-Object UserPrincipalName


    ForEach ($user in $users) { 
    

    Add-RoleGroupMember “Compliance Management” -Member  $user.UserPrincipalName.Split('@')[0]

        
        }

    Remove-PSSession $Session