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

$azModuleName = "Az"
$installedAzModule = Get-InstalledModule -Name $azModuleName -ErrorAction SilentlyContinue

# Ensure that the Az module is installed and up to date.
if (-not $installedAzModule) {
    Write-Output "$azModuleName module not found. Installing..."
    Install-Module -Name $azModuleName -Repository PSGallery -Force -Scope CurrentUser
    Write-Output "$azModuleName module installed."
}
else {
    $latestAzModule = Find-Module -Name $azModuleName -Repository PSGallery
    if ($latestAzModule.Version -gt $installedAzModule.Version) {
        Write-Output "$azModuleName module is already installed. Updating..."
        Update-Module -Name $azModuleName -Force -Scope CurrentUser
        Write-Output "$azModuleName module has been updated."
    }
    else {
        Write-Output "$azModuleName module is already up to date ($($installedAzModule.Version))."
    }
}


# Install or update npm dependencies
npm install


# Import cmdlet module when a PowerShell session is started.
$profileContent = ""
if (Test-Path -Path $PROFILE) {
    $profileContent = Get-Content -Path $PROFILE | Out-String
}

$cmdletInit = @"
### BEGIN DSI-TOOLS ###
Import-Module -Name $PSScriptRoot/cmdlets/DsiTools
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

New-Item -ItemType File -Path $PROFILE -Force
Set-Content -Path $PROFILE -Value $profileContent.Trim()


# Ensure that module is available immediately after the install script is ran.
Import-Module -Name "$PSScriptRoot/cmdlets/DsiTools" -Force


Write-Output "Tooling was installed successfully."
