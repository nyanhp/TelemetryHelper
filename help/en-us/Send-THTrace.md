---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Send-THTrace

## SYNOPSIS
Send a trace message

## SYNTAX

```
Send-THTrace [-Message] <String> [[-SeverityLevel] <Object>] [[-ModuleName] <String>] [-DoNotFlush]
 [<CommonParameters>]
```

## DESCRIPTION
Send a trace message

## EXAMPLES

### EXAMPLE 1
```
Send-THTrace -Message "Oh god! It burns!"
```

Sends the message "Oh god!
It burns!" with severity Information (default) to ApplicationInsights

### EXAMPLE 2
```
Send-THTrace -Message "Oh god! It burns!" -SeverityLevel Critical
```

Sends the message "Oh god!
It burns!" with severity Critical to ApplicationInsights

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

### -Message
The text to send

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ModuleName
Auto-generated, used to select the proper configuration in case you have different modules

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: (Get-CallingModule)
Accept pipeline input: False
Accept wildcard characters: False
```

### -SeverityLevel
The severity of the trace message

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
