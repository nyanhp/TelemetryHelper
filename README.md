# Description

Build status: [![Build Status](https://dev.azure.com/japete/TelemetryHelper/_apis/build/status/TelemetryHelper-Release?branchName=master)](https://dev.azure.com/japete/TelemetryHelper/_build/latest?definitionId=7&branchName=master)
Downloads from Gallery: [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/TelemetryHelper.svg)](https://www.powershellgallery.com/packages/TelemetryHelper/)

The TelemetryHelper module is intended to be used alongside your own modules and can send telemetry to Azure ApplicationInsights for the time being.

With ApplicationInsights and TelemetryHelper you can send:
- Metrics (single values), which are automatically aggregated. Metric names can be single strings e.g. ModuleImportDuration or tuples, e.g. CmdletRuntime,Send-Metric
- Traces, which are very verbose strings which are more used for debugging purposes
- Events, which are the bread and butter. Events can carry a Dictionary<string,string> with property names and their values as well as a Dicitonary<string,double> containing metrics

The TelemetryHelper module is entirely opt-in, meaning: Your users (or you on their behalf) need to opt-in to use telemetry. This is done either
by setting a configurable environment variable or a PSFConfig value.

## Example

Take a look at the following example with the ficticious module, MySweetModule.

Environment variable:  

```powershell
  Set-PSFConfig -Module 'TelemetryHelper' -Name 'MySweetModule.OptInVariable' -Value 'de.janhendrikpeters.telemetryoptin' -PassThru | Register-PSFConfig
```

The environmental variable needs to contain either: 0, 1, false, true, no or yes. If the variable is 1, true or yes, telemetry will be sent.

PSFConfig value:  

```powershell
  Set-PSFConfig -Module 'TelemetryHelper' -Name 'MySweetModule.OptIn' -Value $false -PassThru | Register-PSFConfig
```

By specifying a boolean value for the OptIn setting, you can override the environmental variable and vice versa

To be able to send telemetry, you need to create an ApplicationInsights account and use the telemetry instrumentation key
which can be found on your ApplicationInsights account, for example like so:  

```powershell
  $key = (Get-AzApplicationInsights -ResourceGroupName TotallyTerrificTelemetryTest -Name TurboTelemetry).InstrumentationKey
  Set-PSFConfig -Module 'TelemetryHelper' -Name 'MySweetModule.ApplicationInsights.InstrumentationKey' -Value $key -PassThru | Register-PSFConfig
```
