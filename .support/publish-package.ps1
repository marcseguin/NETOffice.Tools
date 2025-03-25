Remove-Module NETOffice.Tools -Force
Import-Module "./NETOffice.Tools/NETOffice.Tools.psm1" -Force

$PackageName='NETOffice.Tools'
if (!($env:PSModulePath -match ";$PackageName")){
    $env:PSModulePath +=";$PackageName"

}
$manifest = Import-PowerShellDataFile NETOffice.Tools\NETOffice.Tools.psd1

$FunctionNames = Get-ChildItem Function: |
    Where-Object { $_.Module -and $_.Module.Name -eq $PackageName } |
    Select-Object -ExpandProperty Name

[version]$version = $Manifest.ModuleVersion
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
Update-ModuleManifest -Path ".\$PackageName\NETOffice.Tools.psd1"  -ModuleVersion $NewVersion -FunctionsToExport $FunctionNames
.\.support\sign-Scripts.ps1


Publish-Module -path "$((Get-item .).FullName)\$PackageName" -Repository:PSRepo -NuGetApiKey "PSRepo" -Force
