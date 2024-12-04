<#
.SYNOPSIS
    Send custom availability
.DESCRIPTION
    Send custom availability with configurable properties and metrics.
.PARAMETER TestName
    Name of the test
.PARAMETER Location
    Location from which the test was executed
.PARAMETER Duration
    Duration the availablity test ran
.PARAMETER Available
    Indicates whether or not the tested endpoint was available. Defaults to true
.PARAMETER TimeStamp
    Timestamp when the test was executed. Defaults to current date
.PARAMETER Message
    Optional error message to include in availability trace
.PARAMETER PropertiesHash
    A Hashtable of properties and values. Both properties as well as values will be converted to string
.PARAMETER MetricsHash
    A Hashtable of metrics and values. Metric name will be converted to string, value to double
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Send-THAvailability -TestName PublicEndpoint -Location 'Amsterdam' -Duration [TimeSpan]::FromMilliseconds(120)

    Sends availability info for a test called PublicEndpoint, tested from Amsterdam with a duration of 120ms.
#>
function Send-THAvailability
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $TestName,

        [Parameter(Mandatory = $true)]
        [string]
        $Location,

        [Parameter(Mandatory = $true)]
        [TimeSpan]
        $Duration,

        [Parameter()]
        [bool]
        $Available = $true

        [Parameter()]
        [DateTimeOffset]
        $TimeStamp = (Get-Date),

        [Parameter()]
        [string]
        $Message,

        [Alias('Properties')]
        [Parameter()]
        [System.Collections.Hashtable]
        $PropertiesHash,

        [Alias('Metrics')]
        [Parameter()]
        [System.Collections.Hashtable]
        $MetricsHash,

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

        if ($MetricsHash)
        {
            $Metrics = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, double]'
            foreach ($kvp in $MetricsHash.GetEnumerator())
            {
                $Metrics.Add([string]$kvp.Key, [double]$kvp.Value)
            }
        }

        if ($PropertiesHash)
        {
            $Properties = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, string]'
            foreach ($kvp in $PropertiesHash.GetEnumerator())
            {
                $Properties.Add([string]$kvp.Key, [string]$kvp.Value)
            }
        }
    }

    process
    {
        # (string testName, DateTimeOffset timeStamp, TimeSpan duration, string location, bool success = true, string message = "", Dictionary<string, string> properties = null, Dictionary<string, double> metrics = null)
        try
        {
            if ($Properties -and $Metrics)
            {
                $telemetryInstance.SendAvailability($TestName, $TimeStamp, $Duration, $Location, $Available, $Message, $Properties, $Metrics)
            }
            elseif ($Properties)
            {
                $telemetryInstance.SendAvailability($TestName, $TimeStamp, $Duration, $Location, $Available, $Message, $Properties)
            }
            elseif ($Metrics)
            {
                $telemetryInstance.SendAvailability($TestName, $TimeStamp, $Duration, $Location, $Available, $Message, $null, $Metrics)
            }
            else
            {
                $telemetryInstance.SendAvailability($TestName, $TimeStamp, $Duration, $Location, $Available, $Message)
            }
        }
        catch
        {
            Stop-PSFFunction -Message "Unable to send availability test $TestName to ApplicationInsights" -Exception $_.Exception
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
