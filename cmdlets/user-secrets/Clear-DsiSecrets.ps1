function Clear-DsiSecrets {
<#
    .SYNOPSIS
        Clear all user secrets for all projects.

    .NOTES
        This command clears ALL user secrets for all projects.

        This command requires user confirmation.

    .EXAMPLE
        PS> Clear-DsiSecrets
        Clear user secrets for DfE Sign-in projects? [y/n]: y
#>
    [CmdletBinding()]
    param ()

    $ErrorActionPreference = "Stop"

    $reply = Read-Host -Prompt "Clear user secrets for DfE Sign-in projects? [y/n]"
    if ($reply.ToLower() -ne "y") {
        Write-Output "Cancelled."
        return
    }

    $projects = @(
        @{
            Name = "Public API"
            Id = "9cf57240-a4e9-44b7-8c09-922da90f69eb"
        }
        @{
            Name = "Select Organisation"
            Id = "9bc1d9ef-36ce-492e-876f-6d80fe79896c"
        }
        @{
            Name = "UI Tests"
            Id = "74491194-d775-4d5f-973f-870ed02a95fc"
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
