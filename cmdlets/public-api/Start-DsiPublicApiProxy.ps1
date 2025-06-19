function Start-DsiPublicApiProxy {
    <#
    .SYNOPSIS
        Start the Public API proxy for developers.

    .DESCRIPTION
        This is useful for developers working with the Public API where some endpoints
        are hosted whilst some endpoints are being ran locally.

        The proxy runs on http://localhost:5086

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Start-DsiPublicApiProxy
    #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'This cmdlet does not alter system state.'
    )]
    param ()

    Write-Output "Starting Public API proxy..."
    node "$PSScriptRoot/PublicApiProxy.js"
}
