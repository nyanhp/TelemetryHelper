<#
.SYNOPSIS
    Add connection string
.DESCRIPTION
    Adds ApplicationInsights connection string to module's telemetry config
.PARAMETER ConnectionString
    The instrumentation API key, e.g. (Get-AzApplicationInsights -ResourceGroupName TotallyTerrificTelemetryTest -Name TurboTelemetry).ConnectionString
.PARAMETER ModuleName
    Auto-generated, used to select the proper configuration in case you have different modules
.EXAMPLE
    Add-THAppInsightsConnectionString InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/

    Adds API key InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ to the calling modules config
.EXAMPLE
    Add-THAppInsightsConnectionString InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ -ModuleName MyModule

    Adds API key InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ to the configuration of MyModule
#>
function Add-THAppInsightsConnectionString
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ConnectionString,

        [Parameter()]
        [string]
        $ModuleName = (Get-CallingModule)
    )

    if ($null -eq (Get-THTelemetryConfiguration -ModuleName $ModuleName))
    {
        Set-THTelemetryConfiguration -ModuleName $ModuleName -OptInVariableName "$($ModuleName)telemetryOptIn"
    }

    (Get-THTelemetryConfiguration -ModuleName $ModuleName).UpdateConnectionString($ConnectionString)
    Set-PSFConfig -Module TelemetryHelper -Name "$ModuleName.ApplicationInsights.ConnectionString" -Value $ConnectionString -PassThru -Hidden | Register-PSFConfig
}
