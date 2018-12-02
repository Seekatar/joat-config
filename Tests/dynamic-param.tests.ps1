param( [switch] $test )

.  (Join-path $PSScriptRoot dynamicParamFunctions.ps1)

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
}
