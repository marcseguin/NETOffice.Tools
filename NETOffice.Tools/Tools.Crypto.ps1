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
# MIIHSgYJKoZIhvcNAQcCoIIHOzCCBzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBitFrz1x7QPz4I
# yIjCjtNOgJ+upn2chHC2z1unxxC3gaCCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
# hUTpwicUJt4MMA0GCSqGSIb3DQEBCwUAMCExHzAdBgNVBAMMFk5FVC5PZmZpY2Ug
# Q29kZVNpZ25pbmcwIBcNOTkxMjMxMjMwMDAwWhgPMjA5OTEyMzAyMzAwMDBaMCEx
# HzAdBgNVBAMMFk5FVC5PZmZpY2UgQ29kZVNpZ25pbmcwggGiMA0GCSqGSIb3DQEB
# AQUAA4IBjwAwggGKAoIBgQC9Zu8QcBSfopZe1AA0g57HvoMNiylgOaD5u7OqevM+
# L+ubo6akTZVAl6L7fRCn2uWP/I8yD5Epkva/WG9NZ2CzStu8Oew0efgAswJgAFch
# lrAK7tEhrruOAIto6XT61XeKM/EsHdxDw2gEY+9n4TxWdzbsQ9D2QS8W2A94Ohbh
# KMRGVrt4sTwYCfCWN0tzCu2vtVlysAlcYg1UQHtaTRWWUwKapIUKoHCjkOEkAWQy
# r21kiuRMAanB8STtXFIyveudr9AZKLfp3EE0nwL/9UMujN5XPL3EBcJCXCq6SZut
# 4JGoTNNn/PXNX3hEsAG+cooxhlT+7EBaFrTj9466hTKZBciskqs42lc8j48W5qBD
# Wv2K2HZYtHerOCb9hKBQcnH7mkTYb19d8es/2XLxsAFKzATU7c0rpDJdwkk0OtHz
# r2lJjHMrRRq0SwgNrlRUP2TY1uAiF2bb9PkoH8ms9gIUo2VE8Gd9toV8xU4Scv9e
# 0+5fZMvTwRtXh+BuXjxolNECAwEAAaNnMGUwDgYDVR0PAQH/BAQDAgeAMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB8GA1UdEQQYMBaBFHN1cHBvcnRAbmV0b2ZmaWNlLmV1
# MB0GA1UdDgQWBBR/MXTPLvKYY22e96tSZC18IrKaDjANBgkqhkiG9w0BAQsFAAOC
# AYEAfW2H+PvT1T7pNwRbhNqWynQ2e3oEpvRL3PxgUbk4wUoZiT/cRcKvN6aU2F+y
# ykMejOEiaMm8WjDITmk4RM+3H0kdg971nkKAEr3hzgUkCX7O5l3H1v/0YgTKnMdZ
# YOkem97/cNqJshnVi5cN6i+aV+LWmBwK1xEn2sqm3LLbjhUG2OfpcV4ZQT9f1k73
# k4e40zLDWsC4GrdxujW3Fd6mwLFjLFtJZEZBwX0Q7yNtr2Y3xgG3U2951UhqQ9ht
# 4FtEpYtGGKZLg6fbhQt0BZziRwYxFsK+++ezUxmwXoy84z5L6U15P/vds6YV0IO4
# 0pntYy31r7h6Hr49LYEvlk5KQjmPYErgKq/IYzqO7nWAvwGxhrFCxcMVntcyeByl
# zVvc40OXI88+VLnW0AupeLkhAUboWMx39IOIdIzYmIFQykXO4wdxXBUzdgXft2nz
# ucqdlUBb57t/ZuVX1dAECobV5OpUsyRxqlO7q9hZx1Kb5nMr5zDkRznErPGjBWR7
# TtIxMYICZzCCAmMCAQEwNTAhMR8wHQYDVQQDDBZORVQuT2ZmaWNlIENvZGVTaWdu
# aW5nAhAwsvZHii5xhUTpwicUJt4MMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQB
# gjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIH/KJUGZ
# znkFWtuAHFw3SaTiT7Ma4bsaGfVnYYMa4TFJMA0GCSqGSIb3DQEBAQUABIIBgCII
# IaDAJsAjpPoVaM7hSQjK4Xo0wpfm+XgJoGGxRc0pJ+siLYJaGjlPMHP+bpKHWiPA
# R6d6PEacmzFOcgaGjUhS54CshOYy8B8xr4MsZYEj1BoUyBgV4/EsfGYuIJ3XlO20
# YAg6WXukyZw6e2ZoueC85rJ90kmlNhHDlYo1BYNT6sP8yf3XVgY5+dIBNpjYDkgx
# H1tHzNDk5omkUTmrEufkcc7kE+hd1X5IXJUAj49Liw54hg6VLCMGzRAEpX8uWp9d
# K2ut4aluNRYNyid2Jt88RQmB61cXddjUICo0RsWdh1viVB4iuQFHXB6YWmIKJcfi
# UYlYQaVKgAoDoHcWE1EdSoSpKJL/px55MZu5P1PxXsaAaOkmTAD7c7EUxBYOclnq
# F7cfB/ik6PDaupw+PbF/8r00hRSyTpv54IcEwJmv1/+15AyvpwjfFuWIZuQdXlDG
# LHfTMEEdyFQSsqOyiKcnNUInufEQDrAvWVLUN5JIvDEj/GFYQHxUCF7pH3IDKA==
# SIG # End signature block
