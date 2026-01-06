function Import-DsiTestData {
    <#
    .SYNOPSIS
        Import test data that is associated with a hosted environment.

    .DESCRIPTION
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidAssignmentToAutomaticVariable', '',
        Justification = 'A workaround to a bug was needed.'
    )]
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    $env = Test-DsiConnectedEnv
    $projectId = "74491194-d775-4d5f-973f-870ed02a95fc"


    #----- UI Tests ---------------------------------------------------------------------

    Use-DsiSecretsProject -Name "UI Tests" -Id $projectId

    Set-DsiUserSecretsFromKeyVault -Mappings @(
        @{
            Name  = "Platform:HelpBaseAddress"
            Value = "https://{{ standaloneHelpHostName }}"
        }
        @{
            Name  = "Platform:InteractionsBaseAddress"
            Value = "https://{{ standaloneInteractionsHostName }}"
        }
        @{
            Name  = "Platform:ManageBaseAddress"
            Value = "https://{{ standaloneManageHostName }}"
        }
        @{
            Name  = "Platform:ProfileBaseAddress"
            Value = "https://{{ standaloneProfileHostName }}"
        }
        @{
            Name  = "Platform:PublicApiBaseAddress"
            Value = "https://{{ standalonePublicApiHostName }}"
        }
        @{
            Name  = "Platform:ServicesBaseAddress"
            Value = "https://{{ standaloneServicesHostName }}"
        }
    )

    $testDataPath = "$PSScriptRoot/../../private/TestData_$($env.Name).json"
    $testConfigPath = "$PSScriptRoot/../../private/TestData.Config_$($env.Name).json"

    Get-DsiKeyVaultSecret -Name "regressionTestDataConfig" `
    | ConvertFrom-Json -Depth 10 | ConvertTo-Json -Depth 10 ` # Fix any formatting issues.
    | Out-File ( New-Item -Path $testDataPath -Force )

    Set-DsiUserSecret -Name "TestDataPath" -Value $( Resolve-Path -Path $testDataPath )

    # Cache user secrets state so that it can be restored when `Use-DsiTestData` is used.
    $matches = $null # Workaround for bug.
    if ($(dotnet user-secrets list --json --id $projectId) -join "`n" -match "(?s)//BEGIN(.+)//END") {
        $matches[1].Trim() | Out-File $testConfigPath
    }
}
