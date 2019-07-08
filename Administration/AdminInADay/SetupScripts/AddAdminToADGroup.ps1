
   $userprefix = 'labadmin*'

   $UserCredential = Get-Credential   

   Install-Module -Name MSOnline -Scope CurrentUser
   
   Import-Module MSOnline

   Connect-MsolService -Credential $UserCredential

   install-module azuread -Scope CurrentUser
   import-module azuread

   Connect-AzureAD -Credential $UserCredential

   $adminGroup = Get-azureADGroup | where {$_.DisplayName -eq "Lab Admin Team"} | Select-Object -first 1

   if (!$adminGroup)
   {
        $adminGroup = New-AzureADGroup -Description "Lab Admin Team" -DisplayName "Lab Admin Team" -MailEnabled $false -SecurityEnabled $true -MailNickName "LabAdmins"
        Write-Host "Created new group " $adminGroup.ObjectId
   }
   else
   {
        Write-Host "Found existing group " $adminGroup.ObjectId
   }
   
   $users = Get-MsolUser | where {$_.UserPrincipalName -like $userprefix} | Sort-Object UserPrincipalName

   $existingMembers = Get-AzureADGroupMember -ObjectId $adminGroup.ObjectId | Select -ExpandProperty UserPrincipalName


    ForEach ($user in $users) { 

        if (!$existingMembers -contains $user.UserPrincipalName)
        {

            write-host "adding user "  $user.UserPrincipalName  " to group "  $adminGroup.DisplayName

            Add-AzureADGroupMember -ObjectId $adminGroup.ObjectId -RefObjectId $user.ObjectId
        }
        else
        {
            write-host "user "  $user.UserPrincipalName  " is already a member of "  $adminGroup.DisplayName
        }

        
    }