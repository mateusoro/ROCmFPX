# Start do Server

Comando literal para iniciar o servidor (llama-server, build ROCmFPX de 2026-08-01) com o modelo **Qwythos-9B-Claude-Mythos-5-1M-MTP-ROCmFP4-COHERENT**, no padrão do LM Studio (porta 1234, alias `lms`).

## Pré-requisito: PATH do ROCm

O exe exige o runtime ROCm no PATH (sem isso: `STATUS_DLL_NOT_FOUND`).
O caminho `C:\Program Files\AMD\ROCm\7.1\bin` **já foi adicionado ao PATH global do sistema** (01/08/2026) — basta abrir um **novo** terminal.

Fallback (se um terminal antigo não pegar):

```bat
set PATH=C:\Program Files\AMD\ROCm\7.1\bin;%PATH%
```

## Comando completo (PowerShell — 1 linha)

```powershell
& "C:\Users\Administrador\ROCmFPX-built-20260801\llama-server.exe" -m "C:\Users\Administrador\.lmstudio\models\maczzinatui\Qwythos-9B-Claude-Mythos-5-1M-MTP-ROCmFP4-COHERENT-GGUF\Qwythos-9B-Claude-Mythos-5-1M-MTP-ROCmFP4-COHERENT.gguf" -c 120000 -ctk turbo4 -ctv turbo4 -ngl 999 -dev ROCm0 -fa on --jinja --spec-type draft-mtp --spec-draft-n-max 6 --spec-draft-p-min 0.6 --host 127.0.0.1 --port 1234 --alias lms
```

> **PowerShell:** o `&` antes do caminho é obrigatório (sem ele: `Token '-m' inesperado`).
> **CMD:** o mesmo comando funciona sem o `&`.

## Comando alternativo — Grug-12B-ROCmFP4_FAST (sem MTP, sem TurboQuant)

Mesma base, com o modelo **Grug-12B-ROCmFP4_FAST.gguf** (6,34 GB), **sem** MTP e **sem TurboQuant** (turbo4 não se aplica a este modelo), com parâmetros de sampling configurados:

```powershell
& "C:\Users\Administrador\ROCmFPX-built-20260801\llama-server.exe" -m "C:\Users\Administrador\.lmstudio\models\maczzinatui\Grug-12B-ROCmFP4_FAST-GGUF\Grug-12B-ROCmFP4_FAST.gguf" -c 120000 -ctk q4_0 -ctv q4_0 -ngl 999 -dev ROCm0 -fa on --jinja --host 127.0.0.1 --port 1234 --alias lms --temp 0.7 --top-k 40 --top-p 0.95 --min-p 0.05 --repeat-penalty 1.05 --repeat-last-n 256
```

> **Sampling:** `--temp 0.7` (temperatura), `--top-k 40`, `--top-p 0.95`, `--min-p 0.05`, `--repeat-penalty 1.05` (anti-repetição), `--repeat-last-n 256` (janela da penalidade). Para código/factual: `--temp 0.3–0.5`; para criativo: `--temp 0.8–1.0`.
> Sem MTP, o decode não usa speculative decoding (mais lento que o Qwythos com MTP).

## Explicação dos parâmetros

| Parâmetro | Valor | O que faz |
|---|---|---|
| `-m` | Qwythos-9B-Claude-Mythos-5-1M-MTP-ROCmFP4-COHERENT.gguf | Modelo (ROCmFP4-COHERENT, base Qwen3.5-9B, 1M ctx, 1 camada MTP) |
| `-c` | 120000 | Contexto de 120k tokens |
| `-ctk -ctv` | turbo4 | KV cache TurboQuant 4-bit |
| `-ngl` | 999 | Offload total para a GPU |
| `-dev` | ROCm0 | Backend HIP/ROCm (RX 7800 XT / gfx1101) |
| `-fa` | on | Flash Attention |
| `--jinja` | — | Chat template Jinja |
| `--spec-type` | draft-mtp | Speculative decoding com o head MTP embutido |
| `--spec-draft-n-max` | 6 | Máx. tokens de draft |
| `--spec-draft-p-min` | 0.6 | Prob. mínima de aceitação do draft |
| `--host --port` | 127.0.0.1:1234 | Host/porta padrão do LM Studio |
| `--alias` | lms | Nome do modelo na API (aparece como `lms` no `/v1/models`) |

## Como usar

1. Cole o comando acima no PowerShell (terminal **novo**, para pegar o PATH global).
2. Aguarde até o log mostrar `server is listening on http://127.0.0.1:1234`.
3. Use qualquer cliente OpenAI-compatível com:

```
base_url = http://127.0.0.1:1234/v1
model    = lms
```

**Importante:** NÃO defina `GGML_HIP_ENABLE_UNIFIED_MEMORY=1` ao executar os binários.

## Endpoints

- `http://127.0.0.1:1234/v1/models` — lista modelos (retorna `lms`)
- `http://127.0.0.1:1234/v1/chat/completions` — chat (OpenAI-compatível)
- `http://127.0.0.1:1234/v1/completions` — completions
- `http://127.0.0.1:1234/v1/embeddings` — embeddings
