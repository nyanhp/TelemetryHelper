<#
.SYNOPSIS
    Send custom event
.DESCRIPTION
    Send custom event with configurable properties and metrics. This is the most versatile
    telemetry instrument. Properties and Metrics can all be evaluated in e.g. PowerBI or an AppInsights query.
.PARAMETER EventName
    Name of the event
.PARAMETER PropertiesHash
    A Hashtable of properties and values. Both properties as well as values will be converted to string
.PARAMETER MetricsHash
    A Hashtable of metrics and values. Metric name will be converted to string, value to double
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.PARAMETER CallingModule
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Send-THEvent -EventName ModuleImport -PropertiesHash @{PSVersionUsed = $PSVersionTable.PSVersion}

    Sends a ModuleImport event with the PowerShell Version that has been used.
#>
function Send-THEvent
{
    [CmdletBinding()]
    param
    (
        [Parameter(, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $EventName,

        [Alias('Properties')]
        [Parameter()]
        [System.Collections.Hashtable]
        $PropertiesHash,

        [Alias('Metrics')]
        [Parameter()]
        [System.Collections.Hashtable]
        $MetricsHash,

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
        
        try
        {
            if ($Properties -and $Metrics)
            {
                $telemetryInstance.SendEvent($EventName, $Properties, $Metrics)
            }
            elseif ($Properties)
            {
                $telemetryInstance.SendEvent($EventName, $Properties)
            }
            elseif ($Metrics)
            {
                $telemetryInstance.SendEvent($EventName, $null, $Metrics)
            }
            else
            {
                $telemetryInstance.SendEvent($EventName)
            }
        }
        catch
        {
            Stop-PSFFunction -Message "Unable to send event $EventName to ApplicationInsights" -Exception $_.Exception
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
