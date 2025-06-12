function Start-DsiTlsProxy {
    <#
    .SYNOPSIS
        Start the TLS proxy for developers working on Mac.

    .DESCRIPTION
        The proxy runs on http://localhost:8080

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Start-DsiTlsProxy
    #>
    [CmdletBinding()]
    param ()

    Write-Output "Starting TLS proxy..."
    node "$PSScriptRoot/TlsProxy.js"
}
