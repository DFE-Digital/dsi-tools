# Load each of the cmdlet .ps1 files.
Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}
