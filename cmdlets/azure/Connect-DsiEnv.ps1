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

    .PARAMETER TenantId
        ID of the tenant.

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> xyz...
        PS> Disconnect-DsiEnv

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV -TenantId 00000000-0000-0000-0000-000000000000
        PS> xyz...
        PS> Disconnect-DsiEnv
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$Name,
        [String]$TenantId = $null
    )

    $global:DsiConnectedEnv = $null

    try {
        $env = Get-DsiEnvMeta -Name $Name

        $TenantId = $TenantId -like "" ? $global:DsiDefaultTenantId : $TenantId
        if ($TenantId) {
            Write-Output "Connecting to $Name for tenant '$TenantId'..."
            Connect-AzAccount -Subscription $env.Subscription -TenantId $TenantId
        }
        else {
            Write-Output "Connecting to $Name...."
            Connect-AzAccount -Subscription $env.Subscription
        }
    }
    finally {
        $global:DsiConnectedEnv = $env
        Write-Output "`nConnected to $Name. You can disconnect with `Disconnect-DsiEnv`."
    }
}
