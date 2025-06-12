function Clear-DsiSecrets {
    <#
    .SYNOPSIS
        Clear all user secrets for all projects.

    .DESCRIPTION
        This command clears ALL user secrets for all projects.

        This command requires user confirmation.

    .PARAMETER Force
        Force invocation without prompting for confirmation.

    .EXAMPLE
        PS> Clear-DsiSecrets

        Confirm
        Are you sure you want to perform this action?
        Performing the operation 'Clear local user secrets'.
        [Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Switch]$Force
    )

    $ErrorActionPreference = "Stop"

    if (-not ($Force -or $PSCmdlet.ShouldContinue(@"
Are you sure you want to perform this action?
Performing the operation 'Clear local user secrets'.
"@, 'Confirm'))) {
        Write-Output "Cancelled."
        return
    }

    $projects = @(
        @{
            Name = "Public API"
            Id   = "9cf57240-a4e9-44b7-8c09-922da90f69eb"
        }
        @{
            Name = "Select Organisation"
            Id   = "9bc1d9ef-36ce-492e-876f-6d80fe79896c"
        }
        @{
            Name = "UI Tests"
            Id   = "74491194-d775-4d5f-973f-870ed02a95fc"
        }
    )

    Write-Output "Clearing secrets..."
    foreach ($project in $projects) {
        Write-Output "   for '$($project.Name)'..."
        dotnet user-secrets clear --id "$($project.Id)"
    }

    Write-Output "Clearing test data..."
    Remove-Item -Path "$PSScriptRoot/../../private/TestData*.json" -Confirm

    Write-Output "Completed."
}
