function Get-DsiKeyVaultSecret {
<#
    .SYNOPSIS
        Gets a secret from the connected KeyVault.

    .PARAMETER Name
        Name of the secret.

    .OUTPUTS
        The secret value.

    .EXAMPLE
        PS> Get-DsiKeyVaultSecret -Name secretname
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    Test-DsiConnectedEnv > $null

    $secret = Get-AzKeyVaultSecret `
        -VaultName $global:DsiConnectedEnv.KeyVault `
        -Name $Name `
        -AsPlainText

    return $secret
}
