function Import-DsiSecrets {
    <#
    .SYNOPSIS
        Import secrets for a hosted environment.

    .DESCRIPTION
        You must be connected to the environment in order for this command to work.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> Import-DsiSecrets
        PS> Disconnect-DsiEnv
    #>
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    Test-DsiConnectedEnv > $null


    #----- Entra Auth Extensions --------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Entra Auth Extensions" `
        -Id "835f69d2-f31e-49e5-9ade-963db5fa9f18"

    Set-DsiApiConnectionUserSecrets


    #----- Internal API -------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Internal API" `
        -Id "3583e031-7b0f-4819-9605-599cc22f4b9d"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "EntityFramework:Directories:Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework:Directories:Name"
            Value = "{{ platformGlobalDirectoriesDatabaseName }}"
        }
        @{
            Name  = "EntityFramework:Directories:Username"
            Value = "{{ svcSigninDir }}"
        }
        @{
            Name  = "EntityFramework:Directories:Password"
            Value = "{{ svcSigninDirPassword }}"
        }

        @{
            Name  = "EntityFramework:Organisations:Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework:Organisations:Name"
            Value = "{{ platformGlobalOrganisationsDatabaseName }}"
        }
        @{
            Name  = "EntityFramework:Organisations:Username"
            Value = "{{ svcSigninOrg }}"
        }
        @{
            Name  = "EntityFramework:Organisations:Password"
            Value = "{{ svcSigninOrgPassword }}"
        }

        @{
            Name  = "EntityFramework:Audit:Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework:Audit:Name"
            Value = "{{ platformGlobalAuditDatabaseName }}"
        }
        @{
            Name  = "EntityFramework:Audit:Username"
            Value = "{{ svcSigninAdt }}"
        }
        @{
            Name  = "EntityFramework:Audit:Password"
            Value = "{{ svcSigninAdtPassword }}"
        }
    )

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "PublicApiSecretEncryption:Key"
            Value = "{{ secureApiAes256Key }}"
        }
    )


    #----- Public API -------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Public API" `
        -Id "9cf57240-a4e9-44b7-8c09-922da90f69eb"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "BearerToken:ValidAudience"
            Value = "{{ papiValidAudience }}"
        }
        @{
            Name  = "PublicApiSecretEncryption:Key"
            Value = "{{ secureApiAes256Key }}"
        }
    )

    Set-DsiApiConnectionUserSecrets


    #----- Select Organisation ----------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Select Organisation" `
        -Id "9bc1d9ef-36ce-492e-876f-6d80fe79896c"

    Set-DsiApiConnectionUserSecrets


    #----- Profile -------------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Profile" `
        -Id "fa6df331-f36f-4e6c-a01d-a5b78c8b642f"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "Oidc:ClientId"
            Value = "{{ profileClientId }}"
        }
        @{
            Name  = "Oidc:ClientSecret"
            Value = "{{ profileClientSecret }}"
        }
        @{
            Name  = "Oidc:Authority"
            Value = "https://{{ standaloneOidcHostName }}"
        }
        @{
            Name  = "Oidc:MetadataAddress"
            Value = "https://{{ standaloneOidcHostName }}/.well-known/openid-configuration"
        }

        @{
            Name  = "ExternalId:ClientId"
            Value = "{{ dfeSigninHybridIntegrationAppClientId }}"
        }
        @{
            Name  = "ExternalId:ClientSecret"
            Value = "{{ dfeSigninHybridIntegrationAppSecret }}"
        }
        @{
            Name  = "ExternalId:Authority"
            Value = "{{ entraCloudInstance }}{{ entraTenantId }}"
        }
        @{
            Name  = "ExternalId:Instance"
            Value = "{{ entraInstanceUri }}"
        }
        @{
            Name  = "ExternalId:TenantId"
            Value = "{{ entraTenantId }}"
        }

        @{
            Name  = "GraphApi:Endpoint"
            Value = "{{ entraGraphEndpoint }}"
        }
    )

    Set-DsiApiConnectionUserSecrets


    #----- Help -------------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Help" `
        -Id "604df2cb-b96d-4942-93f6-acfd70ece5d0"

    $yourEmailAddress = (Get-AzContext).Account.Id.ToLower()

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "GovNotify:ApiKey"
            Value = "{{ govNotifyApiKey }}"
        }
        @{
            Name  = "RaiseSupportTicketByEmail:SupportEmailAddress"
            Value = $yourEmailAddress
        }
    )

    Set-DsiApiConnectionUserSecrets
}
