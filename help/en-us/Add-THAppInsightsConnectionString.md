---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Add-THAppInsightsConnectionString

## SYNOPSIS
Add connection string

## SYNTAX

```
Add-THAppInsightsConnectionString [-ConnectionString] <String> [[-ModuleName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds ApplicationInsights connection string to module's telemetry config

## EXAMPLES

### EXAMPLE 1
```
Add-THAppInsightsConnectionString InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/
```

Adds API key InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ to the calling modules config

### EXAMPLE 2
```
Add-THAppInsightsConnectionString InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ -ModuleName MyModule
```

Adds API key InstrumentationKey=4852e725-d412-4d7d-ad86-25df570b7f13;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/ to the configuration of MyModule

## PARAMETERS

### -ConnectionString
The instrumentation API key, e.g.
(Get-AzApplicationInsights -ResourceGroupName TotallyTerrificTelemetryTest -Name TurboTelemetry).ConnectionString

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
Auto-generated, used to select the proper configuration in case you have different modules

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-CallingModule)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
