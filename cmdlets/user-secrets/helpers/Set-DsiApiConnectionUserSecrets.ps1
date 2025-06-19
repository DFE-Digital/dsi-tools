function Set-DsiApiConnectionUserSecrets {
    <#
    .SYNOPSIS
        Import secrets to connect to a hosted Node API component.

    .PARAMETER ApiName
        Name of the hosted Node API.

    .PARAMETER Force
        Force invocation without prompting for confirmation.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-DsiSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-DsiApiConnectionUserSecrets -ApiName Directories
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet only sets local user secrets.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [String]$ApiName
    )

    $ErrorActionPreference = "Stop"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:BaseAddress"
            Value = "http://{{ standalone${ApiName}HostName }}"
        }
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:Tenant"
            Value = "{{ platformGlobalTenantDomain }}"
        }
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:Resource"
            Value = "{{ aadshdappid }}"
        }
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:HostUrl"
            Value = "{{ tenantUrl }}"
        }
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ClientSecret"
            Value = "{{ aadshdclientsecret }}"
        }
        @{
            Name  = "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ClientId"
            Value = "{{ aadshdclientid }}"
        }
    )

    # .NET on MacOS requires a proxy to workaround lack of support for TLS version.
    if ($IsMacOS) {
        Set-DsiUserSecret `
            -Name "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:UseProxy" `
            -Value "true"

        Set-DsiUserSecret `
            -Name "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:ProxyUrl" `
            -Value "http://localhost:8080"
    }
    else {
        Set-DsiUserSecret `
            -Name "NodeApiClient:Apis:${ApiName}:AuthenticatedHttpClientOptions:UseProxy" `
            -Value "false"
    }
}
