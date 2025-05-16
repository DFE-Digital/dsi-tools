[CmdletBinding()]
param(
    [string]$EnvId
)

$ErrorActionPreference = "Stop"


#
# Attempt to retrieve parameters from dotnet user-secrets.
#

try {
	$userSecretsJson = dotnet user-secrets list --json --id login.dfe.dsi-config
	$userSecrets = $userSecretsJson | select -Skip 1 | select -SkipLast 1 | ConvertFrom-Json
}
catch {
	Write-Output "Warning: Unable to access local user-secrets because dotnet command was not found."
    exit
}

$TenantId = (ConvertTo-SecureString $userSecrets.("${EnvId}:TenantId") -AsPlainText -Force)
$ApplicationId = (ConvertTo-SecureString $userSecrets.("${EnvId}:ApplicationId") -AsPlainText -Force)
$SecurePassword = (ConvertTo-SecureString $userSecrets.("${EnvId}:SecurePassword") -AsPlainText -Force)


#
# Retrieving secrets from KeyVault.
#

function GetKeyVaultAccessToken {
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/x-www-form-urlencoded")
    $resourceURI = "https%3A%2F%2Fvault.azure.net"

    $body = "grant_type=client_credentials&client_id=$([System.Net.NetworkCredential]::new('', $ApplicationId).Password)&resource=$resourceURI&client_secret=$([System.Net.NetworkCredential]::new('', $SecurePassword).Password)"

    $tokenAuthURI = "https://login.microsoftonline.com/$([System.Net.NetworkCredential]::new('', $TenantId).Password)/oauth2/token"
    $tokenResponse = Invoke-RestMethod -Method 'POST' -Headers $headers -Body $body -Uri $tokenAuthURI

    return $tokenResponse.access_token
}

$keyVaultAccessToken = GetKeyVaultAccessToken
$keyVaultSecretsUrl = "https://s141$EnvId-signin-kv.vault.azure.net/secrets/{0}?api-version=2016-10-01"

function GetSecret {
    param(
        [string]$key
    )
    $secretUrl = $keyVaultSecretsUrl -f $key
    return (Invoke-RestMethod -Uri $secretUrl -Method GET -Headers @{Authorization="Bearer $keyVaultAccessToken"}).value
}


#
# Retrieve application secrets from KeyVault and update dotnet user-secrets.
#

$userSecretsId = ""

function SetUserSecret {
    param(
        [string]$localKey,
        [string]$secret
    )
    Write-Output "Setting user secret '$localKey'..."
    dotnet user-secrets set $localKey $secret --id $userSecretsId > $null
}

function MapUserSecret {
    param(
        [string]$localKey,
        [string]$secretKey,
        [string]$template = "<secret>"
    )
    $secret = GetSecret($secretKey)
    $secret = $template -replace "<secret>", $secret
    SetUserSecret $localKey $secret
}

function SetNodeApiUserSecrets {
    param(
        [string]$apiName
    )

    MapUserSecret "NodeApiClient:Apis:${apiName}:BaseAddress" "standalone${apiName}HostName" "http://<secret>"
    MapUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:Tenant" "platformGlobalTenantDomain"
    MapUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:Resource" "aadshdappid"
    MapUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:HostUrl" "tenantUrl"
    MapUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:ClientSecret" "aadshdclientsecret"
    MapUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:ClientId" "aadshdclientid"

    if ($IsMacOS) {
        # .NET on MacOS requires a proxy to workaround lack of support for TLS version.
        SetUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:UseProxy" "true"
        SetUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:ProxyUrl" "http://localhost:8080"
    }
    else {
        SetUserSecret "NodeApiClient:Apis:${apiName}:AuthenticatedHttpClientOptions:UseProxy" "false"
    }
}

Write-Output "Setup: Public API..."
$userSecretsId = "9cf57240-a4e9-44b7-8c09-922da90f69eb"
SetUserSecret "BearerToken:ValidAudience" "signin.education.gov.uk"
SetNodeApiUserSecrets "Organisations"
SetNodeApiUserSecrets "Directories"
SetNodeApiUserSecrets "Applications"
SetNodeApiUserSecrets "Access"

Write-Output "Setup: Select Organisation..."
$userSecretsId = "9bc1d9ef-36ce-492e-876f-6d80fe79896c"
SetNodeApiUserSecrets "Organisations"
SetNodeApiUserSecrets "Directories"
SetNodeApiUserSecrets "Applications"
SetNodeApiUserSecrets "Access"
