function Invoke-NewCloudData {

    [CmdletBinding()]
    param (
        [Parameter()]
        $ConvertedData
    )
    $ErrorActionPreference = 'stop'

    $ConvertedList = $ConvertedData | Where-Object { $_.Type -eq 'Recipient' }
    foreach ($Converted in $ConvertedList) {
        $MeuCreated, $MeuSet = $null
        $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(16, 7)
        try {
            $NewParams = @{
                Name                      = $Converted.DisplayName
                DisplayName               = $Converted.DisplayName
                MicrosoftOnlineServicesID = $Converted.UserPrincipalName
                PrimarySMTPAddress        = $Converted.UserPrincipalName
                Alias                     = $Converted.Alias
                Password                  = ConvertTo-SecureString -String $GeneratedPW -AsPlainText:$true -Force
                ExternalEmailAddress      = $Converted.SourceInitial
                ErrorAction               = 'Stop'
            }
            $MeuCreated = New-MailUser @NewParams
            Write-Host "New Meu: $($MeuCreated.DisplayName)" -ForegroundColor Green

            $SetParams = @{
                Identity       = $MeuCreated.ExternalDirectoryObjectId
                EmailAddresses = @{Add = $Converted.EmailAddresses -split [regex]::Escape('|') }
                ErrorAction    = 'Stop'
            }
            if ($Converted.RecipientType -eq 'USERMAILBOX') {
                $SetParams['ExchangeGuid'] = $Converted.ExchangeGuid
            }
            $MeuSet = Set-MailUser @SetParams
            Write-Host "Set Meu: $($MeuCreated.DisplayName)" -ForegroundColor Green

            [PSCustomObject]@{
                ResultNew                 = 'SUCCESS'
                ResultSet                 = 'SUCCESS'
                Name                      = $MeuCreated.Name
                DisplayName               = $MeuCreated.DisplayName
                SourceType                = $Converted.RecipientTypeDetails
                MicrosoftOnlineServicesID = $MeuCreated.MicrosoftOnlineServicesID
                UserPrincipalName         = $MeuCreated.UserPrincipalName
                PrimarySMTPAddress        = $MeuCreated.PrimarySMTPAddress
                Alias                     = $MeuCreated.Alias
                ExchangeGuid              = $Converted.ExchangeGuid
                SourceId                  = $Converted.ExternalDirectoryObjectId
                TargetId                  = $MeuCreated.ExternalDirectoryObjectId
                Password                  = $GeneratedPW
                EmailAddresses            = $Converted.ExternalEmailAddress
                Log                       = 'SUCCESS'
            }

        }
        catch {
            if ($MeuCreated -and -not $MeuSet) {
                [PSCustomObject]@{
                    ResultNew                 = 'SUCCESS'
                    ResultSet                 = 'FAILED'
                    Name                      = $MeuCreated.Name
                    DisplayName               = $MeuCreated.DisplayName
                    SourceType                = $Converted.RecipientTypeDetails
                    MicrosoftOnlineServicesID = $MeuCreated.MicrosoftOnlineServicesID
                    UserPrincipalName         = $MeuCreated.UserPrincipalName
                    PrimarySMTPAddress        = $MeuCreated.PrimarySMTPAddress
                    Alias                     = $MeuCreated.Alias
                    ExchangeGuid              = $Converted.ExchangeGuid
                    SourceId                  = $MeuCreated.ExternalDirectoryObjectId
                    TargetId                  = $MeuCreated.ExternalDirectoryObjectId
                    Password                  = $GeneratedPW
                    EmailAddresses            = $Converted.ExternalEmailAddress
                    Log                       = $_.Exception.Message
                }
                Write-Host "Set Meu failed: $($MeuCreated.DisplayName)" -ForegroundColor Red
            }
            else {
                [PSCustomObject]@{
                    ResultNew                 = 'FAILED'
                    ResultSet                 = 'FAILED'
                    Name                      = $Converted.DisplayName
                    DisplayName               = $Converted.DisplayName
                    SourceType                = $Converted.RecipientTypeDetails
                    MicrosoftOnlineServicesID = $Converted.UserPrincipalName
                    UserPrincipalName         = $Converted.UserPrincipalName
                    PrimarySMTPAddress        = $Converted.PrimarySMTPAddress
                    Alias                     = $Converted.Alias
                    ExchangeGuid              = $Converted.ExchangeGuid
                    SourceId                  = $Converted.ExternalDirectoryObjectId
                    TargetId                  = ''
                    Password                  = $GeneratedPW
                    EmailAddresses            = $Converted.ExternalEmailAddress
                    Log                       = $_.Exception.Message
                }
                Write-Host "New and Set Meu failed: $($MeuCreated.DisplayName)" -ForegroundColor Red
            }
        }
    }
    $ConvertedAzList = $ConvertedData | Where-Object { $_.Type -eq 'AzureADUser' }
    foreach ($ConvertedAz in $ConvertedAzList) {
        try {
            $GeneratedPW = [System.Web.Security.Membership]::GeneratePassword(16, 7)
            $PasswordProfile = [Microsoft.Open.AzureAD.Model.PasswordProfile]::new()
            $PasswordProfile.Password = $GeneratedPW
            $AzUserParams = @{
                DisplayName       = $ConvertedAz.DisplayName
                UserPrincipalName = $ConvertedAz.AzureADUPN
                MailNickName      = ($ConvertedAz.AzureADUPN -split '@')[0]
                PasswordProfile   = $PasswordProfile
                AccountEnabled    = $true
                ErrorAction       = 'Stop'
            }
            $NewAzADUser = New-AzureADUser @AzUserParams
            Write-Host "New AzureAdUser: $($NewAzADUser.DisplayName)" -ForegroundColor Green
            [PSCustomObject]@{
                ResultNew                 = 'SUCCESS'
                ResultSet                 = 'SUCCESS'
                Name                      = $ConvertedAz.DisplayName
                DisplayName               = $NewAzADUser.DisplayName
                SourceType                = $ConvertedAz.Type
                MicrosoftOnlineServicesID = ''
                UserPrincipalName         = $NewAzADUser.UserPrincipalName
                PrimarySMTPAddress        = ''
                Alias                     = ($ConvertedAz.AzureADUPN -split '@')[0]
                ExchangeGuid              = ''
                SourceId                  = $ConvertedAz.ExternalDirectoryObjectId
                TargetId                  = $NewAzADUser.ObjectId
                Password                  = $GeneratedPW
                EmailAddresses            = ''
                Log                       = 'SUCCESS'
            }
        }
        catch {
            [PSCustomObject]@{
                ResultNew                 = 'FAILED'
                ResultSet                 = 'FAILED'
                Name                      = $ConvertedAz.DisplayName
                DisplayName               = $ConvertedAz.DisplayName
                SourceType                = $ConvertedAz.Type
                MicrosoftOnlineServicesID = ''
                UserPrincipalName         = $ConvertedAz.UserPrincipalName
                PrimarySMTPAddress        = ''
                Alias                     = ($ConvertedAz.AzureADUPN -split '@')[0]
                ExchangeGuid              = ''
                SourceId                  = $ConvertedAz.ExternalDirectoryObjectId
                TargetId                  = ''
                Password                  = $GeneratedPW
                EmailAddresses            = ''
                Log                       = $_.Exception.Message
            }
            Write-Host "New AzureAdUser failed: $($NewAzADUser.DisplayName)" -ForegroundColor Red
        }
    }
    $ErrorActionPreference = 'continue'
}