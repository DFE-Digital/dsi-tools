function Use-DsiSecretsProject {
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
        PS> Use-DsiSecretsProject -Name "Example Project" -Id "97af337f-9c41-4db1-aaac-9c8537229ee9"
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name,

        [Parameter(Mandatory=$true)]
        [String]$Id
    )

    $ErrorActionPreference = "Stop"

    Write-Output "`nSet active project to '$Name'..."

    $global:DsiActiveUserSecretsId = $Id
}
