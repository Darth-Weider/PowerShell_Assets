$MaximumHistoryCount = 10000; 
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8' #Reference:https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file?view=powershell-7.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8 #Reference: https://stackoverflow.com/questions/35573209/how-to-configure-the-encoding-for-powershell-console
$Check_PS_Version = (($PSVersionTable).PSVersion).Major

$Env:OP_SERVICE_ACCOUNT_TOKEN_GLOBAL = Get-Content .\.config\op\service_account_token -Raw

$Env:OP_SERVICE_ACCOUNT_TOKEN = $Env:OP_SERVICE_ACCOUNT_TOKEN_GLOBAL
if ($Check_PS_Version -eq 5) {
  
  $Module_List_v5 = @('posh-git',
    'Terminal-Icons',
    'AWSCompleter',
    'PSFzf',
    'PSCompletions',
    'DockerCompletion',
    'Microsoft.PowerShell.SecretManagement')

  foreach ($Module in $Module_List_v5) {
	
    Import-Module -Name $Module 
	
  }
  function list_aws_profile {
    Get-Content $HOME\.aws\credentials | Select-String -Pattern '^\['
  }
}

else {

  $Module_List_Core = @('posh-git',
    'PSReadLine',
    'Terminal-Icons',
    'AWSCompleter',
    'PSFzf',
    'PSCompletions',
    'DockerCompletion',
    'Microsoft.PowerShell.SecretManagement',
    'AWSPowerShell.NetCore') #For PowerShell Core only 

  foreach ($Module in $Module_List_Core) {

    Import-Module -Name $Module

  }
  #NoEmphasis is only supported in PowerShell core
  function list_aws_profile {
    Get-Content $HOME\.aws\credentials | Select-String -Pattern '^\[' -NoEmphasis
  }
}


Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource History 

#Reference https://docs.chocolatey.org/en-us/troubleshooting

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

oh-my-posh init pwsh --config ~\terminal_prompt\aliens_v2.omp_aws.json | Invoke-Expression

#usage: set_aws_profile -Profile_Name my-sandbox-profile
function set_aws_profile {
  Param(
    [parameter(Mandatory = $true)]
    [string]
    $Profile_Name)
   
  setx AWS_PROFILE $Profile_Name
  setx AWS_DEFAULT_REGION us-east-1
  setx AWS_SDK_LOAD_CONFIG 1
  setx AWS_SHARED_CREDENTIALS_FILE $HOME\.aws\credentials
  Update-SessionEnvironment


}

# Reads credentials from 1Password via the `op` CLI. Replace the vault/item
# references and server hostname with your own before use.
function PRTG_Connection {

[string]$user = op read "op://YourVault/PRTG_Service_Account/username"
[string]$pass_hash = op read "op://YourVault/PRTG_Service_Account/PassHash"

Connect-PrtgServer -Server prtg.example.com (New-Credential $user $pass_hash) -PassHash

}
function drop_aws_profile {

  setx AWS_PROFILE default 
  Update-SessionEnvironment 
  
  
}

#https://github.com/hashicorp/terraform/issues/29125
# command completion for terraform cli
if(Get-Command terraform.exe -ErrorAction SilentlyContinue) {
  Register-ArgumentCompleter -Native -CommandName terraform -ScriptBlock {
      param($commandName, $wordToComplete, $cursorPosition)
          $env:COMP_LINE=$wordToComplete
          $env:COMP_POINT=$cursorPosition
          terraform.exe | ForEach-Object {
              [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
          }
          Remove-Item Env:\COMP_LINE
          Remove-Item Env:\COMP_POINT
  }
}

function Public_Ip {
  (Invoke-WebRequest -uri "https://api.ipify.org/").Content
  
}

#https://sathyasays.com/2023/04/11/powershell-fzf-psfzf/
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

function update_aws_cred {
  $Current_Location = (Get-Location).Path
  Set-Location -Path ~\.aws
  git pull
  Set-Location -Path $Current_Location
}


function wsl_cisco {
  wsl --shutdown
  Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Set-NetIPInterface -InterfaceMetric 6000
  wsl
}

op completion powershell | Out-String | Invoke-Expression 


function assume {

  & 'C:\Program Files\AssumeRole\assume.ps1'

}
if(Get-Command kubectl -ErrorAction SilentlyContinue) {
  kubectl completion powershell | Out-String | Invoke-Expression
}

helm completion powershell | Out-String | Invoke-Expression

