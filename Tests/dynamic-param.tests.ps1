
.  (Join-path $PSScriptRoot ..\makeDynamicParam.ps1)


function dynamicParamSimple {
[CmdletBinding()]
param()

DynamicParam
{
    makeDynamicParam "dyn" -MakeList {
        return 'cow','pig','horse'
    }
}

process
{
    Set-StrictMode -Version Latest
    $dyn = $psboundparameters["dyn"]

    Write-Verbose "params are $($psboundparameters | out-string)"

    $dyn
}

}

function dynamicParamConditional {
[CmdletBinding()]
param(
[switch] $Colors
)

DynamicParam
{
    makeDynamicParam "dyn" -MakeList {
		if ( (Test-Path variable:colors) -and $colors )
		{
			'red','light blue','green'
		}
		else
		{
			'cow','pig','horse'
		}
    } -DebugFile C:\temp\test.txt
}

process
{
    Set-StrictMode -Version Latest
    $dyn = $psboundparameters["dyn"]

    Write-Verbose "params are $($psboundparameters | out-string)"

    $dyn
}

}

Describe "TestDynamicParameters" {
    It "TestsPositive" {
        dynamicParamSimple -dyn cow | Should be 'cow'
    }
    It "TestsNegative" {
        {dynamicParamSimple -dyn red} | Should throw
    }
 }

 Describe "TestDynamicConditionalParameters" {
    It "TestsPositive" {
        dynamicParamConditional -dyn cow | Should be 'cow'
    }
    It "TestsPositiveColor" {
        dynamicParamConditional -color -dyn red | Should be 'red'
    }
    It "TestsTheNegative" {
        {dynamicParamConditional -dyn red} | Should throw
    }
    It "TestsTheNegativeColor" {
        {dynamicParamConditional -color -dyn cow} | Should throw
    }
    It "TestsSpace" {
        dynamicParamConditional -color -dyn "light blue" | Should be "light blue"
    }
}