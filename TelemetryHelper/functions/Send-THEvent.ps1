<#
.SYNOPSIS
    Send custom event
.DESCRIPTION
    Send custom event with configurable properties and metrics. This is the most versatile
    telemetry instrument. Properties and Metrics can all be evaluated in e.g. PowerBI or an AppInsights query.
.PARAMETER EventName
    Name of the event
.PARAMETER Properties
    Dictionary of properties and their values.
.PARAMETER PropertiesHash
    A Hashtable of properties and values. Both properties as well as values will be convert to string
.PARAMETER Metrics
    Dictionary of metrics and their values
.PARAMETER MetricsHash
    A Hashtable of metrics and values. Both metrics as well as values will be convert to string
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Send-THEvent -EventName ModuleImport -PropertiesHash @{PSVersionUsed = $PSVersionTable.PSVersion}

    Sends a ModuleImport event with the PowerShell Version that has been used.
#>
function Send-THEvent
{
    [CmdletBinding(DefaultParameterSetName = 'dictionary')]
    param
    (
        [Parameter(ParameterSetName = 'dictionary', Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'hashtable', Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $EventName,

        [Parameter(ParameterSetName = 'dictionary')]
        [System.Collections.Generic.Dictionary`2[string, string]]
        $Properties,

        [Parameter(ParameterSetName = 'hashtable')]
        [System.Collections.Hashtable]
        $PropertiesHash,

        [Parameter(ParameterSetName = 'dictionary')]
        [System.Collections.Generic.Dictionary`2[string, double]]
        $Metrics,

        [Parameter(ParameterSetName = 'hashtable')]
        [System.Collections.Hashtable]
        $MetricsHash,

        [Parameter(ParameterSetName = 'hashtable')]
        [Parameter(ParameterSetName = 'dictionary')]
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
