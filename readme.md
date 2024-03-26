# NET.Office Tools

NET.Office Tools is a collection of helpful powershell functions put into a module.

## Table of Contents

- [Installation](#installation)
- [Provided Functions](#providedfunctions)
- [Contributing](#contributing)
- [License](#license)

## Installation

Currently the easiest way is to copy the subdirectory **NET.Office Tools** into your powershell module directory (e.g. `%ProgramFiles%\WindowsPowerShell\Modules`).

## Provided functions
Here the overview to the provided Functions

### Read-Certificate
The function reads a X509-certificate with its public key from a file

`Read-Certificate -FilePath <Path/To/File>`
#### Example
`$cert=Read-Certificate -FilePath './publickey.cer'`

### ConvertTo-EncryptedText
The function encrypts a clear text into an encrypted text using the public key of a X509-certificate. The encrypted text is BASE64 encoded.

`ConvertTo-EncryptedText -ClearText=<Text to be encrypted> -Certificate <X509-Certificate>`
#### Example
`$EncryptedText=ConvertTo -ClearText 'Hello World' -Certificate $cert`

