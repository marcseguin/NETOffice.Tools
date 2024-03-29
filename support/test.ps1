Remove-Module NETOffice.Tools -Force
Import-Module "C:\Users\marc.seguin\NET.Office GmbH\Intranet - Support\Kunden\NET.Office\PowerShell\Modules\NETOffice.Tools\NETOffice.Tools\NETOffice.Tools.psd1" -Force
Write-LogDebug "test"
$a= "-----BEGIN CERTIFICATE-----`n$([Convert]::ToBase64String((Get-item Cert:\CurrentUser\My\A03830B8107B868916833E0FB0D241DDCCF2140F).Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert),[System.Base64FormattingOptions]::InsertLineBreaks))`n-----END CERTIFICATE-----"
Read-Certificate -Base64Certificate $a
