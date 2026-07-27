#!/bin/bash
# Script para aplicar patches de build Windows ROCm
# Uso: ./patches/apply-patches.sh
# Ou: cd patches && ./apply-patches.sh

set -e

REPO_DIR="${1:-..}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Aplicando patches para build Windows ROCm ==="
echo "Repositório: $REPO_DIR"

# Verificar se o repositório existe
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Erro: $REPO_DIR não é um repositório git válido"
    exit 1
fi

cd "$REPO_DIR"

# 1. Aplicar patch de correção wchar_t
echo ""
echo "1. Aplicando correção wchar_t para Windows..."
if [ -f "patches/0001-fix-wchar-conversion.patch" ]; then
    git apply "patches/0001-fix-wchar-conversion.patch"
    echo "   ✓ Patch aplicado com sucesso"
else
    echo "   ⚠ Patch não encontrado, pulando"
fi

# 2. Copiar workflow de build
echo ""
echo "2. Adicionando workflow de build Windows ROCm..."
mkdir -p .github/workflows
if [ -f "patches/build-windows-rocm.yml" ]; then
    cp "patches/build-windows-rocm.yml" .github/workflows/
    echo "   ✓ Workflow copiado com sucesso"
else
    echo "   ⚠ Workflow não encontrado, pulando"
fi

# 3. Mostrar status
echo ""
echo "=== Status das alterações ==="
git status

echo ""
echo "=== Próximos passos ==="
echo "  git add ."
echo "  git commit -m 'feat: add Windows ROCm build support'"
echo "  git push origin main"
echo ""
echo "Para criar uma release:"
echo "  git tag v1.0.0"
echo "  git push origin v1.0.0"
