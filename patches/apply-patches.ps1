# Script para aplicar patches de build Windows ROCm
# Uso: .\patches\apply-patches.ps1
# Ou: cd patches && .\apply-patches.ps1

param(
    [string]$RepoPath = ".."
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Aplicando patches para build Windows ROCm ===" -ForegroundColor Cyan
Write-Host "Repositório: $RepoPath"

# Verificar se o repositório existe
if (-not (Test-Path "$RepoPath\.git")) {
    Write-Host "Erro: $RepoPath não é um repositório git válido" -ForegroundColor Red
    exit 1
}

Set-Location $RepoPath

# 1. Aplicar patch de correção wchar_t
Write-Host ""
Write-Host "1. Aplicando correção wchar_t para Windows..." -ForegroundColor Yellow
$patchFile = "patches\0001-fix-wchar-conversion.patch"
if (Test-Path $patchFile) {
    git apply $patchFile
    Write-Host "   ✓ Patch aplicado com sucesso" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Patch não encontrado, pulando" -ForegroundColor DarkYellow
}

# 2. Copiar workflow de build
Write-Host ""
Write-Host "2. Adicionando workflow de build Windows ROCm..." -ForegroundColor Yellow
New-Item -Path ".github\workflows" -ItemType Directory -Force | Out-Null
$workflowFile = "patches\build-windows-rocm.yml"
if (Test-Path $workflowFile) {
    Copy-Item $workflowFile ".github\workflows\"
    Write-Host "   ✓ Workflow copiado com sucesso" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Workflow não encontrado, pulando" -ForegroundColor DarkYellow
}

# 3. Mostrar status
Write-Host ""
Write-Host "=== Status das alterações ===" -ForegroundColor Cyan
git status

Write-Host ""
Write-Host "=== Próximos passos ===" -ForegroundColor Cyan
Write-Host "  git add ."
Write-Host "  git commit -m 'feat: add Windows ROCm build support'"
Write-Host "  git push origin main"
Write-Host ""
Write-Host "Para criar uma release:"
Write-Host "  git tag v1.0.0"
Write-Host "  git push origin v1.0.0"
