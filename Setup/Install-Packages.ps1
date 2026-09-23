<#
.SYNOPSIS
    Bootstraps the development environment used by this PowerShell profile.
.DESCRIPTION
    Installs command-line tooling with winget, the PowerShell modules imported
    by the profile, and the VS Code extensions listed in the README. Safe to
    re-run: winget and Install-Module both skip anything already present.
.EXAMPLE
    ./Install-Packages.ps1
    Installs everything (packages, modules, and VS Code extensions).
.EXAMPLE
    ./Install-Packages.ps1 -SkipVSCodeExtensions
    Installs packages and modules but leaves VS Code extensions alone.
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipModules,
    [switch]$SkipVSCodeExtensions
)

$ErrorActionPreference = 'Stop'

# winget package IDs for the CLI tooling this profile expects on PATH.
$WingetPackages = @(
    'Git.Git',
    'Microsoft.PowerShell',
    'Microsoft.VisualStudioCode',
    'Microsoft.WindowsTerminal',
    'JanDeDobbeleer.OhMyPosh',
    'junegunn.fzf',
    'AgileBits.1Password.CLI',
    'Amazon.AWSCLI',
    'Hashicorp.Terraform',
    'Kubernetes.kubectl',
    'Helm.Helm',
    'Docker.DockerDesktop'
)

# PowerShell modules imported by Microsoft.PowerShell_profile.ps1.
$Modules = @(
    'posh-git',
    'Terminal-Icons',
    'PSReadLine',
    'PSFzf',
    'PSCompletions',
    'DockerCompletion',
    'AWS.Tools.Installer',
    'AWSPowerShell.NetCore',
    'Microsoft.PowerShell.SecretManagement'
)

# VS Code extensions (see README prerequisites).
$VSCodeExtensions = @(
    '4ops.terraform',
    'docsmsft.docs-yaml',
    'eamodio.gitlens',
    'monokai.theme-monokai-pro-vscode',
    'ms-vscode-remote.remote-wsl',
    'ms-vscode.powershell',
    'redhat.vscode-yaml'
)

if (-not $SkipPackages) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget was not found. Install "App Installer" from the Microsoft Store, then re-run.'
    }
    foreach ($id in $WingetPackages) {
        Write-Host "Installing $id ..." -ForegroundColor Cyan
        winget install --id $id --exact --silent `
            --accept-package-agreements --accept-source-agreements
    }
}

if (-not $SkipModules) {
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    foreach ($module in $Modules) {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Host "Module $module already installed." -ForegroundColor DarkGray
            continue
        }
        Write-Host "Installing module $module ..." -ForegroundColor Cyan
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
}

if (-not $SkipVSCodeExtensions) {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        foreach ($ext in $VSCodeExtensions) {
            Write-Host "Installing VS Code extension $ext ..." -ForegroundColor Cyan
            code --install-extension $ext
        }
    }
    else {
        Write-Warning 'The `code` CLI was not found on PATH. Skipping VS Code extensions.'
    }
}

Write-Host 'Setup complete.' -ForegroundColor Green
