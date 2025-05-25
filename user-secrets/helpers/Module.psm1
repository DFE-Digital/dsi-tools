$ErrorActionPreference = "Stop"

# Load all helper cmdlets.
Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
