BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = [pscustomobject]@{
        ApiConnectionString = 'Has been initialized'
        ModuleName          = $callingModule
        StripPii            = $true
    } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
    Add-Member -MemberType ScriptMethod SendMetric -Value { param ($MetricName, $MetricDimension1, $MetricDimension2, $Value) } -PassThru | 
    Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru

    $cases = @(
        @{
            MetricName = 'NoDimension'
            Value      = 1.234
        }
        @{
            MetricName       = 'OneDimension'
            MetricDimension1 = 'Dim1'
            Value            = 1.234
        }
        @{
            MetricName       = 'TwoDimension'
            MetricDimension1 = 'Dim1'
            MetricDimension2 = 'Dim2'
            Value            = 1.234
        }
        @{
            MetricName = 'NoDimensionNoFlush'
            Value      = 1.234
            DoNotFlush = $true
        }
        @{
            MetricName       = 'OneDimensionNoFlush'
            MetricDimension1 = 'Dim1'
            Value            = 1.234
            DoNotFlush       = $true
        }
        @{
            MetricName       = 'TwoDimensionNoFlush'
            MetricDimension1 = 'Dim1'
            MetricDimension2 = 'Dim2'
            Value            = 1.234
            DoNotFlush       = $true
        }
    )
}

Describe 'Send-THMetric' {
    BeforeEach {
        Mock -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
        Mock -CommandName Stop-PSFFunction -ModuleName TelemetryHelper
        Mock -CommandName Get-THTelemetryConfiguration { if ($global:isFirstCall) { $global:isFirstCall = $false; return $null } else { return $global:returnableObjectInitialized } } -ModuleName TelemetryHelper
        Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
    }

    It 'Should not throw <MetricName> (Non Initialized Telemetry)' -TestCases $cases {
        $metricParam = @{
            MetricName = $MetricName
            Value      = $Value
        }
        if ($MetricDimension1) { $metricParam['MetricDimension1'] = $MetricDimension1 }
        if ($MetricDimension2) { $metricParam['MetricDimension2'] = $MetricDimension2 }
        $global:isFirstCall = $true
        { Send-THMetric @metricParam -ErrorAction Stop } | Should -not -Throw
        Should -Invoke -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
        Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
    }

    It 'Should not throw <MetricName> (Initialized Telemetry)' -TestCases $cases {
        $global:isFirstCall = $false
        $metricParam = @{
            MetricName = $MetricName
            Value      = $Value
        }
        if ($MetricDimension1) { $metricParam['MetricDimension1'] }
        if ($MetricDimension2) { $metricParam['MetricDimension2'] }
        $global:isFirstCall = $true
        { Send-THMetric @metricParam -ErrorAction Stop } | Should -not -Throw
        Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
    }

    It 'Should generate an error when SendMetric throws' {
        $theObject = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $callingModule
            StripPii            = $true
        } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
        Add-Member -MemberType ScriptMethod SendMetric -Value { param ($MetricName, $MetricDimension1, $MetricDimension2, $Value) throw 'oh no' } -PassThru | 
        Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru
        Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

        Send-THMetric -MetricName Error -Value 1.23
        
        Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
    }

    It 'Should generate an error when Flush throws' {
        $theObject = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $callingModule
            StripPii            = $true
        } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
        Add-Member -MemberType ScriptMethod SendMetric -Value { param ($MetricName, $MetricDimension1, $MetricDimension2, $Value) } -PassThru | 
        Add-Member -MemberType ScriptMethod Flush -Value { throw 'Oh no' } -PassThru
        Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

        Send-THMetric -MetricName Error -Value 1.23

        Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
    }
}
