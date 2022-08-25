---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Send-THMetric

## SYNOPSIS
Send a metric

## SYNTAX

### NoDim (Default)
```
Send-THMetric -MetricName <String> -Value <Double> [-ModuleName <String>] [-DoNotFlush] [<CommonParameters>]
```

### TwoDim
```
Send-THMetric -MetricName <String> -MetricDimension1 <String> -MetricDimension2 <String> -Value <Double>
 [-ModuleName <String>] [-DoNotFlush] [<CommonParameters>]
```

### OneDim
```
Send-THMetric -MetricName <String> -MetricDimension1 <String> -Value <Double> [-ModuleName <String>]
 [-DoNotFlush] [<CommonParameters>]
```

## DESCRIPTION
Send a metric (up to two dimensions) to AppInsights.
Metrics will be correlated.

## EXAMPLES

### EXAMPLE 1
```
Send-THMetric -MetricName Layer8Errors -Value 300
```

Sends the metric Layer8Errors with a value of 300

### EXAMPLE 2
```
Send-THMetric -MetricName Layer8 -MetricDimension Errors -Value 300
```

Sends a multidimensional metric

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

### -MetricDimension1
Additional metric dimension 1

```yaml
Type: String
Parameter Sets: TwoDim, OneDim
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetricDimension2
Additional metric dimension 2

```yaml
Type: String
Parameter Sets: TwoDim
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MetricName
Metric name (dimension 0)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

### -Value
Value (double) of the metric

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
