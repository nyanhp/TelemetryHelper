---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Get-THTelemetryConfiguration

## SYNOPSIS
Get the current telemetry config

## SYNTAX

```
Get-THTelemetryConfiguration [[-ModuleName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the current telemetry config

## EXAMPLES

### EXAMPLE 1
```
Get-THTelemetryConfiguration
```

Returns the current configuration for the current module

## PARAMETERS

### -ModuleName
Auto-generated, used to select the proper configuration in case you have different modules

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
