BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = @{
        $global:callingModule = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $callingModule
            StripPii            = $true
        }
    }

    $cases = @(
        @{
            Parameters = @{
                OptInVariableName = 'ModuleNameOptIn'
            }
        }
        @{
            Parameters = @{
                UserOptIn = $true
            }
        }
        @{
            Parameters = @{
                StripPersonallyIdentifiableInformation = $true
            }
        }
        @{
            Parameters = @{
                PassThru = $true
            }
        }
    )
}

Describe 'Set-THTelemetryConfiguration' {
    BeforeEach {
        Mock -CommandName Get-CallingModule -MockWith { $global:callingModule } -ModuleName TelemetryHelper
        Mock -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
        Mock -CommandName Get-PSFConfigValue { if ($global:isFirstCall) { $global:isFirstCall = $false; return @{} } else { return $global:returnableObjectInitialized } } -ModuleName TelemetryHelper
        Mock -CommandName Set-PSFConfig -ModuleName TelemetryHelper
    }

    It 'Should not throw and call mocks (Non Initialized Telemetry)' -TestCases $cases {
        $global:isFirstCall = $true
        Set-THTelemetryConfiguration @Parameters

        Should -Invoke Get-CallingModule -ModuleName TelemetryHelper
        Should -Invoke Get-PSFConfigValue -ModuleName TelemetryHelper
        Should -Invoke Initialize-THTelemetry -ModuleName TelemetryHelper -Exactly -Times 1
        Should -Invoke Set-PSFConfig -ModuleName TelemetryHelper -Exactly -Times 3
    }

    It 'Should not throw and call mocks (Initialized Telemetry)' -TestCases $cases {
        $global:isFirstCall = $false
        Set-THTelemetryConfiguration @Parameters

        Should -Invoke Get-CallingModule -ModuleName TelemetryHelper
        Should -Invoke Get-PSFConfigValue -ModuleName TelemetryHelper
        Should -Invoke Initialize-THTelemetry -ModuleName TelemetryHelper -Exactly -Times 0
        Should -Invoke Set-PSFConfig -ModuleName TelemetryHelper -Exactly -Times 3
    }
}
