<#
.SYNOPSIS
This module provides a set of tools for handling cryptographic operations such as code signing, certificate management, and text encryption/decryption.

.DESCRIPTION
The Tools.Crypto module includes functions to add and remove code signatures from files, read and export certificates, and encrypt/decrypt text using certificates. 
These functions are designed to facilitate secure handling of scripts and sensitive data within the NET.Office environment.

.FUNCTIONS
Add-CodeSignature
    Adds a code signature to the specified file using a certificate.

Remove-CodeSignature
    Removes the code signature from the specified file.

Read-Certificate
    Reads a certificate from a file or a Base64 encoded string.

Export-CertificateEx
    Exports a certificate to a file or returns it as a Base64 encoded string.

ConvertFrom-EncryptedText
    Decrypts an encrypted text using a specified certificate.

ConvertTo-EncryptedText
    Encrypts a clear text using a specified certificate.

.NOTES
Ensure that the necessary certificates are imported into the personal certificate store of the user and that they contain the appropriate keys for the operations being performed.
#>

function Add-CodeSignature {
<#
.SYNOPSIS
Adds a code signature to the specified file.

.DESCRIPTION
The function adds a code signature to the file specified by the parameter {Path} using the certificate identified by thumbprint {CodeSignerThumbprint}.
The certificate and its private key must already be imported in the personal certificate store of the user.

.PARAMETER Path
The path to the file that needs to be signed.

.PARAMETER CodeSignerThumbprint
The thumbprint of the code signer's certificate. If not specified, the default thumbprint from the configuration will be used.

.EXAMPLE
Add-CodeSignature -Path "C:\path\to\file.ps1" -CodeSignerThumbprint "THUMBPRINT"

.THROWS
Throws an exception if the file does not exist or if the certificate is not found.

.NOTES
The certificate and its private key must already be imported in the personal certificate store of the user.
#>
[CmdletBinding(DefaultParameterSetName = 'WithThumbprint')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'WithThumbprint')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'WithCertificate')]
        [ValidateNotNullOrEmpty()]
        [Alias('Filename')]
        [string] $Path,

        [Parameter(ParameterSetName = 'WithThumbprint')]
        [ValidateNotNullOrEmpty()]
        [string] $Thumbprint=$config.CodeSigning.CodeSignerThumbprint,
        
        [Parameter(Mandatory,ParameterSetName = 'WithCertificate')]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate

    )
    switch  ($PSCmdlet.ParameterSetName) {
        'WithThumbprint' {
            try{
                $Certificate = Get-ChildItem "cert:\CurrentUser\My\$Thumbprint"
            }
            catch {
                throw "The certificate with thumbprint $Thumbprint was not found in the personal certificate store of the current user."
            }
        }
        'WithCertificate' {
        }

    }
    if (-not $Certificate.HasPrivateKey) {
        throw "The certificate has no private key."
    }

    if (-not (Test-Path $Path)) {
        throw "The file $Path does not exist."
    }
    Set-AuthenticodeSignature $Path $Certificate
}
    
function Remove-CodeSignature {
<#
.SYNOPSIS
Removes the code signature from the specified file.

.DESCRIPTION
This function removes the code signature from the file specified by the Path parameter.

.PARAMETER Path
The path to the file from which the code signature should be removed.

.EXAMPLE
Remove-CodeSignature -Path "C:\path\to\file.ps1"

.THROWS
Throws an exception if the file does not exist or if there is an error removing the signature.

.NOTES
Ensure the file is accessible and not in use by another process.
#>
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Filename')]
        [string]
        $Path
    
    )

    if (-not (Test-Path $Path)) {
        throw "The file $Path does not exist."
    }
    try{
        $Enc = Get-Encoding -Path $Path
        $content = Get-Content -Path $Path -Raw -Encoding $Enc.Encoding
        $content = $content -replace '# SIG # Begin signature block((.*\n)*)# SIG # End signature block', ''
        $content | Out-File -FilePath $path -Encoding $Enc.Encoding    
    }
    catch {
        throw "Error removing signature from $Path`: $_"
    }
}


