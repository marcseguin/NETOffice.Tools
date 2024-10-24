function Get-Encoding {
    param
    (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]
        $Path
    )
    
        process {
            $bom = New-Object -TypeName System.Byte[](4)
            
            $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')
        
            $null = $file.Read($bom, 0, 4)
            $file.Close()
            $file.Dispose()
        
            $enc = [Text.Encoding]::ASCII
            if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) { $enc = [Text.Encoding]::UTF7 }
            if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) { $enc = [Text.Encoding]::Unicode }
            if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) { $enc = [Text.Encoding]::BigEndianUnicode }
            if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) { $enc = [Text.Encoding]::UTF32 }
            if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) { $enc = [Text.Encoding]::UTF8 }
            
            [PSCustomObject]@{
                Encoding = $enc
                Path     = $Path
            }
        }
    }
    

# SIG # Begin signature block
# MIIHSgYJKoZIhvcNAQcCoIIHOzCCBzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCPUxYQNjyCAFBc
# l9yRyp2TqdrwIKFzNqtXXH2Rq6WNcKCCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
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
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIE93w6aC
# hva6ivnozc/1afu8YkI/8FQVpnHeuKzoXORCMA0GCSqGSIb3DQEBAQUABIIBgG8w
# Rlev8YorPXYKh7822hZvZ44T5gyXL05X/P0jy0zzP8iEoE0bBttIvFlj51KH6JhA
# 29dRXzW0SWeZt4Zpgza1n0t048dUbb73op53X882D8Km8G7OmxzXKw/1pS11BC0d
# utMF09rL90LmAf5nRVPyKphwPlxDlUxIJkxe1qlkEKLNyiybgkxQazr+eyNYaEoo
# DimKcPbils+xTxJzKs+MC4JVs25n+E4/8DRpT5R3eUBvnq9yN8xSh4LaA4Ty+2sA
# OF2R0Op9f7T+PUgYcWC7n08PRRJo3wUhJkgbY3rEGAuU+Tus9E77I1cBg9CYikoF
# 1H95iy2d7+DW37kKXcWKe5Jk1h03FINpXqXrMekTmeTtON5pNyUyQiZOo2h/qEQ5
# /KZlE8gjUyQQHTHA/qiwZv+ia4ZpEQowJmJkJPZHDFBwOsWGKuXa7iyAdGOgtor+
# oMUEXmZU+OIOxDSVwh2z16i7mnibjjXtx2gnyODAUNSy5wNcfEB2c36d/hRr8g==
# SIG # End signature block
