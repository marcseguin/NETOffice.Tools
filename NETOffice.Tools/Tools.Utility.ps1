Function Read-Credentials {
    [CmdletBinding(DefaultParameterSetName = 'Filename')]    
    Param(
        [parameter (ParameterSetName='Filename')] [string] $Filename="$env:USERPROFILE\.PSCredentials\$env:username.PScred",
        [parameter (ParameterSetName='Username')] [string] $Username="$env:username.PScred") 
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Username') {
            # Entferne unerlaubte Zeichen aus dem Benutzernamen entfernen und daraus den Dateinamen bilden
            $Username = $Username -replace '[<>:"/\\|?*]', '_'
            $FileName = "$env:USERPROFILE\.PSCredentials\$Username.PScred"
        }
        if (Test-Path -Path $FileName -PathType Leaf) {
            Write-LogInfo "Loading Credential file '$FileName'"
            $credential = Import-Clixml $FileName
        }
        else {
            if (-not (Test-Path -Path "$env:USERPROFILE\.PSCredentials" -PathType:Container)) {
                New-Item -Path "$env:USERPROFILE\.PSCredentials" -ItemType Directory -Force
            }    
            Write-LogInfo 'Requesting Credentials...'
            Write-Host 'Die Anmeldeinformationsdatei ' -NoNewline -ForegroundColor Yellow  
            Write-Host $filename -NoNewline 
            Write-Host ' existiert nicht. Geben Sie die Anmeldeinformationen manuell ein.' -ForegroundColor Yellow  

            $credential = Get-Credential 
            $decision = $Host.UI.PromptForChoice("Anmeldeinformationsdatei '$FileName' speichern", 'Sollen die Zugangsdaten fuer spaetere Zugriffe gespeichert werden (Das Kennwort wird verschluesselt gespeichert)?', @('&Ja', '&Nein'), 0)
            if ($decision -eq 0) {
                Write-Credentials -Filename $FileName -Credential $credential
                Export-Clixml -Path $FileName -InputObject $credential
            }
            else {
                Write-LogInfo "OK - Credential file '$FileName' won't be saved."
            }
        }
        return $credential
    }
    catch {
        Write-LogError "$_`r`n$($_.InvocationInfo.PositionMessage)"
        throw
    }
}

Function Write-Credentials {
    Param(
        [Parameter(Mandatory = $true)] [string] $Filename,
        [Parameter(Mandatory = $true)] [System.Management.Automation.PSCredential] $Credential
    )

    try {
        if (-not (Test-Path -Path "$env:USERPROFILE\.PSCredentials" -PathType:Container)) {
            New-Item -Path "$env:USERPROFILE\.PSCredentials" -ItemType Directory -Force
        }    
        Write-LogInfo "Saving Credential file $filename"
        Export-Clixml -Path $FileName -InputObject $Credential
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

Function Get-PersistentCounter {
# Depending on the scope parameter, for "maschine" the function reads the a persitent counter from the value {name} in the Key HKEY_Local_Machine\Software\NETOffice.Tools\PersistentCounter;
# For "user" it reads the a persitent counter from the value {name} from key HKEY_Current_User\Software\NETOffice.Tools\PersistentCounter.
# The function returns 0 if the value or the key does not exist.

    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [ValidateSet("user", "maschine")] [string] $Scope='user'

    )
    if ($Scope -eq 'user') {
        $regKey = 'HKCU:\Software\NETOffice.Tools\PersistentCounter'
    }
    else {
        $regKey = 'HKLM:\Software\NETOffice.Tools\PersistentCounter'
    }

    try {
        return [int32] ((Get-ItemProperty -Path $regKey -Name $Name).$Name)
    }
    catch {
        throw "The persistent counter '$Name' does not exist in the '$Scope' scope."
    }
}

Function New-PersistentCounter {
    # Depending on the scope parameter, for "maschine" the function creates a persitent counter from the value {name} in the Key HKEY_Local_Machine\Software\NETOffice.Tools\PersistentCounter;
    # For "user" it creates a persitent counter from the value {name} from key HKEY_Current_User\Software\NETOffice.Tools\PersistentCounter.
    # If key or value does not exist, it is created.
    # The function returns the new value of the counter.

    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [ValidateSet("user", "maschine")] [string] $Scope='user',
        [Parameter(Mandatory = $true)] [int] $InitialValue=0
    )
    if ($Scope -eq 'user') {
        $regKey = 'HKCU:\Software\NETOffice.Tools\PersistentCounter'
    }
    else {
        $regKey = 'HKLM:\Software\NETOffice.Tools\PersistentCounter'
    }
    $value = $InitialValue
    if ((Test-Path $regKey) -eq $false) {
        New-Item -Path $regKey -Force
    }
    $null=New-ItemProperty -path $regkey -Name $Name -PropertyType:DWORD -Value:$value -Force    
    return [Int32] $value
}
Function Increment-PersistentCounter {
    # Depending on the scope parameter, for "maschine" the function increments the a persitent counter {name} in the Key HKEY_Local_Machine\Software\NETOffice.Tools\PersistentCounter by the value of {increment};
    # For "user" it increments the a persitent counter  {name} in key HKEY_Current_User\Software\NETOffice.Tools\PersistentCounter by the value of {increment}.
    # If key or value does not exist, it is created and set to the value {increment}.
    # The function returns the new value of the counter.

    param(
        [Parameter(Mandatory = $true)] [string] $Name,
        [ValidateSet("user", "maschine")] [string] $Scope='user',
        [int] $Increment=1
    )
    if ($Scope -eq 'user') {
        $regKey = 'HKCU:\Software\NETOffice.Tools\PersistentCounter'
    }
    else {
        $regKey = 'HKLM:\Software\NETOffice.Tools\PersistentCounter'
    }
    
    try{
        $value = (Get-PersistentCounter -Name $Name -Scope $Scope -ErrorAction:Stop) +$Increment
        Set-ItemProperty -path $regkey -Name $Name -Value $value
        return [Int32] $value
    }
    catch {
        New-PersistentCounter -Name $Name -Scope $Scope -InitialValue $Increment
        return [Int32] $Increment
    }
}

