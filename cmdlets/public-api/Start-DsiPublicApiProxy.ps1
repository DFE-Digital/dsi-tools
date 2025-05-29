function Start-DsiPublicApiProxy {
<#
    .SYNOPSIS
        Start the Public API proxy for developers.

    .NOTES
        This is useful for developers working with the Public API where some endpoints
        are hosted whilst some endpoints are being ran locally.

        The proxy runs on http://localhost:5086

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Start-DsiPublicApiProxy
#>
    [CmdletBinding()]
    param ()

    Write-Output "Starting Public API proxy..."
    node "$PSScriptRoot/PublicApiProxy.js"
}
