function Export-DsiTestDataToKeyVault {
<#
    .SYNOPSIS
        Submits test data to the KeyVault associated with the connected environment.

    .NOTES
        You must be connected to the environment in order for this command to work.

        This command requires user confirmation.

    .EXAMPLE
        PS> Export-DsiTestDataToKeyVault
        Update test data in KeyVault for 'DEV'? [y/n]: y

        Confirm
        Are you sure you want to perform this action?
        Performing the operation "Set secret" on target "regressionTestDataConfig".
        [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): Y
#>
    param ()

    $ErrorActionPreference = "Stop"

    $env = Test-DsiConnectedEnv

    $reply = Read-Host -Prompt "Update test data in KeyVault for '$($env.Name)'? [y/n]"
    if ($reply.ToLower() -ne "y") {
        Write-Output "Cancelled."
        return
    }

    $testDataPath = Resolve-Path -Path "$PSScriptRoot/../../private/TestData_$($env.Name).json"
    $testData = Get-Content -Path $testDataPath `
        | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Depth 10 # Fix any formatting issues.
    if (-not $testData) {
        throw "No test data found."
    }

    $testData = $testData | ConvertTo-SecureString -AsPlainText

    Set-DsiKeyVaultSecret -Name "regressionTestDataConfig" -SecretValue $testData
}
