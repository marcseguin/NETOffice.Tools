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
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7LbGM7FEk11Y8JR+aAgwhNta
# 33+gggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUBLMrjp1YdceL/f627ErjIuEdj3EwDQYJKoZIhvcN
# AQEBBQAEggGAsLA/WTu1xNgWrQrQTi5xfzacn3p3kynmbBopAWJOuGXSxra+c2qF
# ArPuvIvuCXbLm/yqLzEAuEeFEpHppYz93LOlNDXUwWLl5VB55IyqOVkl/q63HHnu
# 8OnUcV/LfpnE9UUDst03xgRmjH1k/XvGn+1jnN3T1MiUy9qwHwKxNT/6Uvg0TYp/
# sDFK2o4dFF/eqEze5F23M34R3HiYSxjT/Ts4uhXkuxQDsEPXXgw1T61l96nXVL4C
# sBdfuaxJeBWWTjRvF5X2K6w9wYKsMnXg48Ad1nDAIAxFKXVvZYbem4C9d/qrGTY3
# eWVvUcp/hyWHANo3s0XbW6eRckBS3F5PlyH/+tUxG+6bZ2C8WEKivcRtTBuIu1Ze
# CxycYw7avC7vmqPwrooISyIYGJR5DhrhU5XRAliGbCstfyfFDgKHQcUb1HwV5Lfj
# YXj0gP2qHlDkubmXma0kBQQD2/v3DiPAFdQOZlZOQ6DhBr/+qpfir+r+OGfND/O6
# ghxyMN0MdnLn
# SIG # End signature block
