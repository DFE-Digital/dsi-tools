function Set-DsiUserSecretsFromKeyVault {
    <#
    .SYNOPSIS
        Sets user secrets for the active .NET project with KeyVault mappings.

    .DESCRIPTION
        Throws error if no user secrets project is active.

    .PARAMETER Mappings
        An array of mappings where each mapping has the following properties:
            - Name
            - Value

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> Use-DsiSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-DsiUserSecretsFromKeyVault -Mappings @(
            @{
                Name = "SomeUserSecret:Key1"
                Value = "{{ keyvaultkey1 }}"
            }
            @{
                Name = "SomeUserSecret:Key2"
                Value = "https://{{ keyvaultkey2 }}"
            }
        )
        PS> Disconnect-DsiEnv
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet only sets local user secrets.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject[]]$Mappings
    )

    $ErrorActionPreference = "Stop"

    if (-not $global:DsiActiveUserSecretsId) {
        throw "Cannot set user secret because there is not an active project."
    }

    Test-DsiConnectedEnv > $null

    foreach ($mapping in $Mappings) {
        $value = $mapping.Value -replace "{{([^}]+?)}}", {
            $secretName = $_.Groups[1].Value.Trim()
            return Get-DsiKeyVaultSecret -Name $secretName
        }
        if ($mapping.NonHttp) {
            $value = $value  -replace 'https:', 'http:'
        }
        Set-DsiUserSecret -Name $mapping.Name -Value $value
    }
}
