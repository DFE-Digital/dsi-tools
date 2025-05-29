function Set-DsiKeyVaultSecret {
<#
    .SYNOPSIS
        Sets a secret in the connected KeyVault.

    .PARAMETER Name
        Name of the secret.

    .PARAMETER SecretValue
        New value for the secret.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Set-DsiKeyVaultSecret -Name secretname -SecretValue abc
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [SecureString]$SecretValue
    )

    Test-DsiConnectedEnv > $null

    $secret = Set-AzKeyVaultSecret `
        -VaultName $global:DsiConnectedEnv.KeyVault `
        -Name $Name `
        -SecretValue $SecretValue `
        -Confirm

    return $secret
}
