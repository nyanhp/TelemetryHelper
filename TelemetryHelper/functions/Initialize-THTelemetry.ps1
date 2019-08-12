<#
.SYNOPSIS
    Enable telemetry
.DESCRIPTION
    Enable telemetry by creating a new telemetry client in the global telemetry store.
.PARAMETER ModuleName
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
        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule)
    )

    Write-PSFMessage -Message "Creating new telemetry store for $ModuleName"
    (Get-PSFConfigValue -FullName TelemetryHelper.TelemetryStore)[$ModuleName] = New-Object -TypeName de.janhendrikpeters.TelemetryHelper -ArgumentList $ModuleName
}
