<#
Tests
- TelemetryConfig null
- TelemetryConfig exists
#>
BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = [pscustomobject]@{
        ApiConnectionString = 'Has been initialized'
        ModuleName          = $callingModule
        StripPii            = $true
    } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru
}

AfterAll {
    Remove-Variable -Name returnableObjectInitialized -Scope Global
}

Describe 'Add-THAppInsightsConnectionString' {

    Context 'No telemetry configuration yet' {
        BeforeEach {
            Mock -CommandName Get-THTelemetryConfiguration { if ($global:isFirstCall) { $global:isFirstCall = $false; return $null } else { return $global:returnableObjectInitialized } } -ModuleName TelemetryHelper
            Mock -CommandName Set-THTelemetryConfiguration -ModuleName TelemetryHelper
            Mock -CommandName Set-PSFConfig -ModuleName TelemetryHelper
            Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
        }

        It 'Should call all mocks' {
            $global:isFirstCall = $true

            $null = Add-THAppInsightsConnectionString -ConnectionString 'thestring'

            Should -Invoke Get-THTelemetryConfiguration -Exactly -Times 2 -ModuleName TelemetryHelper
            Should -Invoke Set-THTelemetryConfiguration -Exactly -Times 1 -ModuleName TelemetryHelper
            Should -Invoke Set-PSFConfig -Exactly -Times 1 -ModuleName TelemetryHelper
        }

        It 'Should not throw' {
            $global:isFirstCall = $true

            { Add-THAppInsightsConnectionString -ConnectionString 'thestring' -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'Telemetry configuration initialized' {
        BeforeEach {
            Mock -CommandName Get-THTelemetryConfiguration { return $global:returnableObjectInitialized } -ModuleName TelemetryHelper
            Mock -CommandName Set-THTelemetryConfiguration -ModuleName TelemetryHelper
            Mock -CommandName Set-PSFConfig -ModuleName TelemetryHelper
            Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
        }

        It 'Should call all mocks' {
            $null = Add-THAppInsightsConnectionString -ConnectionString 'thestring'

            Should -Invoke Get-THTelemetryConfiguration -Exactly -Times 2 -ModuleName TelemetryHelper
            Should -Invoke Set-THTelemetryConfiguration -Exactly -Times 0 -ModuleName TelemetryHelper
            Should -Invoke Set-PSFConfig -Exactly -Times 1 -ModuleName TelemetryHelper
        }

        It 'Should call all mocks' {
            { Add-THAppInsightsConnectionString -ConnectionString 'thestring' -ErrorAction Stop } | Should -Not -Throw
        }
    }
}
