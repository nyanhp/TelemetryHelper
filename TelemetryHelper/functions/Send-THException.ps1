<#
.SYNOPSIS
    Send an exception
.DESCRIPTION
    Send an exception
.PARAMETER Exception
    The exception to send
.PARAMETER CallingModule
    Auto-generated, used to select the proper configuration in case you have different modules
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.EXAMPLE
    Send-THException -Exception $error[0].Exception

    Sends the recent exception to AppInsights
#>
function Send-THException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Exception]
        $Exception,

        [Alias('ModuleName')]
        [Parameter()]
        [string]
        $CallingModule = (Get-CallingModule),

        [Parameter()]
        [switch]
        $DoNotFlush
    )

    begin
    {
        $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $CallingModule

        if ($null -eq $telemetryInstance)
        {
            Initialize-THTelemetry -ModuleName $CallingModule
            $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $CallingModule
        }
    }

    process
    {
        try
        {
            $telemetryInstance.SendError($Exception)
        }
        catch
        {
            Stop-PSFFunction -Message "Unable to send exception '$Message' to ApplicationInsights" -Exception $_.Exception
        }
    }

    end
    {
        if ($DoNotFlush)
        {
            return
        }

        try
        {
            $telemetryInstance.Flush()
        }
        catch
        {
            Stop-PSFFunction -Message "Unable to flush telemetry client. Messages may be delayed." -Exception $_.Exception
        }
    }
}
