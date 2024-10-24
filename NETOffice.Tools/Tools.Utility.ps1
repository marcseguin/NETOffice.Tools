Function Read-Credentials {

    Param(
        [Parameter(Mandatory = $true)] [string] $FileName) 

    try {
        if (Test-Path -Path $FileName -PathType Leaf) {
            Write-LogInfo "Loading Credential file '$FileName'"
            $credential = Import-Clixml $FileName
        }
        else {
            Write-LogInfo 'Quering Credentials...'
            Write-Host 'Die Anmeldeinformationsdatei ' -NoNewline -ForegroundColor Yellow  
            Write-Host $filename -NoNewline 
            Write-Host ' existiert nicht. Geben Sie die Anmeldeinformationen manuell ein.' -ForegroundColor Yellow  

            $credential = Get-Credential 
            $decision = $Host.UI.PromptForChoice("Anmeldeinformationsdatei '$FileName' speichern", 'Sollen die Zugangsdaten fuer spaetere Zugriffe gespeichert werden (Das Kennwort wird verschluesselt gespeichert)?', @('&Ja', '&Nein'), 0)
            if ($decision -eq 0) {
                Write-LogInfo "Saving Credential file $filename"
                Export-Clixml -Path $FileName -InputObject $credential
            }
            else {
                Write-LogInfo "Credential file '$FileName' won't be saved."
            }
        }
        return $credential
    }
    catch {
        Write-LogError "$_`r`n$($_.InvocationInfo.PositionMessage)"
        throw
    }
}

Function New-Credential {

    Param(
        [Parameter(Mandatory = $true)] [string] $UserName,
        [Parameter(Mandatory = $true)] [string] $Password)
    try {
        return New-Object System.Management.Automation.PSCredential ($UserName, (ConvertTo-SecureString $Password -AsPlainText -Force))
    }
    catch {
        Write-LogError "$_`r`n$($_.InvocationInfo.PositionMessage)"
        throw
    }
}

Function Get-Choice {

    Param(
        [Parameter(Mandatory = $true)] [string] $Title,
        [Parameter(Mandatory = $true)] [string] $Prompt,
        [Parameter(Mandatory = $true)] [string[]] $Options,
        [int] $Default = 0)
    $ObjOptions = [System.Management.Automation.Host.ChoiceDescription[]] $Options
    if ($default + 1 -gt $Options.Count) {
        $default = $Options.Count - 1
    }
    $host.UI.PromptForChoice($Title, $Prompt, $ObjOptions, $Default)
}

Function ConvertFrom-FileTime {
    param(
        [Parameter(ValueFromPipeline, Position = 0, Mandatory = $true)] [long] $FileTime
    )
    if ($filetime -eq 0) {
        return $null
    }
    else {
        return [datetime]::FromFileTime($FileTime)    
    }
}

Function Find-Configurationfile {

    param(
        [string] $Filename
    )

    $pathsToCheck = @(
        $Filename,
        "$env:programdata\sensu\config\$BaseFilename.config.json",
        "$Global:BaseFileDirectory\$BaseFilename.config.json"
    )

    # Wähle den ersten existierenden Pfad aus
    $configFile = $pathsToCheck | Where-Object { -not [string]::IsNullOrEmpty($_) -and (Test-Path -PathType Leaf -Path $_) } | Select-Object -First 1

    return $configFile
}

# SIG # Begin signature block
# MIIHSgYJKoZIhvcNAQcCoIIHOzCCBzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCSLqh4A0ZF0X69
# qg9YqC2y0v576UJot8HPDkNUa4Hkq6CCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
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
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDnJM90R
# Bn7ZB+QK11WTdzfjaaX3nXPpHs5NMKm/F84oMA0GCSqGSIb3DQEBAQUABIIBgC8C
# +KmDcYPm0wHVGyLZ0Fg9RusuriXf++M1bFZJ83BlaWWzItrELE+HkGUYEfV5wO8e
# UWGZ4gFw66JVwuItOI9Ibnp6hRFBoZiomKjt1fnnh91cchfYt9V4qs/GqzItr0ds
# Rm6qAOCyKk7j1tNHSHnrinjgTKFQU5azTGcKX2USAmDy7zmnj6PXGaMh3OaR8RRI
# 3TW2IiwQmueRgD3+E4QK5zdKawbIbmTBSEjJaO/L5PxmwYKpHVvnD8dES0/hDlpb
# 4qvnsB9UKgXdk+8fgbqrosC5c9zjKkIorbRUDk9qJ5xLZSyCugw4h5ppq4Q4c/7c
# eA2xUejq8wQT13Iado7KCMxp5FaibB6KfpVf+BT/ZtvztFicuxh+qYUOxglyOLiX
# 4WRmkFCsxUJR+aZ82Fo+ICQYSd39HyJ83V3v+aIuGSJxZXTd+EU7fCUG2CDhZcmA
# jyagA7HDJB/7Hxj9L9pOkVCD0dVsMF1bgHjQN5N6ccUd1aUX11QtXiz2uzSyGA==
# SIG # End signature block
