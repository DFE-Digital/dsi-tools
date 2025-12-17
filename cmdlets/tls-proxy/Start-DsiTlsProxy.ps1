function Start-DsiTlsProxy {
    <#
    .SYNOPSIS
        Start the TLS proxy for developers when running components locally on a
        development machine.

    .DESCRIPTION
        This is required since the required version of TLS is not supported by
        .NET Core 8.0 when running on a Mac development machine. Some developers
        have also found this useful when running on Windows development machines.

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
