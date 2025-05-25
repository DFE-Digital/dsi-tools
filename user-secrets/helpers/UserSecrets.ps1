. "$PSScriptRoot/KeyVault.ps1"

function Use-UserSecretsProject {
<#
    .SYNOPSIS
        Use the specified .NET user-secrets project ID.

    .PARAMETER Name
        User friendly name of the project which is used to improve logged output.

    .PARAMETER Id
        The unique user secrets project ID.

        For applicable .NET projects this can be found from the `<UserSecretsId>` property
        of the .csproj file.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-UserSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Id
    )

    Write-Output "`nSet active project to '$Name'..."

    $global:DsiActiveUserSecretsId = $Id
}

function Set-UserSecret {
<#
    .SYNOPSIS
        Sets a user secret for the active .NET project.

    .PARAMETER Key
        Key of user secret.

    .PARAMETER Value
        Value to assign.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-UserSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-UserSecret -Key Some:Setting -Value "123"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$true)]
        [string]$Value
    )

    if (-not $global:DsiActiveUserSecretsId) {
        throw "Cannot set user secret because there is not an active project."
    }

    Write-Output "Setting user secret '$Key'..."

    dotnet user-secrets set $Key $Value --id $global:DsiActiveUserSecretsId > $null
}

function Set-UserSecretFromKeyVault {
<#
    .SYNOPSIS
        Sets a user secret for the active .NET project from a KeyVault entry.

    .PARAMETER Key
        Key of user secret.

    .PARAMETER FromKey
        Key of secret in the active KeyVault.

    .PARAMETER Template
        A template string. Defaults to "<secret>".

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-UserSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-UserSecretFromKeyVault -Key Some:Setting -FromKey abc

    .EXAMPLE
        PS> Use-UserSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-UserSecretFromKeyVault -Key Some:Setting -FromKey abc -Template "https://<secret>/"
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Key,
        [Parameter(Mandatory=$true)]
        [string]$FromKey,
        [string]$Template = "<secret>"
    )

    $secret = Get-KeyVaultSecret -Key $FromKey
    $secret = $Template -replace "<secret>", $secret

    Set-UserSecret $Key $secret
}
