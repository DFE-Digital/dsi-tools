function Export-DsiTestDataToKeyVault {
    <#
    .SYNOPSIS
        Submits test data to the KeyVault associated with the connected environment.

    .DESCRIPTION
        You must be connected to the environment in order for this command to work.

        This command requires user confirmation.

    .PARAMETER Force
        Force invocation without prompting for confirmation.

    .EXAMPLE
        PS> Export-DsiTestDataToKeyVault
        Update test data in KeyVault for 'DEV'? [y/n]: y

        Confirm
        Are you sure you want to perform this action?
        Performing the operation 'Export test data to KeyVault' for the 'DEV' environment.
        [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Transferring test data to KeyVault.'
    )]
    param (
        [Switch]$Force
    )

    $ErrorActionPreference = "Stop"

    Test-DsiConnectedEnv > $null

    if (-not ($Force -or $PSCmdlet.ShouldContinue(@"
Are you sure you want to perform this action?
Performing the operation 'Export test data to KeyVault' for the '$($global:DsiConnectedEnv.Name)' environment.
"@, 'Confirm'))) {
        Write-Output "Cancelled."
        return
    }

    $testDataPath = Resolve-Path -Path "$PSScriptRoot/../../private/TestData_$($env.Name).json"
    $testData = Get-Content -Path $testDataPath | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Depth 10 # Fix any formatting issues.
    if (-not $testData) {
        throw "No test data found."
    }

    $testData = $testData | ConvertTo-SecureString -AsPlainText

    Set-DsiKeyVaultSecret -Force -Name "regressionTestDataConfig" -SecretValue $testData
}
