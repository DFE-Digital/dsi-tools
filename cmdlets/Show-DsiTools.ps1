function Show-DsiTools {
    Write-Host "=== DSI Tools ===" -ForegroundColor Cyan

    function Get-CommandParametersString {
        param ($CommandName)

        $command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue
        if (-not $command) { return $null }

        $customParameters = $command.Parameters.GetEnumerator() |
        Where-Object {
            -not [System.Management.Automation.Cmdlet]::CommonParameters.Contains($_.Key) -and
            -not [System.Management.Automation.Cmdlet]::OptionalCommonParameters.Contains($_.Key)
        }

        ($customParameters | ForEach-Object {
            $isMandatory = $_.Value.Attributes.Mandatory -contains $true
            $suffix = if ($isMandatory) { '*' } else { '' }

            "$($_.Key):$($_.Value.ParameterType.Name)$suffix"
        }) -join ', '
    }

    $subFolders = Get-ChildItem -Path ./cmdlets -Directory
    $commands = Get-Command -Module DsiTools
    $subFolderMap = @{}

    foreach ($folder in $subFolders) {
        $files = Get-ChildItem $folder.FullName -Filter *.ps1 -File -Recurse

        $matchedCommands = foreach ($file in $files) {
            $commands | Where-Object { $file.Name -like "$($_.Name)*" } | Select-Object -First 1 | ForEach-Object { $_.Name }
        }

        if ($matchedCommands.Count -gt 0) {
            $subFolderMap[$folder.Name] = @($matchedCommands | Sort-Object -Unique)
        }
    }

    foreach ($sub in $subFolderMap.Keys) {
        Write-Host "$sub" -ForegroundColor Cyan

        foreach ($cmd in $subFolderMap[$sub]) {
            Write-Host "   $($cmd)" -ForegroundColor Green
            $help = Get-Help $cmd -Full -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            Write-Host "   $($help.Synopsis.Trim())" -ForegroundColor Gray
            $cmdParameters = $(Get-CommandParametersString($cmd))
            if ($cmdParameters) {
                Write-Host "   Parameters: $cmdParameters"  -ForegroundColor Gray
            }
            Write-Host ""
        }
    }
}