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
[CmdletBinding(SupportsShouldProcess,ConfirmImpact="High",PositionalBinding=$false)] # PositionalBinding=$false allows us to use dynamic Name w/o -Name
[OutputType([Bool])]
param(
[switch] $NoNameValidate,
[string] $Path
)

dynamicParam {
	makeDynamicParam -ParameterName "Name" -ValidateSetScript {
		if ( !((Test-Path variable:NoNameValidate) -and $SkipNameValidate))
		{
			if (!((Test-Path variable:Path) -and $Path))
			{
				$Path = $null # can't pass in undefined path
			}
			Find-ConfigData -Path $Path
		}
	} -Mandatory -ValueFromPipeline
}

process
{
    Set-StrictMode -Version Latest
	$Name = $psboundparameters["Name"]

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
}

New-Alias -Name rcd -Value Remove-ConfigData