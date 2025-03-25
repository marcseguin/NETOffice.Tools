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
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUR/DrkNZjr4R4wweSqtVbe0F3
# oJCgggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUw60Hn9deaefr4z2keSLz7yG43k4wDQYJKoZIhvcN
# AQEBBQAEggGAo1mjZ019EryTMZcQFdLYDfgHpftwCb2Gg+nwplYOHwcyADHffjci
# mYOYt8gJi3vr9m5ZgeR1iFI3zXKa2HB6T4haXhdRSgh6Rq+9JjdM2f9i0Yz0eyp+
# LkkUuwpOjgG9FKzn2ioErRBzqVw72WY1HLkFgmceC0J7frcn3DlQs+3zzRDuhUg6
# +IgZegvg/GPf4ReRrAqnJ2CU8GVeGIF5y6g11+WdqhKpU5m/FNFRLXLf0PcIr9ed
# 0ucc0L3D9/7K+42vurAsDhdTMa74ay/V53hG5AHV0bVGXCeob2Xlb6qcLY0Fm7Dm
# +jEEKntrxUQqPGG2laZiolF6g8F4RDJKv8GaR9nPXoKIzYtKe1uFV4y/7M3JCsht
# jE4RhTHWcbt4msbIqo4ZQTTyQw2z63ZmmMPqoYwvK5wCw4tgEr6KzWxy3ILmuzB2
# owmQhtePTXuLT9LrcV8M9ixcVsUWOBMKezmLDAobWcMvcoLs61fHVrD/G/C8LNmg
# gN/MPrUqJycv
# SIG # End signature block
