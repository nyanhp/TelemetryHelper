<#
.SYNOPSIS
    Add instrumentation key
.DESCRIPTION
    Adds ApplicationInsights instrumentation key to module's telemetry config
.PARAMETER InstrumentationKey
    The instrumentation API key, e.g. (Get-AzApplicationInsights -ResourceGroupName TotallyTerrificTelemetryTest -Name TurboTelemetry).InstrumentationKey
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Add-THAppInsightsInstrumentationKey 4852e725-d412-4d7d-ad86-25df570b7f13

    Adds API key 4852e725-d412-4d7d-ad86-25df570b7f13 to the calling modules config
.EXAMPLE
    Add-THAppInsightsInstrumentationKey 4852e725-d412-4d7d-ad86-25df570b7f13 -ModuleName MyModule

    Adds API key 4852e725-d412-4d7d-ad86-25df570b7f13 to the configuration of MyModule
#>
function Add-THAppInsightsInstrumentationKey
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $InstrumentationKey,

        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule)
    )

    if ($null -eq (Get-THTelemetryConfiguration -ModuleName $ModuleName))
    {
        Set-THTelemetryConfiguration -ModuleName $ModuleName -OptInVariableName "$($ModuleName)telemetryOptIn"
    }

    (Get-THTelemetryConfiguration -ModuleName $ModuleName).UpdateInstrumentationKey($InstrumentationKey)
    Set-PSFConfig -Module TelemetryHelper -Name "$ModuleName.ApplicationInsights.InstrumentationKey" -Value $InstrumentationKey -PassThru -Hidden | Register-PSFConfig
}
