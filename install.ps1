<#
PowerShell installer script for the Antivirus project (Windows).

What this script does:
- Requires Administrator privileges.
- Installs API dependencies (npm ci in api/).
- Copies UI production files from ui/dist into api/public (or builds the UI if build not present).
- Optionally places an agent binary if present in agent/target/release.
- Registers the API as a Windows service using sc.exe (running node server.js).

Usage (run in an elevated PowerShell):
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
PS> .\install.ps1 -InstallPath "C:\Program Files\Antivirus" -NodePath "C:\Program Files\nodejs\node.exe"

Notes:
- This script assumes Node is installed and `node` path is provided or on PATH.
- For the agent native binary, prefer using CI-built artifacts or build locally (requires Visual C++ Build Tools on Windows).
#>
param(
  [string]$InstallPath = "C:\Program Files\Antivirus",
  [string]$NodePath = "",
  [switch]$SkipService
)

function Abort($msg) {
  Write-Error $msg
  exit 1
}

# Check admin
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Abort "Ce script doit être exécuté en tant qu'administrateur. Ouvre PowerShell en mode administrateur et relance.";
}

# Determine node path
if (-not $NodePath -or $NodePath -eq "") {
  $node = Get-Command node -ErrorAction SilentlyContinue
  if ($node) { $NodePath = $node.Source } else { Abort "node n'a pas été trouvé dans le PATH. Spécifie -NodePath ou installe Node.js." }
}

Write-Output "InstallPath: $InstallPath"
Write-Output "NodePath: $NodePath"

# Ensure folders
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Output "Repository root: $repoRoot"

# 1) Install API dependencies
Push-Location (Join-Path $repoRoot 'api')
if (Test-Path package-lock.json -and Test-Path package.json) {
  Write-Output 'Installing API dependencies (npm ci)...'
  npm ci
} elseif (Test-Path package.json) {
  Write-Output 'Installing API dependencies (npm install)...'
  npm install
} else {
  Write-Output 'No package.json found in api/, skipping dependency install.'
}
Pop-Location

# 2) Build or copy UI
$uiDist = Join-Path $repoRoot 'ui\dist'
if (-not (Test-Path $uiDist)) {
  Write-Output "No prebuilt UI found in $uiDist. Building UI..."
  Push-Location (Join-Path $repoRoot 'ui')
  npm ci
  npm run build
  Pop-Location
} else {
  Write-Output "Found prebuilt UI in $uiDist."
}

# Copy UI dist into api/public
$apiPublic = Join-Path $repoRoot 'api\public'
if (Test-Path $apiPublic) { Remove-Item -Recurse -Force $apiPublic }
New-Item -ItemType Directory -Path $apiPublic -Force | Out-Null

Write-Output "Copying UI files to api/public..."
Copy-Item -Path (Join-Path $uiDist '*') -Destination $apiPublic -Recurse -Force

# 3) Install agent binary if available
$agentRelease = Join-Path $repoRoot 'agent\target\release'
if (Test-Path $agentRelease) {
  $exe = Get-ChildItem -Path $agentRelease -Filter '*antivirus-agent*.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($exe) {
    $agentDestDir = Join-Path $InstallPath 'agent'
    New-Item -ItemType Directory -Path $agentDestDir -Force | Out-Null
    Copy-Item -Path $exe.FullName -Destination (Join-Path $agentDestDir $exe.Name) -Force
    Write-Output "Agent binaire copié: $($exe.Name)"
  } else {
    Write-Output 'Aucun binaire d\'agent trouvé dans agent/target/release. Si tu veux un binaire, construis l\'agent localement ou récupère-le depuis CI.'
  }
} else {
  Write-Output "Dossier agent/target/release introuvable, saut de l'étape agent." 
}

# 4) Register API as Windows service (if not skipped)
if (-not $SkipService) {
  $serviceName = 'AntivirusAPI'
  $serviceDisplay = 'Antivirus API Service'
  $serverJs = Join-Path $repoRoot 'api\server.js'
  if (-not (Test-Path $serverJs)) { Abort "Fichier server.js introuvable: $serverJs" }

  # Build the binPath argument for sc.exe
  $binPath = '"' + $NodePath + '" "' + $serverJs + '"'

  # If service exists, try to stop and delete
  $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
  if ($svc) {
    Write-Output "Stopping existing service $serviceName..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -s 1
  }

  Write-Output "Creating service $serviceName..."
  $create = sc.exe create $serviceName binPath= $binPath DisplayName= "$serviceDisplay" start= auto
  if ($LASTEXITCODE -ne 0) { Write-Warning "La création du service a renvoyé un code non nul: $LASTEXITCODE" }

  Write-Output "Starting service $serviceName..."
  Start-Service -Name $serviceName -ErrorAction SilentlyContinue
  Start-Sleep -s 2
  $svc2 = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
  if ($svc2 -and $svc2.Status -eq 'Running') {
    Write-Output "Service $serviceName démarré avec succès."
  } else {
    Write-Warning "Impossible de démarrer le service $serviceName (vérifie les logs/permissions). Tu peux démarrer manuellement: node api\\server.js"
  }
} else {
  Write-Output 'SkipService: service registration skipped.'
}

Write-Output "Installation terminée. Vérifie l'API: http://localhost:3000/healthz"

# End
