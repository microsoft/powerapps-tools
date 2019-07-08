
  $groupid = "136ed9a0-17fc-4f31-9adb-c8b12eb45e23"
   
   $UserCredential = Get-Credential   

   Install-Module -Name MSOnline -Scope CurrentUser
   
   Import-Module MSOnline

   Connect-MsolService -Credential $UserCredential

   install-module azuread
   import-module azuread

   Connect-AzureAD -Credential $UserCredential

   

   
   $users = Get-MsolUser | where {$_.UserPrincipalName -like 'labadmin*'} | Sort-Object UserPrincipalName


    ForEach ($user in $users) { 

        write-host "adding user "  $user.UserPrincipalName  " to group " + $adminGroup.DisplayName

        Add-AzureADGroupMember -Objectid $groupid  -RefObjectId $user.ObjectId

        
    }