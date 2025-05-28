function Test-DsiConnectedEnv {
<#
    .SYNOPSIS
        Tests that there is an active DfE Sign-in environment.

    .NOTES
        Throws an error if there is no connection.

    .OUTPUTS
        None.
#>
    [CmdletBinding()]
    param ()

    if (-not $global:DsiConnectedEnv) {
        throw "Not connected to a DfE Sign-in environment. Use `Connect-DsiEnv` to connect."
    }
}
