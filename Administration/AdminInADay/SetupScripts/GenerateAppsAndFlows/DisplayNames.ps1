$appNames = Get-Content -Path .\AppNames.txt
foreach($appName in $appNames)
{
    Write-Host $appName
} 