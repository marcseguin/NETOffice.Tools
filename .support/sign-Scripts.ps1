Import-Module .\NETOffice.Tools\NETOffice.Tools.psd1 -Force
$PackagePath='NETOffice.Tools'
if (!($env:PSModulePath -match ";.\\$PackagePath")){
    $env:PSModulePath +=";.\$PackagePath"

}
foreach ($file in Get-ChildItem ".\$PackagePath" -Recurse -Include *.ps1,*.psm1,*.psd1){
    Add-CodeSignature -Filename $file.FullName
}
