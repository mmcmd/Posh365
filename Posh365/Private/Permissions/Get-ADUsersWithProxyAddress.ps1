﻿Function Get-ADUsersWithProxyAddress {
    <#
    .SYNOPSIS


    .EXAMPLE

    
    #>
    param (
        [Parameter()]
        [hashtable] $DomainNameHash
    )
    Try {
        import-module activedirectory -ErrorAction Stop
    }
    Catch {
        Write-Host "This module depends on the ActiveDirectory module."
        Write-Host "Please download and install from https://www.microsoft.com/en-us/download/details.aspx?id=45520"
        throw
    }
    Get-ADUser -filter 'proxyaddresses -ne "$null"' -server ($dc + ":3268") -SearchBase (Get-ADRootDSE).rootdomainnamingcontext -SearchScope Subtree -Properties displayname, canonicalname | Select distinguishedname, canonicalname, displayname, userprincipalname, @{n = "logon"; e = {($DomainNameHash.($_.distinguishedname -replace '^.+?DC=' -replace ',DC=', '.')) + "\" + $_.samaccountname}} 
}