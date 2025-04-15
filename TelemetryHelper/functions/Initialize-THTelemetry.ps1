<#
.SYNOPSIS
    Enable telemetry
.DESCRIPTION
    Enable telemetry by creating a new telemetry client in the global telemetry store.
.PARAMETER CallingModule
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Initialize-THTelemetry

    Initialize telemetry
#>
function Initialize-THTelemetry
{
    [CmdletBinding()]
    param
    (
        [Alias('ModuleName')]
        [Parameter()]
        [string]
        $CallingModule = (Get-CallingModule)
    )

    Write-PSFMessage -Message "Creating new telemetry store for $CallingModule"
    (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$CallingModule] = New-Object -TypeName de.janhendrikpeters.TelemetryHelper -ArgumentList $CallingModule
}
