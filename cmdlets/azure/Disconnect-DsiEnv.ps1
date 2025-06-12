function Disconnect-DsiEnv {
    <#
    .SYNOPSIS
        Disconnects from the connected DfE Sign-in environment.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Disconnect-DsiEnv
    #>
    [CmdletBinding()]
    param ()

    try {
        Disconnect-AzAccount
    }
    finally {
        $global:DsiConnectedEnv = $null
        Write-Output "`nDisconnected."
    }
}
