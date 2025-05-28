function Get-DsiKeyVaultSecret {
<#
    .SYNOPSIS
        Gets a secret from the connected KeyVault.

    .PARAMETER Name
        Name of secret in the active KeyVault.

    .OUTPUTS
        The secret value.

    .EXAMPLE
        PS> Get-DsiKeyVaultSecret -Name secretname
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    Test-DsiConnectedEnv

    $secret = Get-AzKeyVaultSecret `
        -VaultName $global:DsiConnectedEnv.KeyVault `
        -Name $Name `
        -AsPlainText

    return $secret
}
