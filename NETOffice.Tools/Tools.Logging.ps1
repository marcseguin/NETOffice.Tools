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
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm01SdwjuB+DTfxhL9LXUofHY
# iPWgggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUkXbSHooK1Nz9tBf7P/3O/sIaGKowDQYJKoZIhvcN
# AQEBBQAEggGAm9J9OdyHKVsHaZRkCBx9AZAOpPMjDVNqp5A1ktGcslCP+sSKnqAb
# EqO5CiZ7kvVEJNBXiUg69OlsfL5beZMYyTpv+6ktbt+qxqnOYoR9rR0RtVaoOhhN
# N54lSEm/dBuR2pZzVkGcy8c9vDO+YD2K7qM7Jlbowsfu8rzVsbEhNyZorTMQUd5f
# ZqP9vNwyvUw1hIh1zporzR340K+vd0k3+voaw/zPJSrxI6qTvc3i+mbvcs+jzlxB
# oSqcAyk3xtcbM0tTsRz/HEGascb6KEIMvnv/OS4vYMgYUXHEpLYdv7BAOmlFVhqp
# bYZx8YmOF1TFIN+elhl5041Evom+YRadLHDpz7Xhg2lwfx98wj5a7bEXnDEc4cKB
# itLG6mZb3NJgdNZnbvrU6A53jR3RZvgEcogpNwCHpUX5fQ3sBg3LrgT9AVFlDxgO
# kUzIMqoMmP/SpPy3vQ2MZl++o980kWOHbQjVgb7D6iIhON2ltQmWViE0oTZeRImc
# 8hOWvJbZRzQC
# SIG # End signature block
