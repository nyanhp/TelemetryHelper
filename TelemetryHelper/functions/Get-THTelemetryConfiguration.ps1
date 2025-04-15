<#
.SYNOPSIS
    Get the current telemetry config
.DESCRIPTION
    Get the current telemetry config
.PARAMETER CallingModule
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Get-THTelemetryConfiguration

    Returns the current configuration for the current module
#>
function Get-THTelemetryConfiguration
{
    [CmdletBinding()]
    param
    (
        [Alias('ModuleName')]
        [Parameter()]
        [string]
        $CallingModule = (Get-CallingModule)
    )

    (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$CallingModule]
}
