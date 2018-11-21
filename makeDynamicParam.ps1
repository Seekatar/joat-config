<#
.SYNOPSIS
Helper for making dynamic parameters with ValidateSets in PowerShell

.PARAMETER ParameterName
Name of dynamic parameter

.PARAMETER MakeList
A scriptblock to create the ValidateSet list

.PARAMETER Alias
Alias for parameter

.PARAMETER ParameterSetName
Parameter set name

.PARAMETER Mandatory
If the parameter is mandatory

.PARAMETER ValueFromPipeline
If the parameter is from the pipeline

.PARAMETER Position
Position to set

.PARAMETER Help
Optional help

.PARAMETER DebugFile
File for outputing debug information, for debugging dyn parameters

.EXAMPLE
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

.EXAMPLE
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

    }
}
#>
function makeDynamicParam
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ParameterSetName="ValidateScriptBlock",Position=1)]
[Parameter(Mandatory,ParameterSetName="ValidateSet",Position=1)]
[string] $ParameterName,
[Parameter(Mandatory,ParameterSetName="ValidateScriptBlock")]
[scriptblock] $ValidateSetScript,
[Parameter(Mandatory,ParameterSetName="ValidateSet")]
[string[]] $ValidateSet,
[string] $Alias,
[string] $ParameterSetName,
[switch] $Mandatory,
[switch] $ValueFromPipeline,
[switch] $ValueFromPipelineByPropertyName,
[int] $Position = 0,
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
    if ( $ParameterSetName )
    {
        $attributes.ParameterSetName = $ParameterSetName
    }
    if ( $Help )
    {
        $attributes.HelpMessage = $Help
    }
    $attributes.Mandatory = [bool]$Mandatory
    $attributes.ValueFromPipeline = [bool]$ValueFromPipeline
    $attributes.ValueFromPipelineByPropertyName = [bool]$ValueFromPipelineByPropertyName
    $attributes.Position = $Position
    logit "Attributes are $(ConvertTo-Json ($attributes | Select-Object * -ExcludeProperty "TypeId")  -Depth 1)"

    if ( $ValidateSetScript )
    {
        try
        {
            logit "About to invoke"
            $ValidateSet = $ValidateSetScript.Invoke()
        }
        catch {
            logit "Exception from ValidateSetScript: $_"
        }
    }
    logit "list is now $($ValidateSet | out-string)"
    if ( $ValidateSet )
    {
        $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
        $attributeCollection.Add($paramOptions)
    }


    # hook things together
    $attributeCollection.Add($attributes)

    $paramDictionary.Add($ParameterName, $dynParam)

    return $paramDictionary
}
