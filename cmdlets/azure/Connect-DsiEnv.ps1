function Connect-DsiEnv {
<#
    .SYNOPSIS
        Connects to a DfE Sign-in environment in Azure.

    .PARAMETER Name
        The name of the environment:
            - TRAN
            - DEV
            - TEST
            - PREPROD
            - PROD

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> xyz...
        PS> Disconnect-DsiEnv
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $global:DsiConnectedEnv = $null

    try {
        Write-Output "Connecting to $Name..."

        $env = Get-DsiEnvMetadata -Name $Name

        Connect-AzAccount -Subscription $env.Subscription
    }
    finally {
        $global:DsiConnectedEnv = $env
        Write-Output "`nConnected to $Name. You can disconnect with `Disconnect-DsiEnv`."
    }
}
