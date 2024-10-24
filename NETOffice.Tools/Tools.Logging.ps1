function Start-Logging {
    try {
        if ([string]::IsNullOrEmpty($configfilename)) {
            Throw "no log4net configuration file $filename found!" 
        }
        [void][Reflection.Assembly]::LoadFile("$ModulePath\log4net.dll")
        [log4net.LogManager]::ResetConfiguration()        
        [log4net.Config.XmlConfigurator]::Configure([URI](invoke-expression "`"$($config.Logging.ConfigFilename)`""))
        $Global:Log4n = [log4net.LogManager]::GetLogger('root')
        $Log4n.Info('***** Logging started *****')
        $log4n.Info("Log configuration file : $configFilename")
        $log4n.Info("Log file : $($log4n.Logger.Parent.Appenders.file)")
    }
    catch {
        throw
    }
}
    
function Stop-Logging {    
    try {
        $Log4n.info('***** Logging stopped *****')
        Remove-Variable -Name 'Log4n' -Scope 'Global'
        [log4net.LogManager]::ResetConfiguration()
    }
    catch {
        throw 'An error happend when trying to stop the log4net logging faciliy.'
    }
}
    
function Write-LogDebug {
    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.debug($message)
}

function Write-LogInfo {
    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.info($message)
}

function Write-LogWarn {
    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.warn($message)
}

function Write-LogError {
    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.error($message)
}
    
function Write-LogFatal {
    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.fatal($message)
}


# SIG # Begin signature block
# MIIHSgYJKoZIhvcNAQcCoIIHOzCCBzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDGD0NFHb13dmIp
# 7Pxnr9nLqsUG+WeUBUh8WM1k7vmJvaCCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
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
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIA4A9qJB
# g7kSVcDduNRUslUQMWe8Gw5v1mDbRJJ1Og7GMA0GCSqGSIb3DQEBAQUABIIBgDKW
# EyacY5+TR5lGIK7CodECSbYOfG0LoJCzhXIrk4iw6FLPw+P3t/EcpWK5TfLvvgd/
# vbYfT1kDMv+Umvuhuh8ayo/CCQwTH8dUdzvLJDSMN7+GQS6yU+OG8M5dvngoXJZR
# eNkFQt2g9HgdElcaPwWaepwpv3HvepCfN4esl2q6Lv7OZZzh3AwjpULtFXm/eXV/
# N9qiwM21qiDQ5b+jDEO8WM9orWilXOnVVG0aY+MJ+WTh/mb17BXxcPM8uZsnDMDU
# /kwqN0UdwaSqBH0yVJ7nS1M8E8csHGjzAslbUUWyvOkkm0kzxmX2mKwg93A/RRcB
# qAz7+hgq6X30D+VLv4BwPBoVr9XpfCNz8G/TBayEk7sgv5HhqVN3rri5GXFH2Jfv
# 55nl1lGZz7Wyu1i0Bb+aylt4lPF0U50fPovm9ab9+PbEviUb4i682YecFMa0k5Cs
# 2NTTcJMSqUBak5vMdejE7hk7Olxu4VON9P7aNSi9bdXQatEmDPzHr2IKevdQMQ==
# SIG # End signature block