Function ConvertTo-Hashtable {
    <#
        .SYNOPSIS
            Converts a PSCustomObject into a hashtable for Windows PowerShell

        .NOTES
            Author: Adam Bertram
            Link: https://4sysops.com/archives/convert-json-to-a-powershell-hash-table
    #>
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        $InputObject
    )

    Process {
        ## Return null if the input is null. This can happen when calling the function
        ## recursively and a property is null
        If ($Null -eq $InputObject) {
            Return $Null
        }

        ## Check if the input is an array or collection. If so, we also need to convert
        ## those types into hash tables as well. This function will convert all child
        ## objects into hash tables (if applicable)
        If ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @()
            foreach ($object in $InputObject.GetEnumerator()) {
                # Ensure that each item is processed individually without self-reference
                $convertedObject = ConvertTo-Hashtable -InputObject $object
                $collection += $convertedObject
            }   
            Write-Output -NoEnumerate -InputObject $collection
        }
        ElseIf ($InputObject -is [psobject]) {
            ## If the object has properties that need enumeration
            ## Convert it to its own hash table and return it
            $hash = @{ }
            ForEach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        }
        Else {
            ## If the object isn't an array, collection, or other object, it's already a hash table
            ## So just return it.
            $InputObject
        }
    }
}



    

# SIG # Begin signature block
# MIIHJQYJKoZIhvcNAQcCoIIHFjCCBxICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU59TX7fxyOuieREdTiRJT4kz6
# IUigggQ5MIIENTCCAp2gAwIBAgIQMLL2R4oucYVE6cInFCbeDDANBgkqhkiG9w0B
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
# FTAjBgkqhkiG9w0BCQQxFgQUeNnu4Q07VBw+/RORq/7jCT8M5gIwDQYJKoZIhvcN
# AQEBBQAEggGAYwjzBOFXqsUrycmcpS2kVpkRYM6j/LUdCvd8hUa/ztD+wrtIlnco
# Po0gejBwAcK3wnOuYwsKeFmlqN7V2QFywI12VOrWRmnk7SHZuiSvFdLuQPQ5hg3J
# asBTayk/XCKkbTA8/mFFhD9pc5dsllLsaj0+iOmSW0B5d57+Pl+YQIpZ21S3ta7l
# 195cdcMdbvEKj+crlWb3OemQmhbByXTb9H5ryjCftqeood78AW+kWMzfSG7hbHqA
# rghsApbA4+tBhOh069KTM75bNwHXkyaoeZ0pVRyy3BdVSy2rmZmaeHTQJE0YJhwg
# PgE0TzBSpuSvMp+SMNy8AYyYXSwLCp+qh3Q86ESJAXkBHoRnmQS4L7rytVbxqERP
# YEXyoEVmE0QjAyrQVupn7gTPy0alQ7sro8PmDxF01b1J11INk8FLLV93r4B4pb5B
# DSIZN1z2RXnf2J4W+FS+L/sytEWVhqR4i9pqUW7oahPeRbIQIPrUHPXAjVtW4m3A
# aEi23vBu213/
# SIG # End signature block
