function Import-DsiSecrets {
<#
    .SYNOPSIS
        Import secrets for a hosted environment.

    .NOTES
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

    Test-DsiConnectedEnv


    #----- Public API -------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "Public API" `
        -Id "9cf57240-a4e9-44b7-8c09-922da90f69eb"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name = "BearerToken:ValidAudience"
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


    #----- UI Tests ---------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "UI Tests" `
        -Id "74491194-d775-4d5f-973f-870ed02a95fc"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name = "Platform:ServicesBaseAddress"
            Value = "https://{{ standaloneServicesHostName }}"
        }
        @{
            Name = "Platform:ProfileBaseAddress"
            Value = "https://{{ standaloneProfileHostName }}"
        }
        @{
            Name = "Platform:ManageBaseAddress"
            Value = "https://{{ standaloneManageHostName }}"
        }
        @{
            Name = "Platform:InteractionsBaseAddress"
            Value = "https://{{ standaloneInteractionsHostName }}"
        }
        @{
            Name = "Platform:PublicApiBaseAddress"
            Value = "https://{{ standalonePublicApiHostName }}"
        }
    )

}
