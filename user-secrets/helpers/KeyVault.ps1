function Connect-KeyVault {
<#
    .SYNOPSIS
        Connect to KeyVault for development environment.

    .PARAMETER EnvId
        The unique ID of the development environment.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-KeyVault -EnvId d01
        PS> Get-KeyVaultSecret -Key "abc"
        PS> Disconnect-KeyVault
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$EnvId
    )

    try {
        $userSecretsJson = dotnet user-secrets list --json --id dsi-tools
        $userSecrets = $userSecretsJson | select -Skip 1 | select -SkipLast 1 | ConvertFrom-Json
    }
    catch {
        Write-Output "Warning: Unable to access local user-secrets because dotnet command was not found."
        exit
    }

    $tenantId = (ConvertTo-SecureString $userSecrets.("${EnvId}:TenantId") -AsPlainText -Force)
    $applicationId = (ConvertTo-SecureString $userSecrets.("${EnvId}:ApplicationId") -AsPlainText -Force)
    $securePassword = (ConvertTo-SecureString $userSecrets.("${EnvId}:SecurePassword") -AsPlainText -Force)

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/x-www-form-urlencoded")
    $resourceURI = "https%3A%2F%2Fvault.azure.net"

    $body = "grant_type=client_credentials&client_id=$([System.Net.NetworkCredential]::new('', $applicationId).Password)&resource=$resourceURI&client_secret=$([System.Net.NetworkCredential]::new('', $securePassword).Password)"

    $tokenAuthURI = "https://login.microsoftonline.com/$([System.Net.NetworkCredential]::new('', $tenantId).Password)/oauth2/token"
    $tokenResponse = Invoke-RestMethod -Method 'POST' -Headers $headers -Body $body -Uri $tokenAuthURI

    $global:DsiConnectedKeyVaultEnvId = $EnvId
    $global:DsiConnectedKeyVaultAccessToken = $tokenResponse.access_token
}

function Disconnect-KeyVault {
<#
    .SYNOPSIS
        Disconnect from KeyVault.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Disconnect-KeyVault
#>
    [CmdletBinding()]

    $global:DsiConnectedKeyVaultEnvId = $null
    $global:DsiConnectedKeyVaultAccessToken = $null
}

function Get-KeyVaultSecret {
<#
    .SYNOPSIS
        Get a secret from the connected KeyVault.

    .PARAMETER Key
        The key of the secret.

    .OUTPUTS
        The retrieved secret.

    .EXAMPLE
        PS> Get-KeyVaultSecret -Key "abc"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Key
    )

    if (-not $global:DsiConnectedKeyVaultEnvId -or -not $global:DsiConnectedKeyVaultAccessToken) {
        throw "Cannot get secret because not connected."
    }

    $secretUrl = $("https://s141{0}-signin-kv.vault.azure.net/secrets/{1}?api-version=2016-10-01" -f `
        $global:DsiConnectedKeyVaultEnvId, `
        $Key
    )

    return (Invoke-RestMethod -Uri $secretUrl -Method GET -Headers @{Authorization="Bearer $global:DsiConnectedKeyVaultAccessToken"}).value
}
