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

        It 'Should not throw' {
            Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }

            { Get-THTelemetryConfiguration -ModuleName $global:callingModule -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should return null' {
            Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }

            Get-THTelemetryConfiguration -ModuleName $global:callingModule | Should -BeNullOrEmpty
        }

        It 'Should call all mocks' {
            Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }

            $null = Get-THTelemetryConfiguration -ModuleName $global:callingModule

            Should -Invoke Get-PSFConfigValue -Exactly -Times 1 -ModuleName TelemetryHelper
        }
    }
    Context 'Telemetry configuration initialized' {
        It 'Should not throw' {
            Mock -CommandName Get-PSFConfigValue { return $global:returnableObjectInitialized } -ModuleName TelemetryHelper

            { Get-THTelemetryConfiguration -ModuleName $global:callingModule -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should not be null' {
            Mock -CommandName Get-PSFConfigValue { return $global:returnableObjectInitialized } -ModuleName TelemetryHelper

            $config = Get-THTelemetryConfiguration -ModuleName $global:callingModule
            $config | Should -Not -BeNullOrEmpty
            $config.ApiConnectionString | Should -Be $global:returnableObjectInitialized[$global:callingModule].ApiConnectionString
            $config.ModuleName | Should -Be $global:returnableObjectInitialized[$global:callingModule].ModuleName
            $config.StripPii | Should -Be $global:returnableObjectInitialized[$global:callingModule].StripPii
        }

        It 'Should call all mocks' {
            Mock -CommandName Get-PSFConfigValue { return $global:returnableObjectInitialized } -ModuleName TelemetryHelper

            $null = Get-THTelemetryConfiguration -ModuleName $global:callingModule

            Should -Invoke Get-PSFConfigValue -Exactly -Times 1 -ModuleName TelemetryHelper
        }
    }
}
