Param(
  [Parameter(Mandatory=$true)]
  [string]$Tag,
  [string]$ReleaseName = "",
  [switch]$RunWorkflow
)

function Abort($msg) {
  Write-Error $msg
  exit 1
}

# Ensure we're in repo root
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repoRoot

Write-Output "Repo root: $repoRoot"

# Check git available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Abort "git n'est pas installé ou n'est pas disponible dans PATH. Installe git avant de continuer."
}

# Ensure working tree is clean
$status = git status --porcelain
if ($status) {
  Write-Warning "L'arbre de travail n'est pas propre. Commit ou stash tes changements avant de créer une release."
  Write-Output $status
  Pause
}

if (-not $ReleaseName -or $ReleaseName -eq "") {
  $ReleaseName = $Tag
}

Write-Output "Creating tag $Tag and pushing to origin..."

# Create annotated tag
git tag -a $Tag -m "Release $ReleaseName" || Abort "Impossible de créer le tag."

# Push tag
git push origin $Tag || Abort "Impossible de pousser le tag vers origin. Vérifie tes permissions et le remote 'origin'."

Write-Output "Tag pushed: $Tag"

if ($RunWorkflow) {
  # Try to use gh CLI to dispatch the manual workflow
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Output "Dispatching GitHub Actions workflow 'Manual Release' via gh..."
    gh workflow run manual-release.yml --ref main -f tag=$Tag -f release_name=$ReleaseName
    Write-Output "Workflow dispatched (via gh). Vérifie l'onglet Actions sur GitHub."
  } else {
    Write-Warning "La CLI 'gh' n'est pas disponible. Le tag a été poussé, mais tu dois déclencher manuellement le workflow depuis l'interface GitHub Actions (ou installer 'gh' et relancer ce script avec -RunWorkflow)."
    Write-Output "Pour déclencher manuellement : GitHub → Actions → Manual Release → Run workflow, renseigne 'tag' = $Tag et clique Run."
  }
} else {
  Write-Output "Tag créé et poussé. Pour créer la Release et build CI, va dans GitHub → Actions → Manual Release → Run workflow et renseigne 'tag' = $Tag (ou installe 'gh' et relance avec -RunWorkflow)."
}

Write-Output "Opération terminée."
