# JOAT-Config
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Seekatar/joat-config/blob/master/LICENSE)
[![PowerShell Gallery - JOAT-Config](https://img.shields.io/badge/PowerShell%20Gallery-joat--config-blue.svg)](https://www.powershellgallery.com/packages/joat-config)
[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.0-blue.svg)](https://github.com/PowerShell/PowerShell)

|Build, Test, Publish status |
|---|
|![Build](https://dev.azure.com/seekatar0863/JoatConfig/_apis/build/status/JoatConfig-CI)|

## Introduction
This PowerShell module has scripts for getting and setting configuration values for the current user, optionally encrypting it.  This is useful when doing automation and you need to store and retrieve configuration values to avoid hardcoding or committing to git, such as PAT, passwords, etc.

## Requirements

- Windows PowerShell 5.0 or newer.
- PowerShell Core.

## Installation
JOAT-Config is in the [PowerShell Gallery]().  To install it, execute the following command.

```powershell
Install-Module -Name joat-config
```

## Usage
The two main functions are `Get-ConfigData` and `Set-ConfigData` which basically set and get a key-value pair in a file in the user's home folder.  Help is available for all commands.  And the source has Pester tests.

For example, you can store local-specific configuration.

```powershell
Set-ConfigData my.servername -value 'host-123'

Invoke-Command {dir} -computername (Get-ConfigData my.servername)
```

Or more useful is storing encrypted data, such as PAT, APIKeys, etc.

```powershell
Set-ConfigData 'Azure.TenantId' -value 'mytenantId' -Encrypt
Set-ConfigData 'Azure.My.SubscriptionId' -value 'mysubscriptionid' -Encrypt

Connect-AzureRmAccount -TenantId (Get-ConfigData 'Azure.TenantId' -Decrypt) `
        -Subscription (Get-ConfigData 'Azure.My.SubscriptionId' -Decrypt) `
        -Credential (Get-Credential)
```

You can use dotted names to group things, or you can use objects well.

```powershell
$azureConfig = @{
    TenantId = 'tidsecret'
    SubscriptionId = 'sidsecret'
    PAT = 'verysecret'
}

Set-ConfigData -Name "AzConfig" -Value $azureConfig -Encrypt

$config = Get-ConfigData -Name AzConfig -Decrypt
$config.PAT # verysecret
```
Since encrypted strings are stored as `SecureString`s if a cmdlet takes it, you don't need to decrypt.
```powershell
ipmo VSTeam
Set-ConfigData AzurePat ukxzlafg7aalwzku4m2xzjsysoe65azzruqhady4di4qfx2pd2oq -Encrypt

Add-VSTeamAccount -SecurePersonalAccessToken (Get-ConfigData AzurePat) -Account myaccount
```
## File Location
By default, the json file is `~/myconfig.json`.  You can override it by passing in `Path` to any command, setting `$env:joat_config_path` or using `$PSDefaultParameterValues`  You may want to backup this file.  To see the path that will be used, call `Get-ConfigDataPath`

**Note:** Currently only Windows supports encrypting and decrypting of data as well as using SecureStrings.

# Other Stuff
This is one of my more polished set of tools created years ago and finally put out in the Gallery.  Check out other stuff at https://github.com/Seekatar
