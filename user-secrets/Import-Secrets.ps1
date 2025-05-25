<#
.SYNOPSIS
    Import secrets to connect to a hosted development environment.

.PARAMETER EnvId
    The unique ID of the development environment.

.OUTPUTS
    None.

.EXAMPLE
    PS> Import-Secrets -EnvId d01
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$EnvId
)

$ErrorActionPreference = "Stop"

Import-Module -Name "$PSScriptRoot/helpers/Module"

try {
    Connect-KeyVault -EnvId $EnvId

    Use-UserSecretsProject -Name "Public API" -Id "9cf57240-a4e9-44b7-8c09-922da90f69eb"
    Set-UserSecret -Key "BearerToken:ValidAudience" -Value "signin.education.gov.uk"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Organisations"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Directories"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Applications"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Access"

    Use-UserSecretsProject -Name "Select Organisation" -Id "9bc1d9ef-36ce-492e-876f-6d80fe79896c"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Organisations"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Directories"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Applications"
    Set-NodeApiUserSecretsFromKeyVault -ApiName "Access"
}
finally {
    Disconnect-KeyVault
}
