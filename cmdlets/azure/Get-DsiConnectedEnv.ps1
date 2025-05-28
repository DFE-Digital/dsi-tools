function Get-DsiConnectedEnv {
<#
    .SYNOPSIS
        Identifies the current DfE Sign-in environment.

    .OUTPUTS
        Metadata for the current connection with the following properties:
            - Name - The name of the environment (eg. "DEV").
            - Subscription - The name of the associated subscription.
            - Prefix - The resource prefix.
            - KeyVault - The name of the KeyVault resource.

    .EXAMPLE
        PS> Get-DsiConnectedEnv
#>
    [CmdletBinding()]
    param ()

    return $global:DsiConnectedEnv
}
