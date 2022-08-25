---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Send-THEvent

## SYNOPSIS
Send custom event

## SYNTAX

### dictionary (Default)
```
Send-THEvent -EventName <String>
 [-Properties <System.Collections.Generic.Dictionary`2[System.String,System.String]>]
 [-Metrics <System.Collections.Generic.Dictionary`2[System.String,System.Double]>] [-ModuleName <String>]
 [-DoNotFlush] [<CommonParameters>]
```

### hashtable
```
Send-THEvent -EventName <String> [-PropertiesHash <Hashtable>] [-MetricsHash <Hashtable>]
 [-ModuleName <String>] [-DoNotFlush] [<CommonParameters>]
```

## DESCRIPTION
Send custom event with configurable properties and metrics.
This is the most versatile
telemetry instrument.
Properties and Metrics can all be evaluated in e.g.
PowerBI or an AppInsights query.

## EXAMPLES

### EXAMPLE 1
```
Send-THEvent -EventName ModuleImport -PropertiesHash @{PSVersionUsed = $PSVersionTable.PSVersion}
```

Sends a ModuleImport event with the PowerShell Version that has been used.

## PARAMETERS

### -DoNotFlush
Indicates that data should be collected and flushed by the telemetry client at regular intervals
Intervals are 30s or 500 metrics

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventName
Name of the event

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Metrics
Dictionary of metrics and their values

```yaml
Type: System.Collections.Generic.Dictionary`2[System.String,System.Double]
Parameter Sets: dictionary
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetricsHash
A Hashtable of metrics and values.
Both metrics as well as values will be convert to string

```yaml
Type: Hashtable
Parameter Sets: hashtable
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: (Get-CallingModule)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties
Dictionary of properties and their values.

```yaml
Type: System.Collections.Generic.Dictionary`2[System.String,System.String]
Parameter Sets: dictionary
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PropertiesHash
A Hashtable of properties and values.
Both properties as well as values will be convert to string

```yaml
Type: Hashtable
Parameter Sets: hashtable
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
