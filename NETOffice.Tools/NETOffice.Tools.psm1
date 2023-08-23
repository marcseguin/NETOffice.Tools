
function Start-Logging {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>
    param(
        [string] $Filename = ''
    )
    try {
        $configFilename = Find-Configurationfile $Filename
        Write-Debug "Filename $Filename"
        if ([string]::IsNullOrEmpty($configfilename)) {
            Throw "no log4net configuration file $filename found!" 
        }
        [void][Reflection.Assembly]::LoadFile("$ModulePath\log4net.dll")
        [log4net.LogManager]::ResetConfiguration()
        [log4net.Config.XmlConfigurator]::Configure([URI]$configFilename)
        $Global:Log4n = [log4net.LogManager]::GetLogger('root')
        $Log4n.Info('***** Logging started *****')
        $log4n.Info("Log configuration file : $configFilename")
        $log4n.Info("Log file : $($log4n.Logger.Parent.Appenders.file)")
    } catch {
        throw
    }
}

function Stop-Logging {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    try {
        $Log4n.info('***** Logging stopped *****')
        Remove-Variable -Name 'Log4n' -Scope 'Global'
        [log4net.LogManager]::ResetConfiguration()
    } catch {
        throw 'An error happend when trying to stop the log4net logging faciliy.'
    }
}

function Write-LogDebug {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>


    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.debug($message)
}

function Write-LogInfo {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>


    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.info($message)
}

function Write-LogWarn {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>


    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.warn($message)
}

function Write-LogError {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>


    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.error($message)
}
    
function Write-LogFatal {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>


    Param(
        [Parameter(position = 0, Mandatory = $true)] [string] $message
    )

    if (!$log4n) {
        Start-Logging
    }
    $log4n.fatal($message)
}
    
function Read-Credentials {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    Param(
        [Parameter(Mandatory = $true)] [string] $FileName) 

    try {
        if (Test-Path -Path $FileName -PathType Leaf) {
            Write-LogInfo "Loading Credential file '$FileName'"
            $credential = Import-Clixml $FileName
        } else {
            Write-LogInfo 'Quering Credentials...'
            Write-Host 'Die Anmeldeinformationsdatei ' -NoNewline -ForegroundColor Yellow  
            Write-Host $filename -NoNewline 
            Write-Host ' existiert nicht. Geben Sie die Anmeldeinformationen manuell ein.' -ForegroundColor Yellow  

            $credential = Get-Credential 
            $decision = $Host.UI.PromptForChoice("Anmeldeinformationsdatei '$FileName' speichern", 'Sollen die Zugangsdaten fuer spaetere Zugriffe gespeichert werden (Das Kennwort wird verschluesselt gespeichert)?', @('&Ja', '&Nein'), 0)
            if ($decision -eq 0) {
                Write-LogInfo "Saving Credential file $filename"
                Export-Clixml -Path $FileName -InputObject $credential
            } else {
                Write-LogInfo "Credential file '$FileName' won't be saved."
            }
        }
        return $credential
    } catch {
        Write-LogError "$_`r`n$($_.InvocationInfo.PositionMessage)"
        throw
    }
}

function Get-Choice {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

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

function ConvertFrom-FileTime {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    param(
        [Parameter(ValueFromPipeline, Position = 0, Mandatory = $true)] [long] $FileTime
    )
    if ($filetime -eq 0) {
        return $null
    } else {
        return [datetime]::FromFileTime($FileTime)    
    }
}

#region Script Diagnostic Functions

function Get-CurrentLineNumber {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    $MyInvocation.ScriptLineNumber
}

New-Alias -Name __LINE__ -Value Get-CurrentLineNumber -Description 'Returns the current line number in a PowerShell script file.' -Force

function Get-CurrentFileName {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    $MyInvocation.ScriptName
}

New-Alias -Name __FILE__ -Value Get-CurrentFileName -Description 'Returns the name of the current PowerShell script file.' -Force
#endregion

function Add-CodeSignature {
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    ## Signs a file
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
    <#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    ## Signs a file
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]
        $Path

    )
    $Enc=Get-Encoding -Path $Path
    $content=Get-Content -Path $Path -Raw -Encoding $Enc.Encoding
    $content=$content -replace '# SIG # Begin signature block((.*\n)*)# SIG # End signature block',''
    $content|Out-File -FilePath $path -Encoding $Enconding.Encoding    
}

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
        if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
        { $enc = [Text.Encoding]::UTF7 }
        if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
        { $enc = [Text.Encoding]::Unicode }
        if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
        { $enc = [Text.Encoding]::BigEndianUnicode }
        if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
        { $enc = [Text.Encoding]::UTF32 }
        if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
        { $enc = [Text.Encoding]::UTF8 }
        
        [PSCustomObject]@{
            Encoding = $enc
            Path     = $Path
        }
    }
}


