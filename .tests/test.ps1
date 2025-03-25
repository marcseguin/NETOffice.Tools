.support\sign-Scripts.ps1
Remove-Module NETOffice.Tools -Force
Import-Module "./NETOffice.Tools/NETOffice.Tools.psm1" -Force

$a=[PSCustomObject]@{
    Name='Adam'
    Age=30
    Address=@{
        Street='123 Main St'
        City='Anytown'
        State='TX'
        Zip='12345'
    }
}
$b=ConvertTo-Hashtable -InputObject $a
