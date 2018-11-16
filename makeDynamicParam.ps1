
function makeDynamicParam
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $ParameterName,
[Parameter(Mandatory)]
[scriptblock] $MakeList,
[string] $Alias,
[string] $Help,
[string] $DebugFile
)
    Set-StrictMode -Version Latest
    function logit($msg) {
        if ( $DebugFile ) { "$(Get-Date -form 's') $msg" | out-file $DebugFile -Append -Encoding utf8 }
    }

    logit "makeDynamicParam for $ParameterName"

    # create a dictionary to return
    $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

    # create a new [string] dyn parameter with a collection of attributes
    $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $dynParam = new-object -Type System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $attributeCollection)

    # create a new atrbute for all parameter sets
    $attributes = new-object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = "__AllParameterSets"
    if ( $Help )
    {
        $attributes.HelpMessage = $Help
    }

    try
    {
        logit "About to invoke"
        $names = $MakeList.Invoke()
        logit "list is now $($names | out-string)"
    }
    catch {
        logit "Exception is $_"
    }

    $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $names

    # hook things together
    $attributeCollection.Add($attributes)
    $attributeCollection.Add($paramOptions)

    $paramDictionary.Add($ParameterName, $dynParam)

    return $paramDictionary
}
