function Use-DsiTestData {
<#
    .SYNOPSIS
        Use test data that has already been imported for a hosted environment.

    .NOTES
        You must have already imported the test data in order for this command to work.

    .PARAMETER Name
        The name of the environment:
            - TRAN
            - DEV
            - TEST
            - PREPROD
            - PROD

    .OUTPUTS
        The active test data path.

    .EXAMPLE
        PS> Use-DsiTestData -Name DEV
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    $ErrorActionPreference = "Stop"

    try {
        $testDataPath = Resolve-Path "$PSScriptRoot/../../private/TestData_$Name.json"
    }
    catch {
        Write-Output "Test data does not exist for '$Name'. Use `Import-DsiTestData` to import the test data."
        return $null
    }

    Set-DsiUserSecret -Name "TestDataPath" -Value $( Resolve-Path -Path $testDataPath )

    return $testDataPath
}
