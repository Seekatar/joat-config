
.  (Join-path $PSScriptRoot ..\makeDynamicParam.ps1)


function dynamicParamSimple {
[CmdletBinding()]
param(
     [switch] $colors
)

DynamicParam
{
    makeDynamicParam "dyn" -MakeList {
        return "e","f","g"
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
