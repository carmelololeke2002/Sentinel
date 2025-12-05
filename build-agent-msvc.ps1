<#
build-agent-msvc.ps1

Configure l'environnement MSVC (vcvars) et lance `cargo build --release` pour l'agent.

Exécution :
  Ouvre PowerShell en Administrateur (ou normal si vcvars ajoute les variables), puis :
  .\build-agent-msvc.ps1

Le script tente :
- Trouver l'installation Visual Studio (via vswhere si présent)
- Appeler vcvars64.bat pour configurer l'environnement
- Lancer cargo build --release
#>

function Abort($msg) { Write-Error $msg; exit 1 }

# Locate vswhere
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (-not (Test-Path $vswhere)) {
  Write-Warning "vswhere.exe introuvable. On va tenter les chemins par défaut.";
  $possible = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools'
  )
  $installPath = $possible | Where-Object { Test-Path $_ } | Select-Object -First 1
} else {
  $installPath = & $vswhere -latest -products * -property installationPath
}

if (-not $installPath) { Abort "Impossible de localiser Visual Studio Build Tools. Vérifie l'installation." }

$vcvars = Join-Path $installPath 'VC\Auxiliary\Build\vcvars64.bat'
if (-not (Test-Path $vcvars)) { Abort "vcvars64.bat introuvable à $vcvars" }

Write-Output "Sourcing vcvars from: $vcvars"

# Prepare agent directory path
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$agentDir = Join-Path $repoRoot 'agent'

# Build command to run inside cmd.exe: call vcvars then change dir and build
$cmd = "call \"$vcvars\" && cd /d \"$agentDir\" && cargo build --release"

Write-Output "Running: cmd.exe /c $cmd"
cmd.exe /c $cmd

if ($LASTEXITCODE -ne 0) { Abort "La compilation a échoué. Regarde la sortie précédente pour les erreurs." }

Write-Output "Build réussi. Binaire disponible dans agent\target\release"
