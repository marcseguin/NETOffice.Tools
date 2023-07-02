---
external help file: NETOffice.Tools-help.xml
Module Name: NETOffice.Tools
online version:
schema: 2.0.0
---

# Read-Credentials

## SYNOPSIS
Returns a PSCredential object with username and password.

## SYNTAX

```
Read-Credentials [-FileName] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns credentials from \<filename\> (if exists) or requests them from the user. It also can stores them in \<filname\> in an encrypted format (if the file does not exist).

## EXAMPLES

### EXAMPLE 1
```
Read-Credentials .mycredentials
```

## PARAMETERS

### -FileName
{{ Fill FileName Description }}

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
