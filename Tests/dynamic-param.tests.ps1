param( [switch] $test )

.  (Join-path $PSScriptRoot ..\makeDynamicParam.ps1)


function simpleDynamicParam {
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

function conditionalDynamicParam {
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

<#
Try to get it so can not pass in -dyn and just use "red"
Help says -dyn is optional, but can't get it to take it w/o
e.g.
noNameDynamicParam red # sets staticParam to red, prompts for dyn
noNameDynamicParam -dyn red # ok

Setting explicit postion and CmdletBinding(PositionalBinding) doesn't help
DefaultParameterSetName="dyn" didn't help
PositionalBinding=$false and removing position worked, but have to supply -static for second
#>

function noNameDynamicParam {
    [CmdletBinding(PositionalBinding=$false)]
    param(
    [Parameter()]
    [string] $staticParam
    )

    DynamicParam
    {
        makeDynamicParam "dyn" -MakeList {
                'red','light blue','green'
        } -Mandatory
    }

    process
    {
        Set-StrictMode -Version Latest
        $dyn = $psboundparameters["dyn"]

        Write-Verbose "params are $($psboundparameters | out-string)"

        $dyn
    }

}

if ( $test )
{
Describe "TestDynamicParameters" {
    It "Tests Positive" {
        simpleDynamicParam -dyn cow | Should be 'cow'
    }
    It "TestsNegative" {
        {simpleDynamicParam -dyn red} | Should throw
    }
 }

 Describe "TestDynamicConditionalParameters" {
    It "Tests Positive" {
        conditionalDynamicParam -dyn cow | Should be 'cow'
    }
    It "Tests Positive Color" {
        conditionalDynamicParam -dyn red -Colors | Should be 'red'
    }
    It "Tests Negative" {
        {conditionalDynamicParam -dyn red} | Should throw
    }
    It "Tests Negative Color" {
        {conditionalDynamicParam -color -dyn cow} | Should throw
    }
    It "Tests Space" {
        conditionalDynamicParam -color -dyn "light blue" | Should be "light blue"
    }
}

Describe "test noNameDynamicParam" {
    It "Tests Positive" {
        noNameDynamicParam 'light blue' | Should be 'light blue'
    }
    It "Tests Positive Static" {
        noNameDynamicParam red -static "ok" | Should be 'red'
    }
    It "Tests Negative Bad Param" {
        {noNameDynamicParam red2 } | Should throw
    }
    # prompts
    # It "Tests Negative Missing Param" {
    #     {noNameDynamicParam } | Should throw
    # }
}

}