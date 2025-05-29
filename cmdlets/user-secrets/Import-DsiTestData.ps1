function Import-DsiTestData {
<#
    .SYNOPSIS
        Import test data that is associated with a hosted environment.

    .NOTES
        You must be connected to the environment in order for this command to work.

        Test data is imported as a JSON file which can be manually edited as needed for
        development or testing purposes. The 'dsi-ui-tests' project reads the JSON file
        directly as specified by the user secret "TestDataPath".

    .OUTPUTS
        None.

    .EXAMPLE
        PS> Connect-DsiEnv -Name DEV
        PS> Import-DsiTestData
        PS> Disconnect-DsiEnv
#>
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    $env = Test-DsiConnectedEnv


    #----- UI Tests ---------------------------------------------------------------------

    Use-DsiSecretsProject `
        -Name "UI Tests" `
        -Id "74491194-d775-4d5f-973f-870ed02a95fc"

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name = "Platform:ServicesBaseAddress"
            Value = "https://{{ standaloneServicesHostName }}"
        }
        @{
            Name = "Platform:ProfileBaseAddress"
            Value = "https://{{ standaloneProfileHostName }}"
        }
        @{
            Name = "Platform:ManageBaseAddress"
            Value = "https://{{ standaloneManageHostName }}"
        }
        @{
            Name = "Platform:InteractionsBaseAddress"
            Value = "https://{{ standaloneInteractionsHostName }}"
        }
        @{
            Name = "Platform:PublicApiBaseAddress"
            Value = "https://{{ standalonePublicApiHostName }}"
        }
    )

    $testDataPath = "$PSScriptRoot/../../private/TestData_$($env.Name).json"

    Get-DsiKeyVaultSecret -Name "regressionTestDataConfig" `
        | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Depth 10 ` # Fix any formatting issues.
        | Out-File ( New-Item -Path $testDataPath -Force )

    Set-DsiUserSecret -Name "TestDataPath" -Value $( Resolve-Path -Path $testDataPath )
}
