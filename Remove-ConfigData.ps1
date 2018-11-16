<#
.SYNOPSIS
Removes data in a JSON config file

.PARAMETER Name
Name of the config data to remove

.PARAMETER Path
Path to the config file

.OUTPUTS
$True if found and removed, $False if not found or file doesn't exist
#>
function Remove-ConfigData
{
[CmdletBinding(SupportsShouldProcess)]
[OutputType([Bool])]
param(
[Parameter(Mandatory)]
[string] $Name,
[string] $Path
)
    Set-StrictMode -Version Latest

	$Path = Get-ConfigDataPath $Path

	$object = $null
	if ( Test-Path $Path -PathType Leaf)
	{
		$object = Get-Content $path -Raw | ConvertFrom-Json

        if ( Get-Member -InputObject $object -Name $Name )
        {
            $object.PSObject.Properties.Remove($Name)
            if ( $PSCmdlet.ShouldProcess($Path,"Remove ConfigData $Name"))
            {
                Set-Content $path -Value (ConvertTo-Json $object)
            }
            return $true
        }

	}

    $false
}

New-Alias -Name rcd -Value Remove-ConfigData