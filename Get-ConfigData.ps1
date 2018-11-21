<#
.SYNOPSIS
Get data from a JSON config file

.PARAMETER Name
Name of the config data to get.  Supports tab completion

.PARAMETER AsSecureString
Return the encrypted data as a SecureString

.PARAMETER Decrypt
Return encrypted data in clear text

.PARAMETER Quiet
Don't kick out a Warning message if not found

.PARAMETER Path
Path to the config file

.EXAMPLE
Get-ConfigData Key

.OUTPUTS
Object from config file, or $null
#>
function Get-ConfigData
{
[CmdletBinding(PositionalBinding=$false)] # PositionalBinding=$false allows us to use dynamic Name w/o -Name
[OutputType([string],[PSCustomObject])]
param(
[switch] $AsSecureString,
[switch] $Decrypt,
[switch] $Quiet,
[switch] $SkipNameValidate,
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
	}  -Mandatory -ValueFromPipeline
}

process
{
	Write-Verbose "Path is $Path"
	Set-StrictMode -Version Latest
	$Name = $psboundparameters["Name"]

	$Path = Get-ConfigDataPath $Path

	if ( -not (Test-Path $Path -PathType Leaf))
	{
		throw "Path $Path not found"
	}
	Write-Verbose "Getting $Name from $Path"

	$object = Get-Content $path -Raw | ConvertFrom-Json

	$value = $null
	$member = Get-Member -InputObject $object -MemberType NoteProperty  | Where-Object Name -eq $Name | Select-Object -ExpandProperty name
	if ( !$member  )
	{
		if ( !$Quiet )
		{
			Write-Warning "Didn't find value named $name in $path"
		}
	}
	else
	{
		$value = $object.$member
		if ( $PSVersionTable.PSVersion.Major -gt 5 -and -not $IsWindows )
		{
			$decryptedtString = $false  # Core 2.0 doesn't support encrypt/decrypt
			if ( $AsSecureString )
			{
				Write-Warning "AsSecureString not supported in PS Core"
				return ""
			}
		}

		$value = ConvertFrom-Json $value
		$isSecureString = [bool](Get-Member -InputObject $value -Name "Secure-String" -MemberType NoteProperty )
		$isEncryptedObject = [bool](Get-Member -InputObject $value -Name "Encrypted-Object" -MemberType NoteProperty )
		$isEncryptedString = [bool](Get-Member -InputObject $value -Name "Encrypted-String" -MemberType NoteProperty )
		Write-Verbose "isSecureString = $isSecureString isEncryptedObject = $isEncryptedObject"
		if ( $isSecureString -or $isEncryptedObject -or $isEncryptedString )
		{
			if ( $isEncryptedObject )
			{
				$value = $value."Encrypted-Object"
			}
			elseif ( $isEncryptedString )
			{
				$value = $value."Encrypted-String"
			}
			else
			{
				$value = $value."Secure-String"
			}
			Write-Verbose "Value is $value"
			$secureString = $value | ConvertTo-SecureString

			if ( $Decrypt )
			{
				$decryptedtString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
				if ( $isEncryptedObject )
				{
					$value = ConvertFrom-Json $decryptedtString
				}
				else
				{
					$value = $decryptedtString
				}
			}
			else
			{
				$value = $secureString
			}
		}
		$value
	}
}

}

New-Alias -Name gcd -Value Get-ConfigData