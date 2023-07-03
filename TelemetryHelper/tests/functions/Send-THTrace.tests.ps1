BeforeDiscovery {
    $global:callingModule = 'TeleTester'
    $global:returnableObjectInitialized = [pscustomobject]@{
        ApiConnectionString = 'Has been initialized'
        ModuleName          = $callingModule
        StripPii            = $true
    } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
    Add-Member -MemberType ScriptMethod SendTrace -Value { param ($Message, $SeverityLevel) } -PassThru | 
    Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru
}

Describe 'Send-THTrace' {
    BeforeEach {
        Mock -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
        Mock -CommandName Stop-PSFFunction -ModuleName TelemetryHelper
        Mock -CommandName Get-THTelemetryConfiguration { if ($global:isFirstCall) { $global:isFirstCall = $false; return $null } else { return $global:returnableObjectInitialized } } -ModuleName TelemetryHelper
        Mock -CommandName Get-CallingModule { return $global:callingModule } -ModuleName TelemetryHelper
    }

    It 'Should not throw (Non Initialized Telemetry)' {
        $global:isFirstCall = $true
        { Send-THTrace -Message NotInitialized -SeverityLevel Information -ErrorAction Stop } | Should -not -Throw
        Should -Invoke -CommandName Initialize-THTelemetry -ModuleName TelemetryHelper
        Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
    }

    It 'Should not throw (Initialized Telemetry)' {
        $global:isFirstCall = $false
        { Send-THTrace -Message NotInitialized -SeverityLevel Information -ErrorAction Stop } | Should -not -Throw
        Should -Invoke -CommandName Get-THTelemetryConfiguration -ModuleName TelemetryHelper
    }

    It 'Should generate an error when SendTrace throws' {
        $theObject = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $callingModule
            StripPii            = $true
        } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
        Add-Member -MemberType ScriptMethod SendTrace -Value { param ($Message, $SeverityLevel) throw 'Oh no' } -PassThru | 
        Add-Member -MemberType ScriptMethod Flush -Value {  } -PassThru
        Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

        Send-THTrace -Message NotInitialized -SeverityLevel Information
        
        Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
    }

    It 'Should generate an error when Flush throws' {
        $theObject = [pscustomobject]@{
            ApiConnectionString = 'Has been initialized'
            ModuleName          = $callingModule
            StripPii            = $true
        } | Add-Member -MemberType ScriptMethod UpdateConnectionString -Value { param ($ConnectionString) } -PassThru |
        Add-Member -MemberType ScriptMethod SendTrace -Value { param ($Message, $SeverityLevel) } -PassThru | 
        Add-Member -MemberType ScriptMethod Flush -Value { throw 'Oh no' } -PassThru
        Mock -CommandName Get-THTelemetryConfiguration { return $theObject } -ModuleName TelemetryHelper

        Send-THTrace -Message NotInitialized -SeverityLevel Information

        Should -Invoke Stop-PSFFunction -Exactly -Times 1 -ModuleName TelemetryHelper
    }
}
