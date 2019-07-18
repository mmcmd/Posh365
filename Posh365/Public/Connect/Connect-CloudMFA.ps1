function Connect-CloudMFA {
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $MSOnline,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $Compliance,

        [Parameter()]
        [switch]
        $DeleteCredential
    )
    end {
        if ($Tenant -match 'onmicrosoft') { $Tenant = $Tenant.Split(".")[0] }

        $host.ui.RawUI.WindowTitle = "Tenant: $($Tenant.ToUpper())"
        $PoshPath = Join-Path $Env:USERPROFILE '.Posh365'
        $TenantPath = Join-Path $PoshPath $Tenant
        $CredPath = Join-Path $TenantPath 'Credentials'
        $CredFile = Join-Path $CredPath CC.xml
        $LogPath = Join-Path $TenantPath 'Logs'

        if (-not ($null = Test-Path $CredFile)) {
            $ItemSplat = @{
                Type        = 'Directory'
                Force       = $true
                ErrorAction = 'SilentlyContinue'
            }
            $null = New-Item $PoshPath @ItemSplat
            $null = New-Item $CredPath @ItemSplat
            $null = New-Item $LogPath @ItemSplat
        }

        switch ($true) {
            $DeleteCredential {
                Write-Host "Deleting credential and halting script" Write-Host -ForegroundColor White
                Connect-CloudDeleteCredential -CredFile $CredFile
                break
            }
            { $ExchangeOnline -or $MSOnline -or $AzureAD -or $Compliance } {
                if ($null = Test-Path $CredFile) {
                    Connect-CloudMFAClip -CredFile $CredFile
                }
                else {
                    [System.Management.Automation.PSCredential]$Credential = Get-Credential -Message 'Enter Office 365 username and password'
                    [System.Management.Automation.PSCredential]$Credential | Export-CliXml -Path $CredFile
                    [System.Management.Automation.PSCredential]$Credential = Import-CliXml -Path $CredFile
                    Connect-CloudMFAClip -CredFile $CredFile
                }
            }
            { $ExchangeOnline -or $Compliance } {
                Connect-CloudModuleImport -ExchangeOnline
            }
            $ExchangeOnline {
                Import-Module (Connect-EXOPSSession) -Global -WarningAction SilentlyContinue -DisableNameChecking
                Write-Host "Connected to Exchange Online" -ForegroundColor Green
            }
            $Compliance {
                Import-Module (Connect-IPPSSession) -Global -NoClobber
                Write-Host "Connected to Security & Compliance" -ForegroundColor Green
            }
            $MSOnline {
                Connect-CloudModuleImport -MSOnline
                Connect-MsolService
                Write-Host "Connected to Microsoft Online" -ForegroundColor Green
            }
            $AzureAD {
                Connect-CloudModuleImport -AzureAD
                Connect-AzureAD
                Write-Host "Connected to Azure AD" -ForegroundColor Green
            }
            default {

            }
        }
        Get-RSJob -State Completed | Remove-RSJob -ErrorAction SilentlyContinue
    }
}
