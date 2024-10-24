# Module: NETOffice.Tools


##############################
# Module initialisation
##############################



$CallStack = Get-PSCallStack
$ModuleName = [io.path]::GetFileNameWithoutExtension($CallStack[0].ScriptName)
$ModulePath = [io.path]::GetDirectoryName($CallStack[0].ScriptName)
if ($null -ne $CallStack[1].ScriptName){
    $ScriptPath = [io.path]::GetDirectoryName($CallStack[1].ScriptName)
    $ScriptName = [io.path]::GetFileName($CallStack[1].ScriptName)
}
else {
    $ScriptPath = '.\'
    $ScriptName = "<No Script call>"
}


. "$ModulePath\Tools.Utility.ps1"
. "$ModulePath\Tools.Crypto.ps1"
. "$ModulePath\Tools.File.ps1"
. "$ModulePath\Tools.Logging.ps1"

# Look after configuration files

$pathsToCheck = @(
    "$ScriptPath\$ModuleName.config.json",
    "$ModulePath\$ModuleName.config.json"
)


# Wle den ersten existierenden Pfad aus
$configFilename = $pathsToCheck | Where-Object { -not [string]::IsNullOrEmpty($_) -and (Test-Path -PathType Leaf -Path $_) } | Select-Object -First 1
Write-Host "Script Name $ScriptName"
Write-Host "Module Name $ModuleName.psm1"
Write-Host "Script Path $ScriptPath"
Write-Host "Module Path $ModulePath"
Write-Host "Configuration file $configFilename"

if ($null -ne $configFilename) {
    $script:config = Get-Content $configFilename | ConvertFrom-Json
} else {
    throw [System.IO.FileNotFoundException] "No Configuration file  found!`nDepending on your setup the file '$ModuleName.config.json' avaible in $ScripPath or $ModulePath is required."
}
if ($script:config.Logging.enable) {
    Start-Logging -Filename $script:config.Logging.configfile
    if ($script:config.Logging.AliasEnabled) {
        New-Alias -Name Write-Debug -Value Write-LogDebug
        New-Alias -Name Write-Info -Value Write-LogInfo
        New-Alias -Name Write-Error -Value Write-LogError
        New-Alias -Name Write-Fatal -Value Write-LogFatal
        New-Alias -Name Write-Warn -Value Write-LogWarn
    }
    $Log4n.Info("$ModuleName module path: $ModulePath")
    $log4n.Info("$ModuleName configuration file $configFilename")
    $Log4n.Info("Calling script path: $(Split-Path $MyInvocation.MyCommand.path)")
}

# SIG # Begin signature block
# MIIHSgYJKoZIhvcNAQcCoIIHOzCCBzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBJB6HDL8g+Lh6a
# c66mV8/IsUp1bF1su/hr8B9SQEm7CqCCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
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
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIDac5ApU
# olmMvZuoKlbyQaPlWpy6yvxO7Gjw6fXZ/Fu5MA0GCSqGSIb3DQEBAQUABIIBgLuy
# 4FeKDrmZQxfrVAkTJzoatOrEWgvm/Crmj3VDF7KvyecZyVd4JQvQZF1SdySGi/TX
# efCzpth+lYWAVLdvZf3+9JVC5+sICuO3AOBtcDO17vlLHVNo3Qz+Rq97LP6Wknim
# 5UWwz61NTBeSKHS5cIRaTGYwyUW5LSNvk0RujVwBBzf2eRn+XYu4F+H6G/5HIhfN
# TeS9WzrUbM/7CE8HMAT7ww37huc/VWtwOB0972qXGp6aj4/y+3/v2D+ZPuf8IIhu
# EXQz7HWq2nX/3xa1+xsLFhgqlLGMS5k0IZFnw8SA2r1rgE7ZfPOrgfmVZeCiPKdF
# jsJTBVOQeUWqV0ElcJdzVXvUaznVBi+vjJNUXzztsemgaH2Fik1+K0dyC/D4+Hi/
# +pIs+HOEefvBTSTCoeF6NIePZ5gnvpNyY5pPqTPcR23airFK0gWC/J+ukK5NFiMn
# i/ZarCGBRuC4BSKe7/kMjAKoHpCPU4ZmfRSfd3eOPxl/wY0dyY5Off4zzR8Crg==
# SIG # End signature block
