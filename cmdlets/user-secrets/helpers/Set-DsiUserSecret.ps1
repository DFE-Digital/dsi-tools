function Set-DsiUserSecret {
<#
    .SYNOPSIS
        Sets a user secret for the active .NET project.

    .NOTES
        Throws error if no user secrets project is active.

    .PARAMETER Name
        Name of the user secret.

    .PARAMETER Value
        Value to assign.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Use-DsiSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
        PS> Set-DsiUserSecret -Name Some:Setting -Value "123"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [String]$Value
    )

    $ErrorActionPreference = "Stop"

    if (-not $global:DsiActiveUserSecretsId) {
        throw "Cannot set user secret because there is not an active project."
    }

    Write-Output "Setting user secret '$Name'..."

    dotnet user-secrets set $Name $Value --id $global:DsiActiveUserSecretsId > $null
}
