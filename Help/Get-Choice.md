---
external help file: NETOffice.Tools-help.xml
Module Name: NETOffice.Tools
online version:
schema: 2.0.0
---

# Get-Choice

## SYNOPSIS
Requests a choise from the user

## SYNTAX

```
Get-Choice [-Title] <String> [-Prompt] <String> [-Options] <String[]> [[-Default] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Requests a choise from the user

## EXAMPLES

### EXAMPLE 1
```
Get-Choice -Title 'Do you want to proceed further?' -Prompt 'Enter your choice' -Options @('&Yes','&No') -Default 1
```

## PARAMETERS

### -Default
{{ Fill Default Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Options
{{ Fill Options Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prompt
{{ Fill Prompt Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
{{ Fill Title Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
AUTHOR: Marc Seguin

## RELATED LINKS
