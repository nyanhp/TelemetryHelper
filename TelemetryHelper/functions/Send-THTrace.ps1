<#
.SYNOPSIS
    Send a trace message
.DESCRIPTION
    Send a trace message
.PARAMETER Message
    The text to send
.PARAMETER SeverityLevel
    The severity of the trace message
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.EXAMPLE
    Send-THTrace -Message "Oh god! It burns!"

    Sends the message "Oh god! It burns!" with severity Information (default) to ApplicationInsights
.EXAMPLE
    Send-THTrace -Message "Oh god! It burns!" -SeverityLevel Critical

    Sends the message "Oh god! It burns!" with severity Critical to ApplicationInsights
#>
function Send-THTrace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Message,

        [Parameter()]
        [ValidateSet('Critical', 'Error', 'Warning', 'Information', 'Verbose')]
        $SeverityLevel = 'Information',

        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule),

        [Parameter()]
        [switch]
        $DoNotFlush
    )

    begin
    {
        $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $ModuleName

        if ($null -eq $telemetryInstance)
        {
            Initialize-THTelemetry -ModuleName $ModuleName
            $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $ModuleName
        }
    }

    process
    {
        try
        {
            $telemetryInstance.SendTrace($Message, $SeverityLevel)
        }
        catch
        {
            Stop-PSFFunction -Message "Unable to send trace '$Message' to ApplicationInsights" -Exception $_.Exception
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
