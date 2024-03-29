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
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU20/L50ivHtWCp7gry+4noNpa
# vTegggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUgFqtU0JAXyBo7f9DyDL2PNvEawMwDQYJKoZIhvcN
# AQEBBQAEggGAljfN+uCqSFkHuX0ElqzItw55KcT/0kdYoOPdvTX90/i4XxwCN7Pl
# 5pIbkxQIbDZwgvk5uD6E7dRHRl9Iehrc+1E/wzcp0OaIjuSXc2zOM0tMcVMiytw7
# rfZRn73xYSnb+pceS34hBPsGDLtgpHyMbSdKSHGD1ryDKywAwCqQ8vWFTSbbK43l
# 0u23rP6wvYmZBlZXyw32nTNvsxXcLXWqHkPumx/iYQ3lNE6iGNXgk2wCFPD1z5Ne
# w+E+Y5Ganc1+cf18kHE1fH8xZ//yhumN36IjsJ1W7wtaBCFrqw/MIRoy3OEkpcD9
# 5CjXONH3sVZ/MlRnM017llq5ox92T++t/4NODRDmmOjBpwlTDlzMU8vZmbo2Wpn/
# sEqlT/VpVix1/6kaubeXwwwLiVm3zeD3Ts0aPQzDblO2QojNOAC56zBRBRk5zKio
# kOVD9Wxo3FjFaZ5K7wiBuXsoLMeGKP4DgIidpGiHmjUVtMinvTl0WnFTuR+m1I7e
# ZT0rvp5cWR6L
# SIG # End signature block
