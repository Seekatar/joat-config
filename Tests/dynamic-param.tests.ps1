param( [switch] $test )

.  (Join-path $PSScriptRoot ..\makeDynamicParam.ps1)


function processIt {
param( $bindings )

    Set-StrictMode -Version Latest
    $dyn = $bindings["dyn"]

    Write-Verbose "params are $($bindings | out-string)"

    $dyn
}

function simpleDynamicParam {
[CmdletBinding()]
param()

DynamicParam {
    makeDynamicParam "dyn" -ValidateSetScript {
        return 'cow','pig','horse'
    } -DebugFile C:\temp\test.txt

}

process {
    processIt $PSBoundParameters
}

}

function twoSimpleDynamicParam {
[CmdletBinding()]
param()

DynamicParam {
    makeDynamicParam "dynAnimal" -ValidateSet 'cow','pig','horse' -Mandatory |
    makeDynamicParam "dynColor" -ValidateSet 'red','light blue','green' -Mandatory
}

process {
    $PSBoundParameters["dynAnimal"]
    $PSBoundParameters["dynColor"]
}

}

function twoSimpleDynamicParamPositional {
    [CmdletBinding()]
    param(
    # this breaks it since it thinks test is always 1
    #[Parameter(Position=3)]
    #[string] $test
    )

    DynamicParam {
        makeDynamicParam "dynAnimal" -ValidateSet 'cow','pig','horse' -Mandatory -Position 1|
        makeDynamicParam "dynColor" -ValidateSet 'red','light blue','green' -Position 2 -Mandatory
    }

    process {
        $PSBoundParameters["dynAnimal"]
        $PSBoundParameters["dynColor"]
    }

    }

<#
.SYNOPSIS
Test dynamic parameter function that does not work, since no [CmdletBinding] or [Parameter]
#>
function simpleDynamicParamNoBinding {
    param()

    DynamicParam
    {
        makeDynamicParam "dyn" -ValidateSet 'cow','pig','horse'
    }

    process
    {
        processIt $PSBoundParameters
    }

}


function conditionalDynamicParam {
[Cmdletbinding()]
param(
[Parameter()]
[switch] $Colors
)

DynamicParam
{
    makeDynamicParam "dyn" -ValidateSetScript {
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
    processIt $PSBoundParameters
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
        makeDynamicParam -ParameterName "dyn" -ValidateSet 'red','light blue','green' -Mandatory
    }

    process
    {
        processIt $PSBoundParameters
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
    It "TestsNoParam" {
        {simpleDynamicParam} | Should not throw
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
    # this will prompt for dyn
    # It "Tests Negative Missing Param" {
    #     {noNameDynamicParam } | Should throw
    # }
}

Describe "test no bindings" {
    It "Tests no Cmdletbinding" {
        simpleDynamicParamNoBinding -dyn pig | should be $null
    }
}

Describe "test two parameters" {
    It "Checks two positive" {
        ($animal,$color) = twoSimpleDynamicParam -dynAnimal cow -dynColor red
        $animal | Should be "cow"
        $color | Should be "red"
    }
} -Tag SkipMe

} #end if test

