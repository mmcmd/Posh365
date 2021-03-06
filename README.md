# Posh365
Module used by Office 365 consultants and admins to migrate, discover and manage.

This module leverages several native cmdlets.  I created this for my everyday use.
All feedback is welcome.

## Prerequisite when TLS1.2 is not enforced
If you receive an error attempting to installing the module. Run this and try again.
```
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
```

## How to install
```
Install-Module Posh365 -Force
```

## Install without admin access
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Install-Module Posh365 -Force -Scope CurrentUser
```


## Function Examples
_Syntax_: https://github.com/kevinblumenfeld/Posh365Demo

### Connect
* **Connect-CloudMFA** Connect to EXO, MSOnline, AzureAD, SharePoint, Compliance.

### Migrate
* **New-MailboxMove** Creates new move requests
* **Get-MailboxMove** Gets current move requests.
* **Set-MailboxMove** Set move requests.
* **Suspend-MailboxMove** Suspends move requests.
* **Resume-MailboxMove** Resumes move requests. Includes the switch -DontAutoComplete
* **Remove-MailboxMove** Removes move requests.
* **Complete-MailboxMove** Complete move requests.

### Report
* **Get-MailboxMoveStatistics** Gets move request statistics.
* **Get-MailboxMoveReport** Gets full move request report.

### License
* **Set-MailboxMoveLicense** Licenses users via AzureAD.
* **Get-MailboxMoveLicense** Reports on user licenses.
* **Get-MailboxMoveLicenseCount** Reports on a tenant's skus and options.
* **Get-MailboxMoveLicenseReport** Reports on each user's assigned skus and options.

### Office365 Endpoints
* **Get-OfficeEndpoints** URLs and IPs, initial and "changes since"

![ME3V6nNhwV](https://user-images.githubusercontent.com/28877715/71635906-fcb6a980-2bf6-11ea-927e-03c9bda8f2a4.gif)
