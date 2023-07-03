BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = [pscustomobject]@{
        ApiConnectionString = 'Has been initialized'
        ModuleName          = $callingModule
        StripPii            = $true
    } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
    Add-Member -MemberType ScriptMethod SendEvent -Value { param ($EventName, $Properties, $Metrics) } -PassThru | 
    Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru

    $propDic = [System.Collections.Generic.Dictionary[string, string]]::new()
    $metricDic = [System.Collections.Generic.Dictionary[string, double]]::new()
    $propDic.Add('Version', '1.2.3.4')
    $propDic.Add('DeploymentName', 'UnitTest')
    $metricDic.Add('TimeTaken', 10.1234)
    $metricDic.Add('DaysUntilEndOfWorld', 1)

    $propHash = @{
        Version        = '1.2.3.4'
        DeploymentName = 'UnitTest'
    }
    $metricHash = @{
        TimeTaken           = 10.1234
        DaysUntilEndOfWorld = 1
    }

    $cases = @(
        # Only event
        @{
            EventName = 'NameOnly'
        }
        @{
            EventName  = 'NameOnlyNoFlush'
            DoNotFlush = $true
        }
        # Only properties
        @{
            EventName      = 'PropsOnlyHash'
            PropertiesHash = $propHash
        }
        @{
            EventName      = 'PropsOnlyHashNoFlush'
            PropertiesHash = $propHash
            DoNotFlush     = $true
        }
        # Only metrics
        @{
            EventName   = 'MetricsOnlyHash'
            MetricsHash = $metricHash
        }
        @{
            EventName   = 'MetricsOnlyHashNoFlush'
            MetricsHash = $metricHash
            DoNotFlush  = $true
        }
        @{
            EventName      = 'FullHash'
            MetricsHash    = $metricHash
            PropertiesHash = $propHash
        }
        @{
            EventName      = 'FullHashNoFlush'
            MetricsHash    = $metricHash
            PropertiesHash = $propHash
            DoNotFlush     = $true
        }
    )
}

Describe 'Send-THEvent' {
        BeforeEach {
            Mock -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
            Mock -CommandName Stop-PSFFunction -ModuleName TelemetryHelper
            Mock -CommandName Get-THTelemetryConfiguration { if ($global:isFirstCall) { $global:isFirstCall = $false; return $null } else { return $global:returnableObjectInitialized } } -ModuleName TelemetryHelper
            Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
        }

        It "Should not throw <EventName> (Non Initialized Telemetry)" -TestCases $cases {
            $global:isFirstCall = $true

            $theParameters = @{
                EventName = $EventName
            }
            if ($PropertiesHash)
            {
                $theParameters['PropertiesHash'] = $PropertiesHash
            }
            if ($MetricsHash)
            {
                $theParameters['MetricsHash'] = $MetricsHash
            }
            if ($DoNotFlush)
            {
                $theParameters['DoNotFlush'] = $DoNotFlush
            }
            { Send-THEvent @theParameters -ErrorAction Stop } | Should -Not -Throw

            Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
            Should -Invoke -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
            Should -Invoke -CommandName Get-CallingModule -ModuleName TelemetryHelper
        }

        It "Should not throw <EventName> (Initialized Telemetry)" -TestCases $cases {
            $global:isFirstCall = $false

            $theParameters = @{
                EventName = $EventName
            }
            if ($Properties)
            {
                $theParameters['Properties'] = $Properties
            }
            if ($PropertiesHash)
            {
                $theParameters['PropertiesHash'] = $Properties
            }
            if ($Metrics)
            {
                $theParameters['Metrics'] = $Properties
            }
            if ($MetricsHash)
            {
                $theParameters['MetricsHash'] = $Properties
            }
            if ($DoNotFlush)
            {
                $theParameters['DoNotFlush'] = $Properties
            }
            { Send-THEvent @theParameters -ErrorAction Stop } | Should -Not -Throw

            Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
            Should -Invoke -CommandName Get-CallingModule -ModuleName TelemetryHelper
        }

        It "Should generate error while sending" {
            $theObject = [pscustomobject]@{
                ApiConnectionString = 'Has been initialized'
                ModuleName          = $callingModule
                StripPii            = $true
            } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
            Add-Member -MemberType ScriptMethod SendEvent -Value { param ($EventName, $Properties, $Metrics) throw 'Oh no' } -PassThru | 
            Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru
            Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

            Send-THEvent -EventName SendError

            Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
        }

        It "Should generate error while flushing" {
            $theObject = [pscustomobject]@{
                ApiConnectionString = 'Has been initialized'
                ModuleName          = $callingModule
                StripPii            = $true
            } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
            Add-Member -MemberType ScriptMethod SendEvent -Value { param ($EventName, $Properties, $Metrics) } -PassThru | 
            Add-Member -MemberType ScriptMethod Flush -Value { throw 'Oh no' } -PassThru
            Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

            Send-THEvent -EventName FlushError

            Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
        }
}
