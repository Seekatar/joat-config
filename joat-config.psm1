
foreach( $i in (Get-ChildItem (Join-Path $PSScriptRoot "*.ps1") -File -Exclude *.tests.ps1 -Recurse) )
{
    . $i
}

Export-ModuleMember -Function "Find-ConfigData","Get-ConfigData","Set-ConfigData","Remove-ConfigData","Get-ConfigDataPath" -Alias *