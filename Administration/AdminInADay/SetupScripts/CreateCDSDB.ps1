
$userprefix = 'labadmin*'

Import-Module Microsoft.PowerShell.Utility


Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force
Install-Module -Name Microsoft.PowerApps.PowerShell  -Scope CurrentUser -AllowClobber -Force
Install-Module Microsoft.Xrm.OnlineManagementAPI -Scope CurrentUser -Force


Install-Module -Name MSOnline -Scope CurrentUser -Force
Import-Module MSOnline

$creds = Get-Credential


Connect-MsolService -Credential $creds

$UserPassword = "test@word1"


function Create-CDSenvironment {

    param(
    [Parameter(Mandatory = $false)]
    [string]$password=$UserPassword,
    [Parameter(Mandatory = $false)]
    [string]$CDSlocation="canada"
    )
    $starttime= Get-Date -DisplayHint Time
    Write-Host " Starting CreateCDSEnvironment :" $starttime   -ForegroundColor Green

    $securepassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $users = Get-MsolUser | where {$_.UserPrincipalName -like $userprefix } | Sort-Object UserPrincipalName

    
    ForEach ($user in $users) { 
        $envDev=$null
        $envProd=$null

        if ($user.isLicensed -eq $false)
        {
        write-host " skiping user " $user.UserPrincipalName " he is not licensed" -ForegroundColor Red
        continue
        }

        write-host " switching to user " $user.UserPrincipalName 

        Add-PowerAppsAccount -Username $user.UserPrincipalName -Password $securepassword -Verbose

        write-host " creating environment for user " $user.UserPrincipalName 
         
         $envDisplayname = "Central Apps Test - " + $user.UserPrincipalName.Split('@')[0] 
         $envDisplayname
         
       #  while ($envDev.EnvironmentName -eq $null)
       # {
            $envDev = New-AdminPowerAppEnvironment -DisplayName  $envDisplayname -LocationName $CDSlocation -EnvironmentSku Production -Verbose
            
       # }
         Write-Host " Created CDS Environment with id :" $envDev.EnvironmentName   -ForegroundColor Green 
        
#         $envDisplayname = $user.UserPrincipalName.Split('@')[0] + "-Prod"
#         $envDisplayname

 #         while ($envProd.EnvironmentName -eq $null)
 #       {
 #           $envProd = New-AdminPowerAppEnvironment -DisplayName  $envDisplayname -LocationName $CDSlocation -EnvironmentSku Production -Verbose
 #       }
 #       Write-Host " Created CDS Environment with id :" $envProd.EnvironmentName   -ForegroundColor Green 
         
    }
    $endtime = Get-Date -DisplayHint Time
    $duration = $("{0:hh\:mm\:ss}" -f ($endtime-$starttime))
    Write-Host "End of CreateCDSEnvironment at : " $endtime "  Duration: " $duration   -ForegroundColor Green

}



function create-CDSDatabases {

        $starttime= Get-Date -DisplayHint Time
        Write-Host "Starting CreateCDSDatabases :" $starttime   -ForegroundColor Green

        $CDSenvs = Get-AdminPowerAppEnvironment | where { $_.DisplayName -like "Central Apps*" -and $_.commonDataServiceDatabaseType -eq "none"} | Sort-Object displayname
        
        Write-Host "creating CDS databases for following environments :
          " $CDSenvs.DisplayName "
        ****************************************************************
        ****************************************************************" -ForegroundColor Green

        ForEach ($CDSenv in $CDSenvs) { 
         $CDSenv.EnvironmentName
         Write-Host "creating CDS databases for:" $CDSenv.DisplayName " id:" $CDSenv.EnvironmentName -ForegroundColor Yellow
            # while ($CDSenv.CommonDataServiceDatabaseType -eq "none" )
            #{
           # $CDSenv.CommonDataServiceDatabaseType
             New-AdminPowerAppCdsDatabase -EnvironmentName  $CDSenv.EnvironmentName -CurrencyName USD -LanguageName 1033 -Verbose -ErrorAction Continue -WaitUntilFinished $false
           # $CDSenv=Get-AdminPowerAppEnvironment -EnvironmentName $CDSenv.EnvironmentName
           # }
        }

        $endtime = Get-Date -DisplayHint Time
        $duration = $("{0:hh\:mm\:ss}" -f ($endtime-$starttime))
        Write-Host "End of CreateCDSDatabases at : " $endtime "  Duration: " $duration   -ForegroundColor Green
        
}

function Setup-CDSenvironments{
    param(
    [Parameter(Mandatory = $false)]
    [string]$CDSlocation="canada"
    )
   

    Add-PowerAppsAccount -Username $creds.UserName -Password $creds.Password

    create-CDSenvironment -CDSlocation $CDSlocation

    Add-PowerAppsAccount -Username $creds.UserName -Password $creds.Password
        
    create-CDSDatabases
    
}
