function Start-Logging {
    
    param (
        [Parameter()]
        [string]
        $Filename=""
    )
    try {
        if ($Filename -eq "") {
            $Filename=invoke-expression "`"$($config.Logging.ConfigFilename)`""
        }
        if (-not (Test-Path -Path $Filename -PathType Leaf)) {
            Throw "no log4net configuration file $Filename found!" 
        }
        $configurationFile=Get-Item -Path $Filename
        [void][Reflection.Assembly]::LoadFile("$ModulePath\log4net.dll")
        [log4net.LogManager]::ResetConfiguration()        
        [log4net.Config.XmlConfigurator]::Configure([URI]$configurationFile.FullName)
        $Global:Log4n = [log4net.LogManager]::GetLogger('root')
        $Log4n.Info('***** Logging started *****')
        $log4n.Info("Log configuration file : $($configurationFile.FullName)")
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
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZEOKkFNzulmVpuEsDbWdeaWn
# iIygggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUIquhF3Ko8DZt1gCtXzj+1BTyFdkwDQYJKoZIhvcN
# AQEBBQAEggGAT0BHOaX9pCkJfKvC3kSTCPHYTTIiIyWMcSAPGPjeGMFMWDLOcPKc
# PLLClJm7AaWmMApP3lbusmD66xPSSzcKykCwlIggcHCp28Ij+eH9+lAG/14Y4Ruv
# mjuEspMqdgmabrF31oTaW2iH12qukJiwdIarbwA11BzADRXiKSFI+2YlMlzptdks
# bD8cJmTziJIu6aa8L8xOs5Ik9lHb1/XGlIGHFPVro0ZXHE9M8YqYrCAXx2+1Qexu
# 1qbEddO1reZWib861OjG3Ed5DXOtNiIlA/YEhjw1L/8vMjj7EWhEoOiI1CFjfyYq
# U6f8ggTmJFq7tLuj7tdIW49+eabwtIb4LY/7ksdC83v+QMlziwvXtP8T/U9Eiqoq
# qxMi2tlA/kMZoQxYvdieyfT1p6/epadtGVOd3zHBrByIq+dFEYPO4UN1LAQUbr+w
# yfRqil5uZERTvOzCgaMYocSnrxPCvwGilpaVKuvVh44Qsh5ANdneelOh/1DjCFqm
# F0a22U4PpBCd
# SIG # End signature block
