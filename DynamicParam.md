# Dynamic Parameters in PowerShell using DynamicParam block
Adding a dynamic parameter to a PowerShell function can be a powerful feature that makes your cmdlets easier to use.  This blog describes using a helper function to do that, and some of the quirks of using `DynamicParam` blocks.

Note that with this helper are Pester tests that show the various ways dynamic parameters can be added with`DynamicParam` blocks, and they are referenced throughout.

There are more advance methods for adding dynamic parameters, and another blog post will cover those.

## Using `makeDynamicParam`

This helper function is to be used in your function to add a dynamic parameter, with various options. Most commonly the option is to add a `ValidateSet` to the parameter to allow tab-completion with a dynamic set of strings.

The basic usage of the cmdlet is as follows:

```powershell
function simpleDynamicParam {
[CmdletBinding()] # required!
param()

DynamicParam {
    makeDynamicParam "dyn" -ValidateSet 'cow','pig','horse'
}

process { # required!
    $dyn = $PSBoundParameters["dyn"] # assign to a local variable
}

}
```

You must use both the `DynamicParam` and `process` blocks in your function.  You may also optionally use `begin` and `end`.  To declare the dynamic parameter, call the `makeDynamicParam` method, passing in the name and all the options you desire.  You can check the values of other parameter to see if they are set yet, but you must test to see if they are there first.  See the `conditionalDynamicParam` tests.

### Multiple Dynamic Parameters

You can add multiple dynamic parameters simply by calling `makeDynamicParam` multiple times, piping the output from one to another.  See the `twoSimpleDynamicParamPositional` tests.

## Quirks in Position

If you use names, all is well, but if you want to omit names and use positional parameters, things get quirky.

* If you only have dynamic parameters, it works
* If you have dynamic and static, it always thinks the static come first, regardless of `Postion` values.
* If you want the dynamic parameter first, with other static parameters, it will work if you turn off `PositionalBinding` and do _not_ use `Position`.  See the `noNameDynamicParam` tests.

## Debugging and Gotchas

You can debug `dynamicParam` blocks via the debugger but sometimes it can be quirky.  Output such as `Write-Verbose/Warning`, etc. isn't written out to the console.  In the `makeDynamicParam` function there is a `-DebugFile` switch that will dump diagnostics out to the file it is given.  Also, if you use `-ValidateScriptBlock` parameter, you can call the `logit` function inside the ScriptBlock passed to it.

If tabbing isn't working, sometimes pressing enter will show an error.

### Must have CmdletBinding or Param

If nothing seems to be working, and pressing enter shows nothing, it may be you are missing either `[CmdletBinding()]` or mark one or more parameters with `[Parmeter()]`.  It seems that without one of those the `dynamicParam` block is not executed.