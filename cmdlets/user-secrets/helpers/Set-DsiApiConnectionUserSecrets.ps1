function Set-DsiApiConnectionUserSecrets {
    <#
    .SYNOPSIS
        Import secrets to connect to a hosted internal API component.

    .PARAMETER Force
        Force invocation without prompting for confirmation.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-DsiSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-DsiApiConnectionUserSecrets
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet only sets local user secrets.'
    )]
    param ()

    $ErrorActionPreference = "Stop"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "InternalApiClient:BaseAddress"
            Value = "{{ standaloneIntapiHostName }}"
            NonHttp = $true
        }
        @{
            Name  = "InternalApiClient:Tenant"
            Value = "{{ platformGlobalTenantDomain }}"
        }
        @{
            Name  = "InternalApiClient:Resource"
            Value = "{{ aadshdappid }}"
        }
        @{
            Name  = "InternalApiClient:HostUrl"
            Value = "{{ tenantUrl }}"
        }
        @{
            Name  = "InternalApiClient:ClientSecret"
            Value = "{{ aadshdclientsecret }}"
        }
        @{
            Name  = "InternalApiClient:ClientId"
            Value = "{{ aadshdclientid }}"
        }
    )

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "InternalApiClient:Access:BaseAddress"
            Value = "{{ standaloneAccHostName }}"
            NonHttp = $true
        }
        @{
            Name  = "InternalApiClient:Applications:BaseAddress"
            Value = "{{ standaloneAppHostName }}"
            NonHttp = $true
        }
        @{
            Name  = "InternalApiClient:Directories:BaseAddress"
            Value = "{{ standaloneDirHostName }}"
            NonHttp = $true
        }
        @{
            Name  = "InternalApiClient:Organisations:BaseAddress"
            Value = "{{ standaloneOrgHostName }}"
            NonHttp = $true
        }
        @{
            Name  = "InternalApiClient:Search:BaseAddress"
            Value = "{{ standaloneSchHostName }}"
            NonHttp = $true
        }
    )

    # .NET on MacOS requires a proxy to workaround lack of support for TLS version.
    if ($IsMacOS) {
        Set-DsiUserSecret `
            -Name "InternalApiClient:UseProxy" `
            -Value "true"

        Set-DsiUserSecret `
            -Name "InternalApiClient:ProxyUrl" `
            -Value "http://localhost:8080"
    }
    else {
        Set-DsiUserSecret `
            -Name "InternalApiClient:UseProxy" `
            -Value "false"
    }
}
