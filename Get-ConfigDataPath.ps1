<#
.SYNOPSIS
Get the path to the config file, if empty

.PARAMETER Path
Optional path name

.OUTPUTS
The path to the config file
#>
function Get-ConfigDataPath
{
[CmdletBinding()]
param(
[string] $Path
)

Set-StrictMode -Version Latest

if ( -not $Path )
{
    if ( $env:joat_config_path )
    {
        $Path = $env:joat_config_path
    }
    else
    {
        if ( $env:home ) # for some reason in VSCode and ICE, no $HOME
        {
            $Path = "$env:home/myconfig.json"
        }
        elseif ( $env:HOMEDRIVE -and $env:HOMEPATH )
        {
            $Path = "$env:HOMEDRIVE$env:HOMEPATH/myconfig.json"
        }
        else
        {
            throw "Can't determine default path."
        }
    }
}

$Path

}

New-Alias gcdp -Value Get-ConfigDataPath