function Get-DsiTestDataPath {
<#
    .SYNOPSIS
        Gets the active test data path.

    .NOTES
        This is the value of the "TestDataPath" user secret for "dsi-ui-tests".

    .OUTPUTS
        The active test data path.

    .EXAMPLE
        PS> Get-DsiTestDataPath
#>
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    $userSecrets = dotnet user-secrets list --json --id "74491194-d775-4d5f-973f-870ed02a95fc" `
        | ConvertFrom-Json

    if ($userSecrets.TestDataPath) {
        return $userSecrets.TestDataPath
    }
    else {
        return "None."
    }
}
