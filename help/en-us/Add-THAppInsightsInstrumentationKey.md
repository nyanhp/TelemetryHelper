---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Add-THAppInsightsInstrumentationKey

## SYNOPSIS
Add instrumentation key

## SYNTAX

```
Add-THAppInsightsInstrumentationKey [-InstrumentationKey] <String> [[-ModuleName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds ApplicationInsights instrumentation key to module's telemetry config

## EXAMPLES

### EXAMPLE 1
```
Add-THAppInsightsInstrumentationKey 4852e725-d412-4d7d-ad86-25df570b7f13
```

Adds API key 4852e725-d412-4d7d-ad86-25df570b7f13 to the calling modules config

### EXAMPLE 2
```
Add-THAppInsightsInstrumentationKey 4852e725-d412-4d7d-ad86-25df570b7f13 -ModuleName MyModule
```

Adds API key 4852e725-d412-4d7d-ad86-25df570b7f13 to the configuration of MyModule

## PARAMETERS

### -InstrumentationKey
The instrumentation API key, e.g.
(Get-AzApplicationInsights -ResourceGroupName TotallyTerrificTelemetryTest -Name TurboTelemetry).InstrumentationKey

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
