function Add-CodeSignature {
    param (
        [string] $Filename = $(throw 'Please specify a filename.'),
        [string] $CodeSignerThumbprint = $script:config.CodeSigning.CodeSignerThumbprint
    )
    if ($CodeSignerThumprint -eq '') {
        throw "Please specify valid code signer's certificate thumbprint."
    }
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.thumbprint -Match $CodeSignerThumbprint }
    if ($null -eq $cert) {
        throw "Please install code signing certificate *AND* its private key with thumbprint $CodeSignerThumbprint in personal certificate store."
    }
    Set-AuthenticodeSignature $FileName $cert
}
    
function Remove-CodeSignature {
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]
        $Path
    
    )
    $Enc = Get-Encoding -Path $Path
    $content = Get-Content -Path $Path -Raw -Encoding $Enc.Encoding
    $content = $content -replace '# SIG # Begin signature block((.*\n)*)# SIG # End signature block', ''
    $content | Out-File -FilePath $path -Encoding $Enconding.Encoding    
}


function Read-Certificate {
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'File')] [String] $FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Base64')] [String] $Base64Certificate
    )
    if ($PSCmdlet.ParameterSetName -eq 'File') {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($FilePath)
    }
    else {
        $Base64Certificate = $Base64Certificate.Replace('-----BEGIN CERTIFICATE-----', '')
        $Base64Certificate = $Base64Certificate.Replace('-----END CERTIFICATE-----', '')
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import([Convert]::FromBase64String($Base64Certificate))
    }
    return $cert
}

enum EnumCertificateFormatType {
    base64
}
function Export-CertificateEx {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU217jpdn8gAy78/hOYm5IvgyD
# Q2agggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUQj4iQExXbgJvrR/bkIGDg2aqvVowDQYJKoZIhvcN
# AQEBBQAEggGASBp80citICAqIzD1O75u3SAsHBz78cFQNb8lE5tZPRQOS39c6H3/
# oQkX3hVRab95CqUd52iUbROr6xr1obsk76u/eRSLill9DMwK38SALe2N0yvqQQAs
# gNszWSdlFsjamWVvpZ1+v509mRtSqj0IA3GTGpEwhqOQdaAe4gXj4i0LSUyTXGXc
# 1Y5jK7cu8ib+kDhi5LoUlnUH0S+kbHUC3cklrlBHWgSzEOBkAGPPhVjfiME5leMw
# 3oZFEH2e67j32G923nc1L1FuYd0R3TEIf1/Q/VALUShRmrzQ5LZAqhhqW94fQJec
# Isn09/JTsPD2SKEaZwoELnkmExPAAzGkwBhPhfuDgrGg1DvVNapn61fDVkI6yv7A
# 9ZPkLXaqz5r70XkxdOg4E/y83le566200zLECnDkJ9VEQbnnn7tssuLTUy/GwBoo
# kcgc5KpUUHzvZiyk6uMuyhKJGFBZ7MoTCSmfASLjjy8WrvIa52TaqbefNb2/xWE/
# lQr30ck3dYE4
# SIG # End signature block
