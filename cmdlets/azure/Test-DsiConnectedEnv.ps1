function Test-DsiConnectedEnv {
<#
    .SYNOPSIS
        Tests that there is an active DfE Sign-in environment.

    .NOTES
        Throws an error if there is no connection.
    
    .PARAMETER Name
        When specified, this command tests that the specified envrionment is connected:
            - TRAN
            - DEV
            - TEST
            - PREPROD
            - PROD

    .OUTPUTS
        Metadata for the connected environment:
            - Name - The name of the environment (eg. "DEV").
            - Subscription - The name of the associated subscription.
            - Prefix - The resource prefix.
            - KeyVault - The name of the KeyVault resource.
#>
    [CmdletBinding()]
    param (
        [String]$Name = $null
    )

    if ($Name -and $Name -ne $global:DsiConnectedEnv.Name) {
        throw "Not connected to the DfE Sign-in '$Name' environment. Use `Connect-DsiEnv -Name $Name` to connect."
    }

    if (-not $global:DsiConnectedEnv) {
        throw "Not connected to a DfE Sign-in environment. Use `Connect-DsiEnv` to connect."
    }

    return $global:DsiConnectedEnv
}
