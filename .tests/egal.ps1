# Erstellen eines selbstsignierten Zertifikats
$cert = New-SelfSignedCertificate -Subject "CN=TestCert" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature

# Exportieren des Zertifikats in eine .pfx-Datei
$pfxPath = ".\.tests\cert.pfx"
$password = ConvertTo-SecureString -String "P@ssw0rd" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password

# Importieren des Zertifikats aus der .pfx-Datei
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($pfxPath, "P@ssw0rd", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

# Exportieren des Zertifikats in eine .pem-Datei
$pemPath = ".\.tests\cert.pem"
$base64Cert = [Convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
$pemContent = "-----BEGIN CERTIFICATE-----`n$base64Cert`n-----END CERTIFICATE-----"
Set-Content -Path $pemPath -Value $pemContent

# Optional: Bereinigen der .pfx-Datei
Remove-Item -Path $pfxPath