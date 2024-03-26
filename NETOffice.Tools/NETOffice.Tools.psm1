# Module: NETOffice.Tools


class EncyptedPSCredential {
    hidden [string]$_Credential;
    hidden [System.Security.Cryptography.X509Certificates.X509Certificate2]$_Certificate;

    EncyptedPSCredential([pscredential]$Credential,[System.Security.Cryptography.X509Certificates.X509Certificate2] $certificate)  {
        $this._Credential= $Credential
        $this._Certificate = $certificate
    }
    [pscustomobject] GetEncrytedData() {
        $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($this._Certificate)
        $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($this._Credential.GetNetworkCredential().Password)
        $encryptedBytes = $rsa.Encrypt($bytesToEncrypt, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
        $encryptedPassword = [Convert]::ToBase64String($encryptedBytes)
        $encryptedUsername = $this._Credential.GetNetworkCredential().UserName
        return [pscustomobject]@{
            EncryptedUsername = $encryptedUsername
            EncryptedPassword = $encryptedPassword
        }
    }    
}

function ConvertTo-EncryptedText
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $ClearText,
        [Parameter(Mandatory = $true)] [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($Certificate)
    $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($ClearText)
    $encryptedBytes = $rsa.Encrypt($bytesToEncrypt, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
    $encryptedText = [Convert]::ToBase64String($encryptedBytes)
    return $encryptedText
}

function ConvertFrom-EncryptedText
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)] [String] $EncryptedText,
        [Parameter(Mandatory = $true)] [System.Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
    )
    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate)
    $encryptedBytes = [Convert]::FromBase64String($EncryptedText)
    $decryptedBytes = $rsa.Decrypt($encryptedBytes, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1)
    $decryptedText = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    return $decryptedText
}

function Start-Logging {
<#
.EXTERNALHELP NETOffice.Tools-help.xml
#>

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

    $pathsToCheck = @(
        $Filename,
        "$env:programdata\sensu\config\$BaseFilename.config.json",
        "$Global:BaseFileDirectory\$BaseFilename.config.json"
    )

    # W�hle den ersten existierenden Pfad aus
    $configFile = $pathsToCheck | Where-Object { -not [string]::IsNullOrEmpty($_) -and (Test-Path -PathType Leaf -Path $_) } | Select-Object -First 1


    return $configFile
}


##############################
# Module initialisation
##############################
$CallStack = Get-PSCallStack
$CallStack|ConvertTo-Json -Depth 1|Write-Host
$ModuleName = [io.path]::GetFileNameWithoutExtension($CallStack[0].ScriptName)
$ModulePath = [io.path]::GetDirectoryName($CallStack[0].ScriptName)
if ($null -ne $CallStack[1].ScriptName){
    $ScriptPath = [io.path]::GetDirectoryName($CallStack[1].ScriptName)
}
else {
    $ScriptPath = '.\'
}
Write-Host $ModuleName
Write-Host $ModulePath
Write-Host $ScriptPath

# Look after configuration files

$pathsToCheck = @(
    "$ScriptPath\$ModuleName.config.json",
    "$ModulePath\$ModuleName.config.json"
)

Write-Debug "Module Name $ModuleName"
Write-Debug "Module Path $ModulePath"
Write-Debug "Module configuration file $configFilename"

# W�hle den ersten existierenden Pfad aus
$configFilename = $pathsToCheck | Where-Object { -not [string]::IsNullOrEmpty($_) -and (Test-Path -PathType Leaf -Path $_) } | Select-Object -First 1
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaOvm7/Leo0fXooI1AZeSk1ye
# NfWgggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUYIv+CFln/7xKB0T4gsifR3BBYYUwDQYJKoZIhvcN
# AQEBBQAEggGAoxYj1QPMRGFP364AUxEADQqI15hNXW8WGvfvBrY+neKoTxIFi0vk
# GFg0sVkvlZLGxTp0lcomNVeDbUcnm4XtUnu89LfQniQDIHI+VtD781N/K3jqo1dJ
# hivf0xZpM77Y69TYnk4EQuFv0XEVzdbSbA3t+3ILZDhVTpDS5lRLrbiKuaY8y8z0
# 7utZWNlbrq17hVf/kJDwTsBAG5q85rjNYFoY1/29TVNQm0FMb0HOXcqVgdqJnBvE
# ndRm+YrwYcxOZr5TJ0+BRrHKnBox79MYtqhbDCFotM9uKGicAEu2OnRpOfQ1tOA+
# +Kvv71lCJ5zLDMCeuMQ6wo6dwOcM0sHJnS3eSjl+uAgBEDreRcMfHTWa42X+0FGs
# 3SmdaVcK8n2X/o126keSt5xEoEmUpSmNTpFpxUqn5R+fN/GoT1z8ywArnZ/Wioqc
# dXX00ULVuBNFFfD5uxmzFiWdjBbw+aFqsogW3F7muskep3XdUTbJNwCE63Qqddzb
# pU2o1aBtZmgO
# SIG # End signature block
