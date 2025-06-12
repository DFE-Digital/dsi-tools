function Set-DsiKeyVaultSecret {
    <#
    .SYNOPSIS
        Sets a secret in the connected KeyVault.

    .PARAMETER Name
        Name of the secret.

    .PARAMETER SecretValue
        New value for the secret.

    .PARAMETER Force
        Force invocation without prompting for confirmation.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Set-DsiKeyVaultSecret -Name secretname -SecretValue abc

        Confirm
        Are you sure you want to perform this action?
        Performing the operation 'Set secret in KeyVault' for the 'DEV' environment.
        [Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter(Mandatory = $true)]
        [SecureString]$SecretValue,

        [Switch]$Force
    )

    Test-DsiConnectedEnv > $null

    if (-not ($Force -or $PSCmdlet.ShouldContinue(@"
Are you sure you want to perform this action?
Performing the operation 'Set secret in KeyVault' for the '$($global:DsiConnectedEnv.Name)' environment.
"@, 'Confirm'))) {
        Write-Output "Cancelled."
        return
    }

    return Set-AzKeyVaultSecret `
        -VaultName $global:DsiConnectedEnv.KeyVault `
        -Name $Name `
        -SecretValue $SecretValue
}
