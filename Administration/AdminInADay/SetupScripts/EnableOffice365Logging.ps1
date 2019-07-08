$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session -DisableNameChecking

Write-Host "Enabling Customizations"

Enable-OrganizationCustomization

Write-Host "Enabling Customizations - Done"

Write-Host "Setting Unified Audit Log Ingestion Enabled"

Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true 

Write-Host "Setting Unified Audit Log Ingestion Enabled - Done"

Remove-PSSession $Session