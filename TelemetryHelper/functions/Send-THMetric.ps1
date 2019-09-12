<#
.SYNOPSIS
    Send a metric
.DESCRIPTION
    Send a metric (up to two dimensions) to AppInsights. Metrics will be correlated.
.PARAMETER MetricName
    Metric name (dimension 0)
.PARAMETER MetricDimension1
    Additional metric dimension 1
.PARAMETER MetricDimension2
    Additional metric dimension 2
.PARAMETER Value
    Value (double) of the metric
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.PARAMETER DoNotFlush
    Indicates that data should be collected and flushed by the telemetry client at regular intervals
    Intervals are 30s or 500 metrics
.EXAMPLE
    Send-THMetric -MetricName Layer8Errors -Value 300

    Sends the metric Layer8Errors with a value of 300
.EXAMPLE
    Send-THMetric -MetricName Layer8 -MetricDimension Errors -Value 300

    Sends a multidimensional metric
#>
function Send-THMetric
{
    [CmdletBinding(DefaultParameterSetName = 'NoDim')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'NoDim')]
        [Parameter(Mandatory = $true, ParameterSetName = 'OneDim')]
        [Parameter(Mandatory = $true, ParameterSetName = 'TwoDim')]
        [string]
        $MetricName,

        [Parameter(Mandatory = $true, ParameterSetName = 'OneDim')]
        [Parameter(Mandatory = $true, ParameterSetName = 'TwoDim')]
        [string]
        $MetricDimension1,

        [Parameter(Mandatory = $true, ParameterSetName = 'TwoDim')]
        [string]
        $MetricDimension2,

        [Parameter(Mandatory = $true)]
        [double]
        $Value,

        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule),

        [Parameter()]
        [switch]
        $DoNotFlush
    )

    $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $ModuleName

    if ($null -eq $telemetryInstance)
    {
        Initialize-THTelemetry -ModuleName $ModuleName
        $telemetryInstance = Get-THTelemetryConfiguration -ModuleName $ModuleName
    }

    try
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            'NoDim'
            {
                $telemetryInstance.SendMetric($MetricName, $Value)
            }
            'OneDim'
            {
                $telemetryInstance.SendMetric($MetricName, $MetricDimension1, $Value)
            }
            'TwoDim'
            {
                $telemetryInstance.SendMetric($MetricName, $MetricDimension1, $MetricDimension2, $Value)
            }
        }
    }
    catch
    {
        Stop-PSFFunction -Message "Unable to send metric '$MetricName$MetricDimension1$MetricDimension2' with value $Value to ApplicationInsights" -Exception $_.Exception
    }

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
