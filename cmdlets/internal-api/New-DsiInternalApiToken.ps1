function New-DsiInternalApiToken {
    <#
    .SYNOPSIS
        Create an authorization token to use when using the DfE Sign-in Internal API.

    .DESCRIPTION
        You must be connected to the environment in order for this command to work.

    .OUTPUTS
        The authorization token.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> New-DsiInternalApiToken
        PS> Disconnect-DsiEnv
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet creates a token but does not change system state.'
    )]
    param ()

    $ErrorActionPreference = "Stop"

    Test-DsiConnectedEnv > $null

    $params = @{
        tenant = Get-DsiKeyVaultSecret -Name "platformGlobalTenantDomain"
        hostUrl = Get-DsiKeyVaultSecret -Name "tenantUrl"
        resource = Get-DsiKeyVaultSecret -Name "aadshdappid"
        clientId = Get-DsiKeyVaultSecret -Name "aadshdclientid"
        clientSecret = Get-DsiKeyVaultSecret -Name "aadshdclientsecret"
    }

    $env:PARAMS = $params | ConvertTo-Json -Compress

    node "$PSScriptRoot/CreateToken.js"
}