function Read-Certificate {
<#
.SYNOPSIS
Reads a certificate from a file or a Base64 encoded string.

.DESCRIPTION
This function reads a certificate from the specified file path or from a Base64 encoded string.

.PARAMETER FilePath
The path to the certificate file.

.PARAMETER Base64Certificate
The Base64 encoded string of the certificate.

.EXAMPLE
Read-Certificate -FilePath "C:\path\to\certificate.cer"

.EXAMPLE
Read-Certificate -Base64Certificate "BASE64ENCODEDSTRING"

.THROWS
Throws an exception if the certificate cannot be read.

.NOTES
Ensure the certificate file is accessible and correctly formatted.
#>
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'File')] [String] $FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Base64')] [String] $Base64Certificate
    )
    if ($PSCmdlet.ParameterSetName -eq 'File') {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($FilePath)
    }
    else {
        $FilePath= [System.IO.Path]::GetTempFileName()
        $Base64Certificate | Out-File -FilePath $FilePath
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($FilePath)
        Remove-Item -Path $FilePath
    }
    return $cert
}

enum EnumCertificateFormatType {
    base64
}
function Export-CertificateEx {
<#
.SYNOPSIS
Exports a certificate to a file or returns it as a Base64 encoded string.

.DESCRIPTION
This function exports the specified certificate to a file or returns it as a Base64 encoded string.

.PARAMETER Certificate
The certificate to export.

.PARAMETER FilePath
The path to the file where the certificate should be saved.

.PARAMETER Format
The format in which to export the certificate. Default is Base64.

.EXAMPLE
Export-CertificateEx -Certificate $cert -FilePath "C:\path\to\certificate.cer"

.EXAMPLE
Export-CertificateEx -Certificate $cert

.THROWS
Throws an exception if the certificate cannot be exported.

.NOTES
Ensure the certificate is valid and the file path is accessible.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate,
        [Parameter(Mandatory = $false)] [String] $FilePath,
        [Parameter(Mandatory = $false)] [EnumCertificateFormatType] $Format = [EnumCertificateFormatType]::base64
    )
    $Text = "-----BEGIN CERTIFICATE-----`n$([convert]::ToBase64String($cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert),[System.Base64FormattingOptions]::InsertLineBreaks))`n-----END CERTIFICATE-----"
    if (-not ([string]::IsNullOrEmpty($FilePath))) {
        $Text | Out-File -FilePath $FilePath
    }
    return $Text
}
function ConvertFrom-EncryptedText {
<#
.SYNOPSIS
Decrypts an encrypted text using a specified certificate.

.DESCRIPTION
This function decrypts the specified encrypted text using the private key of the provided certificate.

.PARAMETER EncryptedText
The text to decrypt.

.PARAMETER Certificate
The certificate with the private key to use for decryption.

.EXAMPLE
ConvertFrom-EncryptedText -EncryptedText "ENCRYPTEDTEXT" -Certificate $cert

.THROWS
Throws an exception if the decryption fails.

.NOTES
Ensure the certificate contains the private key and is valid.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $EncryptedText,
        [Parameter(Mandatory = $true)] [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)
    $encryptedBytes = [Convert]::FromBase64String($EncryptedText)
    $decryptedBytes = $rsa.Decrypt($encryptedBytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
    $decryptedText = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    return $decryptedText
}

function ConvertTo-EncryptedText {
<#
.SYNOPSIS
Encrypts a clear text using a specified certificate.

.DESCRIPTION
This function encrypts the specified clear text using the public key of the provided certificate.

.PARAMETER ClearText
The text to encrypt.

.PARAMETER Certificate
The certificate with the public key to use for encryption.

.EXAMPLE
ConvertTo-EncryptedText -ClearText "CLEARTEXT" -Certificate $cert

.THROWS
Throws an exception if the encryption fails.

.NOTES
Ensure the certificate is valid and contains the public key.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $ClearText,
        [Parameter(Mandatory = $true)] [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($Certificate)
    $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($ClearText)
    $encryptedBytes = $rsa.Encrypt($bytesToEncrypt, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
    $encryptedText = [Convert]::ToBase64String($encryptedBytes)
    return $encryptedText
}

# SIG # Begin signature block
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVdYuMrMiTuYBklsXmXCRXXIa
# jv2gggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
# AQsFADAhMR8wHQYDVQQDDBZORVQuT2ZmaWNlIENvZGVTaWduaW5nMCAXDTk5MTIz
# MTIzMDAwMFoYDzIwOTkxMjMwMjMwMDAwWjAhMR8wHQYDVQQDDBZORVQuT2ZmaWNl
# IENvZGVTaWduaW5nMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAvWbv
# EHAUn6KWXtQANIOex76DDYspYDmg+buzqnrzPi/rm6OmpE2VQJei+30Qp9rlj/yP
# Mg+RKZL2v1hvTWdgs0rbvDnsNHn4ALMCYABXIZawCu7RIa67jgCLaOl0+tV3ijPx
# LB3cQ8NoBGPvZ+E8Vnc27EPQ9kEvFtgPeDoW4SjERla7eLE8GAnwljdLcwrtr7VZ
# crAJXGINVEB7Wk0VllMCmqSFCqBwo5DhJAFkMq9tZIrkTAGpwfEk7VxSMr3rna/Q
# GSi36dxBNJ8C//VDLozeVzy9xAXCQlwqukmbreCRqEzTZ/z1zV94RLABvnKKMYZU
# /uxAWha04/eOuoUymQXIrJKrONpXPI+PFuagQ1r9ith2WLR3qzgm/YSgUHJx+5pE
# 2G9fXfHrP9ly8bABSswE1O3NK6QyXcJJNDrR869pSYxzK0UatEsIDa5UVD9k2Nbg
# Ihdm2/T5KB/JrPYCFKNlRPBnfbaFfMVOEnL/XtPuX2TL08EbV4fgbl48aJTRAgMB
# AAGjZzBlMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAfBgNV
# HREEGDAWgRRzdXBwb3J0QG5ldG9mZmljZS5ldTAdBgNVHQ4EFgQUfzF0zy7ymGNt
# nverUmQtfCKymg4wDQYJKoZIhvcNAQELBQADggGBAH1th/j709U+6TcEW4Talsp0
# Nnt6BKb0S9z8YFG5OMFKGYk/3EXCrzemlNhfsspDHozhImjJvFowyE5pOETPtx9J
# HYPe9Z5CgBK94c4FJAl+zuZdx9b/9GIEypzHWWDpHpve/3DaibIZ1YuXDeovmlfi
# 1pgcCtcRJ9rKptyy244VBtjn6XFeGUE/X9ZO95OHuNMyw1rAuBq3cbo1txXepsCx
# YyxbSWRGQcF9EO8jba9mN8YBt1NvedVIakPYbeBbRKWLRhimS4On24ULdAWc4kcG
# MRbCvvvns1MZsF6MvOM+S+lNeT/73bOmFdCDuNKZ7WMt9a+4eh6+PS2BL5ZOSkI5
# j2BK4CqvyGM6ju51gL8BsYaxQsXDFZ7XMngcpc1b3ONDlyPPPlS51tALqXi5IQFG
# 6FjMd/SDiHSM2JiBUMpFzuMHcVwVM3YF37dp87nKnZVAW+e7f2blV9XQBAqG1eTq
# VLMkcapTu6vYWcdSm+ZzK+cw5Ec5xKzxowVke07SMTGCAlYwggJSAgEBMDUwITEf
# MB0GA1UEAwwWTkVULk9mZmljZSBDb2RlU2lnbmluZwIQMLL2R4oucYVE6cInFCbe
# DDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUIJFbjsn3WhCh5TYAARmME2XOgwMwDQYJKoZIhvcN
# AQEBBQAEggGAQqpAAlQ4RJZicMyFsp1hH3oZ1E1SYxo2H3rDttRhKTC+LGJ/bZxM
# EgwDiWUn0Sd3QZiDsZYW653H8HFRBx7O4KjguYSBtr+77SZyJF1Dgxz1qy4QXgwx
# ihbonQKL4KP94fRbouU2SIwRgmU0Z8mgrANjAwj2AL3K4wJILgaMK+afkKtDqwe0
# QZPU8BeDZnhfZkgYdMXNyDesVYH6jIP+x/zzrcE7P8CNe1ArOBokxkll47IwPMRZ
# +FUfQNLTNQmp/EZPCt/g5vXxaODdz0IQ0YL1pWRzZR3IwTdf6VPnOJH0GbfQ9hca
# weaebqiUAqzb3p3TyYa+G0kLY4N9JipRxOigOtySs3tg7Dok2JnOqjwnzakCjGTx
# jLLEVxaiwQ39TrIORZWusSHwUJOa4PJR9UJv0WqFklEI9X1MYsncGx13mxsIktjp
# Av/1hVx5tPzGH3jVhKCX8Ju45JglGKGFrcR2lwxrJamWkk/7SdCLsdOTgDtKG++I
# nPFqm6HIvh1D
# SIG # End signature block
