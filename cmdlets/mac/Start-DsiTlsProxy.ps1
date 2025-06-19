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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet starts a proxy server locally.'
    )]
    param ()

    Write-Output "Starting TLS proxy..."
    node "$PSScriptRoot/TlsProxy.js"
}
