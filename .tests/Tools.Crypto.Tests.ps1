# .tests\Tools.Crypto.Tests.ps1

# Importiere das Modul, das die zu testenden Funktionen enthält
Import-Module -Name "$PSScriptRoot\..\Tools.Crypto.ps1"

# Testfälle für die Funktion Add-CodeSignature
Describe "Add-CodeSignature" {
    It "Should throw an error if the file does not exist" {
        { Add-CodeSignature -Path "C:\nonexistent\file.ps1" -CodeSignerThumbprint "THUMBPRINT" } | Should -Throw "The file C:\nonexistent\file.ps1 does not exist."
    }

    It "Should throw an error if the certificate is not found" {
        { Add-CodeSignature -Path "C:\path\to\file.ps1" -CodeSignerThumbprint "INVALID_THUMBPRINT" } | Should -Throw "The certificate with thumbprint INVALID_THUMBPRINT was not found in the personal certificate store of the current user."
    }

    It "Should throw an error if the certificate has no private key" {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        { Add-CodeSignature -Path "C:\path\to\file.ps1" -Certificate $cert } | Should -Throw "The certificate has no private key."
    }
}

# Testfälle für die Funktion Remove-CodeSignature
Describe "Remove-CodeSignature" {
    It "Should throw an error if the file does not exist" {
        { Remove-CodeSignature -Path "C:\nonexistent\file.ps1" } | Should -Throw "The file C:\nonexistent\file.ps1 does not exist."
    }

    It "Should remove the code signature from the file" {
        # Erstelle eine temporäre Datei mit einer Signatur
        $tempFile = New-TemporaryFile
        Set-Content -Path $tempFile -Value "# SIG # Begin signature block`n# SIG # End signature block"
        
        # Entferne die Signatur
        Remove-CodeSignature -Path $tempFile
        
        # Überprüfe, ob die Signatur entfernt wurde
        (Get-Content -Path $tempFile -Raw) | Should -Not -Match "# SIG # Begin signature block"
        
        # Lösche die temporäre Datei
        Remove-Item -Path $tempFile
    }
}

# Testfälle für die Funktion Import-Certificate
Describe "Import-Certificate" {
    It "Should import a certificate from a file" {
        $cert = Import-Certificate -FilePath ".tests\cert.pem"
        $cert | Should -BeOfType "System.Security.Cryptography.X509Certificates.X509Certificate2"
    }

    It "Should import a certificate from a base64 string" {
        $base64Cert = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes(".tests\cert.pem"))
        $cert = Import-Certificate -Base64Certificate $base64Cert
        $cert | Should -BeOfType "System.Security.Cryptography.X509Certificates.X509Certificate2"
    }
}

# Testfälle für die Funktion Export-CertificateEx
Describe "Export-CertificateEx" {
    It "Should export a certificate to a file" {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(".tests\cert.pem")
        Export-CertificateEx -Certificate $cert -FilePath ".\.tests\export.pem"
        Test-Path ".\.tests\export.pem" | Should -Be $true
        Remove-Item -Path ".\.tests\export.pem"
    }

    It "Should export a certificate as a base64 string" {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(".tests\cert.pem")
        $base64Cert = Export-CertificateEx -Certificate $cert
        $base64Cert | Should -Match "-----BEGIN CERTIFICATE-----"
    }
}