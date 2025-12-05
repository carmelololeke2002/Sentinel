<#
install-vs-buildtools.ps1

Télécharge et installe silencieusement Visual Studio Build Tools avec le workload
"Desktop development with C++" et le Windows SDK recommandé.

Exécution (PowerShell en Administrateur) :
  .\install-vs-buildtools.ps1

Remarques :
- Le téléchargement est volumineux (plusieurs Go). Le script peut prendre du temps.
- L'installation nécessite des droits administrateurs.
#>

function Abort($msg) { Write-Error $msg; exit 1 }

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Abort "Ce script doit être exécuté en tant qu'administrateur. Ouvre PowerShell en mode admin et relance.";
}

$vsUrl = 'https://aka.ms/vs/17/release/vs_BuildTools.exe'
$tmp = [System.IO.Path]::GetTempPath()
$installer = Join-Path $tmp 'vs_BuildTools.exe'

Write-Output "Téléchargement de Visual Studio Build Tools depuis $vsUrl -> $installer"
if (Test-Path $installer) { Remove-Item $installer -Force }
Invoke-WebRequest -Uri $vsUrl -OutFile $installer -UseBasicParsing

Write-Output "Lancement de l'installateur (mode silencieux). Ceci peut prendre longtemps..."

# Workloads/components : Desktop C++ workload + Windows 10/11 SDK (utiliser component id générique)
$args = @(
  '--add', 'Microsoft.VisualStudio.Workload.VCTools',
  '--add', 'Microsoft.VisualStudio.Component.Windows10SDK.19041',
  '--includeRecommended',
  '--quiet',
  '--wait',
  '--norestart'
)

& $installer $args

if ($LASTEXITCODE -ne 0) {
  Write-Warning "L'installateur a renvoyé un code non nul : $LASTEXITCODE. Vérifie manuellement.";
} else {
  Write-Output "Installation terminée. Redémarre la machine si nécessaire."
}
