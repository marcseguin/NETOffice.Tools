---
external help file: NETOffice.Tools-help.xml
Module Name: NETOffice.Tools
online version:
schema: 2.0.0
---

# Add-CodeSignature

## SYNOPSIS
Adds or updates digital code signature to a file.

## SYNTAX

```
Add-CodeSignature [[-Filename] <String>] [[-CodeSignerThumbprint] <String>]
```

## DESCRIPTION
The function signes signature of a file. The used certificate is identified by its thumbprint. The signer must have available the certificate and its coresponsing private key to his Windows personal certificate store.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-CodeSignature -Filename do-mystuff.ps1 -CodeSignerThumbprint e4d1df854984ab0d17bf5de3edf7cc67c02a0928
```

The command signes the filename do-mystuff.ps1 with the certificate identified by its thumbprint e4d1df854984ab0d17bf5de3edf7cc67c02a0928.

## PARAMETERS

### -CodeSignerThumbprint
Identifying thumbprint for the certificate to be used for signature.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: false
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filename
Filename of the file which is to be signed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
