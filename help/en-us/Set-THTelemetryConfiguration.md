---
external help file: TelemetryHelper-help.xml
Module Name: TelemetryHelper
online version:
schema: 2.0.0
---

# Set-THTelemetryConfiguration

## SYNOPSIS
Configure the telemetry for a module

## SYNTAX

```
Set-THTelemetryConfiguration [[-OptInVariableName] <String>] [[-UserOptIn] <Boolean>]
 [[-StripPersonallyIdentifiableInformation] <Boolean>] [[-ModuleName] <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Configure the telemetry for a module

## EXAMPLES

### EXAMPLE 1
```
Set-THTelemetryConfiguration -UserOptIn $True
```

Configures the basics and enables the user opt-in

## PARAMETERS

### -ModuleName
Auto-generated, used to select the proper configuration in case you have different modules

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: (Get-CallingModule)
Accept pipeline input: False
Accept wildcard characters: False
```

### -OptInVariableName
The environment variable used to determine user-opt-in

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$(Get-CallingModule)telemetryOptIn"
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the configuration object for further processing

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

### -StripPersonallyIdentifiableInformation
Remove information such as the host name from telemetry

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserOptIn
Override environment variable and opt-in

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Requests confirmation that you really want to change the configuration

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Simulates the entire affair

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
