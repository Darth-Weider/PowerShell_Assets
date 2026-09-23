# Visual Studio Code Settings and PowerShell Profile

A personal Windows dev environment: a PowerShell profile, VS Code settings and
snippets, and a Windows Terminal configuration, plus a one-step setup script
that installs the required tooling with [winget](https://learn.microsoft.com/windows/package-manager/).

## Quick start

`winget` ships with the **App Installer** package on Windows 10/11. If you don't
have it, install *App Installer* from the Microsoft Store first.

From an elevated PowerShell prompt:

```powershell
./Setup/Install-Packages.ps1
```

This installs the CLI tooling, the PowerShell modules the profile imports, and
the VS Code extensions listed below. It is safe to re-run — already-installed
items are skipped. Useful switches: `-SkipPackages`, `-SkipModules`,
`-SkipVSCodeExtensions`.

### What gets installed

CLI tooling via winget:

```powershell
winget install --id Git.Git -e
winget install --id Microsoft.PowerShell -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Microsoft.WindowsTerminal -e
winget install --id JanDeDobbeleer.OhMyPosh -e
winget install --id junegunn.fzf -e
winget install --id AgileBits.1Password.CLI -e
winget install --id Amazon.AWSCLI -e
winget install --id Hashicorp.Terraform -e
winget install --id Kubernetes.kubectl -e
winget install --id Helm.Helm -e
winget install --id Docker.DockerDesktop -e
```

VS Code extensions:

```powershell
code --install-extension 4ops.terraform
code --install-extension docsmsft.docs-yaml
code --install-extension eamodio.gitlens
code --install-extension monokai.theme-monokai-pro-vscode
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.powershell
code --install-extension redhat.vscode-yaml
```

> The profile also uses the **FiraCode Nerd Font**. Nerd Fonts aren't in the
> winget catalog — grab it from <https://www.nerdfonts.com/>.

## PowerShell profile

Copy `Microsoft.PowerShell_profile.ps1` into the appropriate location:

- Windows PowerShell (v5.1): `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- PowerShell Core (7+): `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

Some functions (for example `PRTG_Connection`) read secrets from 1Password via
the `op` CLI and reference placeholder vault names and hostnames — update those
to your own before use.

## VS Code settings

Copy `VS_Code_Settings/settings.json` into:

```
$HOME\AppData\Roaming\Code\User\settings.json
```

Copy `VS_Code_Settings/snippets/powershell.json` into:

```
$HOME\AppData\Roaming\Code\User\snippets\powershell.json
```

## Windows Terminal settings

Copy `Windows_Terminal_Settings/settings.json` into the Windows Terminal
settings file (open Terminal → Settings → *Open JSON file*).
