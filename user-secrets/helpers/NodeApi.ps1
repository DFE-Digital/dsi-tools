. "$PSScriptRoot/UserSecrets.ps1"

function Set-NodeApiUserSecretsFromKeyVault {
<#
    .SYNOPSIS
        Import secrets to connect to a hosted Node API component.

    .PARAMETER ApiName
        Name of the hosted Node API.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-UserSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-NodeApiUserSecretsFromKeyVault -ApiName Directories
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ApiName
    )

    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:BaseAddress" -FromKey "standalone${ApiName}HostName" -FromKey "http://<secret>"
    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:Tenant" -FromKey "platformGlobalTenantDomain"
    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:Resource" -FromKey "aadshdappid"
    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:HostUrl" -FromKey "tenantUrl"
    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ClientSecret" -FromKey "aadshdclientsecret"
    Set-UserSecretFromKeyVault -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ClientId" -FromKey "aadshdclientid"

    if ($IsMacOS) {
        # .NET on MacOS requires a proxy to workaround lack of support for TLS version.
        Set-UserSecret -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:UseProxy" -Value "true"
        Set-UserSecret -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ProxyUrl" -Value "http://localhost:8080"
    }
    else {
        Set-UserSecret -Key "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:UseProxy" -Value "false"
    }
}
