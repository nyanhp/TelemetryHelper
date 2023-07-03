BeforeDiscovery {
    $callingModule = 'TeleTester'
}

Describe 'Initialize-THTelemetry' {
    BeforeEach {
        Mock -CommandName Get-CallingModule -MockWith { $callingModule } -ModuleName TelemetryHelper
    }

    It 'Should not throw' {
        Mock -CommandName Write-PSFMessage -ModuleName TelemetryHelper
        Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }
        Mock -CommandName New-Object -ModuleName TelemetryHelper
        { Initialize-THTelemetry -ErrorAction Stop } | Should -Not -Throw
    }

    It 'Should call mocks' {
        Mock -CommandName Write-PSFMessage -ModuleName TelemetryHelper
        Mock -CommandName Get-PSFConfigValue -ModuleName TelemetryHelper -MockWith { return @{} }
        Mock -CommandName New-Object -ModuleName TelemetryHelper
        Initialize-THTelemetry
        Should -Invoke Write-PSFMessage -Exactly -Times 1 -ModuleName TelemetryHelper
        Should -Invoke Get-PSFConfigValue -Exactly -Times 1 -ModuleName TelemetryHelper
        Should -Invoke New-Object -Exactly -Times 1 -ModuleName TelemetryHelper
    }
}
