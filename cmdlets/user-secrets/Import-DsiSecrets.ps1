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
