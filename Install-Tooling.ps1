<#
.SYNOPSIS
    Install or update the required tooling.

.PARAMETER DefaultTenantId
    ID of the default tenant to use with running `Connect-DsiEnv`.

.OUTPUTS
    None.

.EXAMPLE
    PS> ./Install-Tooling.ps1
#>
[CmdletBinding()]
param (
    [String]$DefaultTenantId = $null
)


# Ensure that the Az module is installed and up to date.
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Output "Az module not found. Installing..."
    Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser
    Write-Output "Az module installed."
}
else {
    Write-Output "Az module is already installed. Updating..."
    Update-Module -Name Az -Force -Scope CurrentUser
    Write-Output "Az module has been updated."
}


# Import cmdlet module when a PowerShell session is started.
if ($IsMacOS) {
    $profilePath = "~/.config/powershell/Microsoft.PowerShell_profile.ps1"
}
else {
    $profilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
}
$profileContent = ""
if (Test-Path -Path $profilePath) {
    $profileContent = Get-Content -Path $profilePath | Out-String
}

$cmdletInit = @"
### BEGIN DSI-TOOLS ###
Import-Module -Name $PSScriptRoot/cmdlets/Module
$($DefaultTenantId ? "`$global:DsiDefaultTenantId = `"$DefaultTenantId`"" : "")
### END DSI-TOOLS ###
"@

$pattern = "(?s)### BEGIN DSI-TOOLS ###.+### END DSI-TOOLS ###"
if ($profileContent -match $pattern) {
    $profileContent = $profileContent -replace $pattern, $cmdletInit
}
else {
    $profileContent = $("{0}`n`n{1}" -f $profileContent, $cmdletInit)
}

New-Item -ItemType File -Path $profilePath -Force
Set-Content -Path $profilePath -Value $profileContent.Trim()


# Ensure that module is available immediately after the install script is ran.
Import-Module -Name "$PSScriptRoot/cmdlets/Module" -Force


Write-Output "Tooling was installed successfully."
