# Patches para Build Windows ROCm

Este diretório contém patches e scripts para habilitar builds Windows com ROCm/HIP no ROCmFPX.

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `0001-fix-wchar-conversion.patch` | Corrige bug de conversão wchar_t no Windows |
| `build-windows-rocm.yml` | Workflow GitHub Actions para build automático |
| `apply-patches.ps1` | Script PowerShell para aplicar patches |
| `apply-patches.sh` | Script Bash para aplicar patches |

## Como usar

### Aplicar patches em um repositório novo

```powershell
# PowerShell (recomendado no Windows)
cd patches
.\apply-patches.ps1

# Ou especificando o caminho
.\apply-patches.ps1 -RepoPath "C:\caminho\ROCmFPX"
```

```bash
# Bash (Linux/Mac/WSL)
cd patches
./apply-patches.sh

# Ou especificando o caminho
./apply-patches.sh /caminho/ROCmFPX
```

### Atualizar com upstream

Quando o repositório original for atualizado:

```powershell
# 1. Adicionar upstream (uma vez)
git remote add upstream https://github.com/ciru-ai/ROCmFPX.git

# 2. Buscar atualizações
git fetch upstream

# 3. Reaplicar patches
git apply patches/0001-fix-wchar-conversion.patch

# 4. Copiar workflow (se não existir)
Copy-Item patches\build-windows-rocm.yml .github\workflows\ -ErrorAction SilentlyContinue

# 5. Commit e push
git add .
git commit -m "feat: reapply Windows ROCm patches"
git push origin main
```

### Criar release automática

```powershell
git tag v1.0.0
git push origin v1.0.0
```

O GitHub Actions irá buildar automaticamente e publicar os binários na release.

## Build manual

Se preferir buildar localmente:

```powershell
# Configurar ambiente
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
set ROCM_PATH=C:\Program Files\AMD\ROCm\7.1
set PATH=%ROCM_PATH%\bin;C:\tools\cmake\bin;%PATH%

# Configurar e buildar
cmake -S . -B build -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_C_COMPILER="%ROCM_PATH%/bin/clang.exe" ^
    -DCMAKE_CXX_COMPILER="%ROCM_PATH%/bin/clang++.exe" ^
    -DGGML_HIP=ON ^
    -DGGML_HIP_FORCE_MMQ=ON ^
    -DCMAKE_HIP_ARCHITECTURES=gfx1101 ^
    -DLLAMA_BUILD_SERVER=ON

cmake --build build -j 8
```

**IMPORTANTE:** NÃO defina `GGML_HIP_ENABLE_UNIFIED_MEMORY=1` ao executar o servidor.
