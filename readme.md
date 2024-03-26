# NET.Office Tools

NET.Office Tools is a collection of helpful powershell functions put into a module.

## Table of Contents

- [Installation](#installation)
- [Provided Functions](#provided-functions)

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
The function encrypts a clear text into an encrypted text using the public key of a X509-certificate. The encrypted text is BASE64-encoded.

`ConvertTo-EncryptedText -ClearText=<Text to be encrypted> -Certificate <X509-Certificate>`
#### Example
First you may want to create  a self signed certificate and export it with its private key to `<./publicKey.cer>`.
```
$cert=Read-Certificate -FilePath './publickey.cer'
$EncryptedText=ConvertTo -ClearText 'Hello World' -Certificate $cert
Write-Host $EncryptedText
```
Output: `hPNDxSAO9LKsWP1Vc9S1gMgJGwAokOK/EV7LeVggmbwgAmZXnLcvID+Gsq1tEmLxQn2KZjYdSBqaZLR6TlbMD664+e8Qwuzhhc6HR2pQTl0+maG9DzqJa9imNIs7RhnEjDmZ+/u7TxrwiHrtkxBQSVOMpdmmKk7f5qKWC0Rt+Ov5HVxFztuoH0c50hW5vByUr6sJnhZZ2Ku42ZZobLJRHIbaTbVtLuZ9HMkLyTqUboelJDkI5SWbNNYNN1aJ3mWl2+TXHzOrvUv9oREw0KR/rdE92a8xehqHQqriJb4bH5x/hHcSyrGpO87dyCVAYCNxzZvke2F0yfVfX6K891S2gA==`

### ConverFrom-EncryptedText
The function decrypts an encrypted text into an clear text using the private key of a X509-certificate. The encrypted text must be BASE64-encoded.

`ConvertFrom-EncryptedText -ClearText=<Text to be encrypted> -Certificate <X509-Certificate>`
The encrypted text and the certifacte thumbprint are only examples.
In the example you need to change with thumbprint *A03830B8107B868916833E0FB0D241DDCCF2140F* with the thumbprint of the self-signed certificate you created before.
#### Example
```
$Cert=Get-Item Cert:\CurrentUser\My\A03830B8107B868916833E0FB0D241DDCCF2140F
$ClearText=ConvertFrom-EncryptedText 'hPNDxSAO9LKsWP1Vc9S1gMgJGwAokOK/EV7LeVggmbwgAmZXnLcvID+Gsq1tEmLxQn2KZjYdSBqaZLR6TlbMD664+e8Qwuzhhc6HR2pQTl0+maG9DzqJa9imNIs7RhnEjDmZ+/u7TxrwiHrtkxBQSVOMpdmmKk7f5qKWC0Rt+Ov5HVxFztuoH0c50hW5vByUr6sJnhZZ2Ku42ZZobLJRHIbaTbVtLuZ9HMkLyTqUboelJDkI5SWbNNYNN1aJ3mWl2+TXHzOrvUv9oREw0KR/rdE92a8xehqHQqriJb4bH5x/hHcSyrGpO87dyCVAYCNxzZvke2F0yfVfX6K891S2gA==' -Certificate $Cert
Write-Host $ClearText
```
Output: `Hello World`
