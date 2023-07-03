BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = @{
        $global:callingModule = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $global:callingModule
            StripPii            = $true
        } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru
    }
}

Describe 'Get-THTelemetryConfiguration' {

    Context 'No telemetry configuration yet' {
        BeforeEach {
            Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }
            Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
        }

        It 'Should not throw' {

            { Get-THTelemetryConfiguration -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should return null' {

            Get-THTelemetryConfiguration | Should -BeNullOrEmpty
        }

        It 'Should call all mocks' {

            $null = Get-THTelemetryConfiguration

            Should -Invoke Get-PSFConfigValue -Exactly -Times 1 -ModuleName TelemetryHelper
        }
    }
    Context 'Telemetry configuration initialized' {
        BeforeEach {
            Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
            Mock -CommandName Get-PSFConfigValue { return $global:returnableObjectInitialized } -ModuleName TelemetryHelper
        }

        It 'Should not throw' {
            { Get-THTelemetryConfiguration -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should not be null' {
            $config = Get-THTelemetryConfiguration
            $config | Should -Not -BeNullOrEmpty
            $config.ApiConnectionString | Should -Be $global:returnableObjectInitialized[$global:callingModule].ApiConnectionString
            $config.ModuleName | Should -Be $global:returnableObjectInitialized[$global:callingModule].ModuleName
            $config.StripPii | Should -Be $global:returnableObjectInitialized[$global:callingModule].StripPii
        }

        It 'Should call all mocks' {
            $null = Get-THTelemetryConfiguration

            Should -Invoke Get-PSFConfigValue -Exactly -Times 1 -ModuleName TelemetryHelper
            Should -Invoke Get-CallingModule -Exactly -Times 1 -ModuleName TelemetryHelper
        }
    }
}
