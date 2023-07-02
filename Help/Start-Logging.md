---
external help file: NETOffice.Tools-help.xml
Module Name: NETOffice.Tools
online version:
schema: 2.0.0
---

# Start-Logging

## SYNOPSIS
Initializes the logging facility log4n using a configuration file.

## SYNTAX

```
Start-Logging [[-Filename] <String>]
```

## DESCRIPTION
Initializes the logging libary (Apache log4n)[https://logging.apache.org/log4net/] using a configuration file. If the parameter Filename is omitted the cmdlet will try using:
- %appdata%\log4net.xml
- %programdata%\log4net.xml
If no configuration file is found an error is thrown.

For details about Apache log4n please (https://logging.apache.org/log4net/)

## EXAMPLES

### EXAMPLE 1
```
Start-Logging
```
### EXAMPLE 2
```
Start-Logging -Filename logging.xml
```


## PARAMETERS

### -Filename
Path to the log4n configuration file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
AUTHOR: Marc Seguin

## RELATED LINKS
