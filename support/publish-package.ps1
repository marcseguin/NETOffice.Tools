$PackagePath='NETOffice.Tools'
if (!($env:PSModulePath -match ";$PackagePath")){
    $env:PSModulePath +=";$PackagePath"

}
$manifest = Import-PowerShellDataFile NETOffice.Tools\NETOffice.Tools.psd1 
[version]$version = $Manifest.ModuleVersion
[version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
Update-ModuleManifest -Path ".\$PackagePath\NETOffice.Tools.psd1"  -ModuleVersion $NewVersion
Add-CodeSignature -Filename ".\$PackagePath\NETOffice.Tools.psm1"
Add-CodeSignature -Filename ".\$PackagePath\NETOffice.Tools.psd1"
Import-module ".\$PackagePath\NETOffice.Tools.psd1" -Force

Publish-Module -name netoffice.tools -Repository:LocalPSRepo -NuGetApiKey 'oy2lvlwpy7z3gunab6uae7t6ogqclmtepgccnmaplw2fh4'
