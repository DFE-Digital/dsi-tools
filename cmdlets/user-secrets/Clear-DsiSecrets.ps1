function Clear-DsiSecrets {
<#
    .SYNOPSIS
        Clear all user secrets for all projects.

    .NOTES
        This command clears ALL user secrets for all projects.

    .PARAMETER Confirm
        Specify any of the following values to confirm (not case sensitive):
            - 1
            - "y"
            - "yes"
            - "true"

    .EXAMPLE
        PS> Clear-DsiSecrets
        Confirm: y
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Confirm
    )

    $ErrorActionPreference = "Stop"

    if ($Confirm.ToLower() -notmatch "^(1|true|yes|y)$") {
        Write-Output "Cancelled."
        return;
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

    foreach ($project in $projects) {
        Write-Output "Clearing secrets for '$($project.Name)'..."
        dotnet user-secrets clear --id "$($project.Id)"
    }

    Write-Output "Completed."
}