function Export-SignerCertificate {
<#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

    param(
        [string] $Filename,
        [string] $SignerCertificateFilename
    )
    $cert = (Get-AuthenticodeSignature -FilePath $Filename -ErrorAction:Stop ).SignerCertificate
    if ($null -eq $cert) {
        throw "$($MyInvocation.MyCommand): Cannot read certificate from '$Filename'."
    }
    if ([string]::IsNullOrEmpty($SignerCertificateFilename)) {
        $SignerCertificateFilename = "$($cert.Thumbprint).cer"
    }
    Export-Certificate -FilePath $SignerCertificateFilename -Cert $cert
}

function Find-Configurationfile {
<#
.EXTERNALHELP NETOffice.Tools-help.xml
#>
    param(
        [string] $Filename
    )

    if (Test-Path -Path "$env:appdata\$Filename" -PathType:Leaf) {
        return "$env:appdata\$Filename"
    } elseif (Test-Path -Path "$env:programdata\$Filename" -PathType:Leaf) {
        return "$env:programdata\$Filename"
    } elseif (Test-Path -Path "$ModulePath\$Filename" -PathType:Leaf) {
        return "$ModulePath\$Filename"
    }
    return $null
}


##############################
# Module initialisation
##############################
$ModuleName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Source)
$ModulePath = [io.path]::GetDirectoryName($MyInvocation.MyCommand.Source)
$configFilename = Find-Configurationfile -Filename "$Modulename.config.json"
Write-Debug "Module Name $ModuleName"
Write-Debug "Module Path $ModulePath"
Write-Debug "Module configuration file $configFilename"
if ([string]::IsNullOrEmpty($configFilename) -eq $false) {
    $script:config = Get-Content $configFilename | ConvertFrom-Json
} else {
    throw [System.IO.FileNotFoundException] "Configuration file $Modulename.config.json not found!`nDepending on your environment you must place it in %appdata% or %programdata%."
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
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDTeUUTYIebOm4l
# MCUcm95mhDhxf/ITDm26QbVGzK4yUaCCBDkwggQ1MIICnaADAgECAhAwsvZHii5x
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
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIIP2ThY8
# ofb+Nb5DTRSOfM5KXwCiJHHs/d8VeaH0+3+aMA0GCSqGSIb3DQEBAQUABIIBgEvb
# icjcp/B6glWTO8f6MYmuGc7XcVDZ7F8Su++n6AEdVCH3r1xIZPTWAVtmOsXu8O/B
# 3oPDC3K0eyWtJb9pIhSkO0jkqZAEYgpuKWx/0IcJiRlcjT1I0Q8cgbCQHrN8Q3Cd
# svKyuewovQWCisAQS2UKZGR+HHdGcunVu72Kksp2jkViBn+Ome4GkXJUesk9RP+I
# v6JWkK9Cl+g/w/H5HktexQszYha0k+ZlTaL5CuW17lR8UKXDiIuMHvYLuiOGmleD
# SlBu5Mo1pk/znp+UbgV8pWmfIXj8LvVyTHC/Y5TJj0Gn0C/uDQnzeleTqKyQ+42G
# WTe9q+3rm1CiskwyaHpGWN99KBq2h79MF1q0qbjQEtkM8VT9gZ8avLSnq3s0cTc4
# 7VE3GelU7RAvOMake02T9ntlDraUAveq5pX4ySf3FpTyhlu5ZjOmL0pFpvRZdT1x
# PgOUVTGiKq1KYEJBFNOXhDJMw454asUxfEif+9QC7bYualdx9C7+rMI2/FsAfA==
# SIG # End signature block
