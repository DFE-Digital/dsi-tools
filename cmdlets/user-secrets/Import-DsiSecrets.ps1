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

    Set-DsiApiConnectionUserSecrets -ApiName "Organisations"
    Set-DsiApiConnectionUserSecrets -ApiName "Directories"
    Set-DsiApiConnectionUserSecrets -ApiName "Access"
    Set-DsiApiConnectionUserSecrets -ApiName "Search"


    #----- Internal API -------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Internal API" `
        -Id "3583e031-7b0f-4819-9605-599cc22f4b9d"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "EntityFramework__Directories__Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework__Directories__Name"
            Value = "{{ platformGlobalDirectoriesDatabaseName }}"
        }
        @{
            Name  = "EntityFramework__Directories__Username"
            Value = "{{ svcSigninDir }}"
        }
        @{
            Name  = "EntityFramework__Directories__Password"
            Value = "{{ svcSigninDirPassword }}"
        }

        @{
            Name  = "EntityFramework__Organisations__Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework__Organisations__Name"
            Value = "{{ platformGlobalOrganisationsDatabaseName }}"
        }
        @{
            Name  = "EntityFramework__Organisations__Username"
            Value = "{{ svcSigninOrg }}"
        }
        @{
            Name  = "EntityFramework__Organisations__Password"
            Value = "{{ svcSigninOrgPassword }}"
        }

        @{
            Name  = "EntityFramework__Audit__Host"
            Value = "{{ platformGlobalServerName }}"
        }
        @{
            Name  = "EntityFramework__Audit__Name"
            Value = "{{ platformGlobalAuditDatabaseName }}"
        }
        @{
            Name  = "EntityFramework__Audit__Username"
            Value = "{{ svcSigninAdt }}"
        }
        @{
            Name  = "EntityFramework__Audit__Password"
            Value = "{{ svcSigninAdtPassword }}"
        }
    )


    #----- Public API -------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Public API" `
        -Id "9cf57240-a4e9-44b7-8c09-922da90f69eb"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "BearerToken:ValidAudience"
            Value = "signin.education.gov.uk"
        }
    )

    Set-DsiApiConnectionUserSecrets -ApiName "Organisations"
    Set-DsiApiConnectionUserSecrets -ApiName "Directories"
    Set-DsiApiConnectionUserSecrets -ApiName "Applications"
    Set-DsiApiConnectionUserSecrets -ApiName "Access"


    #----- Select Organisation ----------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Select Organisation" `
        -Id "9bc1d9ef-36ce-492e-876f-6d80fe79896c"

    Set-DsiApiConnectionUserSecrets -ApiName "Organisations"
    Set-DsiApiConnectionUserSecrets -ApiName "Directories"
    Set-DsiApiConnectionUserSecrets -ApiName "Applications"
    Set-DsiApiConnectionUserSecrets -ApiName "Access"


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

    Set-DsiApiConnectionUserSecrets -ApiName "Directories"


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

    Set-DsiApiConnectionUserSecrets -ApiName "Applications"
}
