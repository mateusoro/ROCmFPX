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

## Comando alternativo — Qwen3.5-9B-ROCMFP4-COHERENT (sem MTP)

Mesma base, com o modelo **Qwen3.5-9B-ROCMFP4-COHERENT.gguf** (5,31 GB, quantizado a partir do BF16 do `unsloth/Qwen3.5-9B-GGUF`):

```powershell
& "C:\Users\Administrador\ROCmFPX-built-20260801\llama-server.exe" -m "C:\Users\Administrador\.lmstudio\models\unsloth\Qwen3.5-9B-GGUF\Qwen3.5-9B-ROCMFP4-COHERENT.gguf" -c 120000 -ctk turbo4 -ctv turbo4 -ngl 999 -dev ROCm0 -fa on --jinja --host 127.0.0.1 --port 1234 --alias lms
```

> **Sem MTP:** este GGUF **não** tem head MTP/NextN (verificado — a quantização termina em blk.31, sem tensores mtp), então não use `--spec-type draft-mtp`. Para resposta direta sem raciocínio (o modelo gera `reasoning_content`), adicione `--reasoning off`.

## Comando alternativo — Ornith-1.0-9B-ROCmFP4-COHERENT (criado por nós)

Mesma base, com o modelo **Ornith-1.0-9B-ROCmFP4-COHERENT.gguf** (5,31 GB, convertido por nós a partir do BF16 do `unsloth/Ornith-1.0-9B-GGUF` — ver guia de conversão no final deste arquivo):

```powershell
& "C:\Users\Administrador\ROCmFPX-built-20260801\llama-server.exe" -m "C:\Users\Administrador\.lmstudio\models\unsloth\Ornith-1.0-9B-GGUF\Ornith-1.0-9B-ROCmFP4-COHERENT.gguf" -c 120000 -ctk turbo4 -ctv turbo4 -ngl 999 -dev ROCm0 -fa on --jinja --host 127.0.0.1 --port 1234 --alias lms --temp 1.0 --top-k 20 --top-p 0.95
```

> **Sampling:** `--temp 1.0` (temperatura, alias `--temperature`), `--top-k 20`, `--top-p 0.95` (defaults do llama-server: temp 0.80, top-k 40, top-p 0.95 — estes flags sobrescrevem). Medido no teste: ~83 tok/s de decode na RX 7800 XT.
> **Sem MTP:** este GGUF **não** tem head MTP/NextN (a conversão termina em blk.31, sem tensores mtp), então não use `--spec-type draft-mtp`. O modelo gera `reasoning_content`; para resposta direta, adicione `--reasoning off`.

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

## Usar com o pi (harness) — já configurado

Com o servidor ativo (qualquer um dos comandos acima), o usuário pode usar o pi apontando direto para ele:

```
pi --model lmstudio/lms
```

O provider `lmstudio` com o modelo `lms` **já está configurado** no pi (`~/.pi/agent/models.json`, baseUrl `http://127.0.0.1:1234/v1`), então não precisa de setup — basta o servidor estar no ar na porta 1234.

## Endpoints

- `http://127.0.0.1:1234/v1/models` — lista modelos (retorna `lms`)
- `http://127.0.0.1:1234/v1/chat/completions` — chat (OpenAI-compatível)
- `http://127.0.0.1:1234/v1/completions` — completions
- `http://127.0.0.1:1234/v1/embeddings` — embeddings

---

# Guia de conversão de modelos → ROCmFP4-COHERENT

Converte um GGUF **BF16/F16** (não quantizado) para o formato **`Q4_0_ROCMFP4_COHERENT`** (4.70 bpw: ROCmFP4 + token embeddings Q6_K), o mesmo usado pelos modelos `*-ROCmFP4-COHERENT` do LM Studio.

## Pré-requisitos

1. O binário **`llama-quantize.exe`** do build ROCmFPX (mesmo build do servidor):
   `C:\Users\Administrador\ROCmFPX-built-20260801\llama-quantize.exe`
2. O modelo de origem em GGUF **BF16/F16** (não quantizado). Se você só tem safetensors/HF, converta antes com `convert_hf_to_gguf.py` do projeto.
3. PATH do ROCm (ver seção "Pré-requisito: PATH do ROCm" no topo) para o runtime não falhar com `STATUS_DLL_NOT_FOUND`.

## Comando (PowerShell)

Sintaxe: `llama-quantize.exe <entrada-BF16.gguf> <saida.gguf> Q4_0_ROCMFP4_COHERENT`

### Exemplo real — Ornith-1.0-9B (executado em 03/08/2026)

```powershell
& "C:\Users\Administrador\ROCmFPX-built-20260801\llama-quantize.exe" "C:\Users\Administrador\.lmstudio\models\unsloth\Ornith-1.0-9B-GGUF\Ornith-1.0-9B-BF16.gguf" "C:\Users\Administrador\.lmstudio\models\unsloth\Ornith-1.0-9B-GGUF\Ornith-1.0-9B-ROCmFP4-COHERENT.gguf" Q4_0_ROCMFP4_COHERENT
```

Resultado real: 17.9 GB BF16 (16.00 BPW) → **5.31 GB** (4.74 BPW), ~103 s de quantização.

> **PowerShell:** o `&` antes do caminho é obrigatório (igual ao `llama-server`).
> **CMD:** o mesmo comando funciona sem o `&`.

## Passo a passo

1. Baixe/coloque o modelo BF16 na pasta de modelos do LM Studio (ex.: `C:\Users\Administrador\.lmstudio\models\<autor>\<modelo>-GGUF\`).
2. Rode o comando acima trocando os caminhos de entrada e saída.
3. O output fica na mesma pasta (ex.: `Ornith-1.0-9B-ROCmFP4-COHERENT.gguf`) — o LM Studio já reconhece como um modelo novo.
4. Para servir com o `llama-server`, use o mesmo padrão de comando do topo deste arquivo (`-m` apontando para o GGUF COHERENT gerado).

## Dicas

- **Estimativa sem rodar a conversão inteira:** adicione `--dry-run` antes da entrada — mostra o tamanho final estimado (ex.: `quant size = 5056.75 MiB (4.74 BPW)`) e valida o preset.
- **Outros presets ROCmFP4** (mesma sintaxe, troque o último argumento):

  | Preset | O que faz |
  |---|---|
  | `Q4_0_ROCMFP4` | 4.50 bpw ROCmFP4 padrão |
  | `Q4_0_ROCMFP4_COHERENT` | **4.70 bpw ROCmFP4 + Q6_K token embeddings (usado aqui)** |
  | `Q4_0_ROCMFP4_FAST` | 4.25 bpw layout de velocidade single-scale |
  | `Q4_0_ROCMFP4_FAST_COHERENT` | ~4.45 bpw fast + Q6_K embeddings |
  | `Q4_0_ROCMFP4_STRIX` | ~4.49 bpw receita K/V Strix Halo |
  | `Q4_0_ROCMFP4_STRIX_LEAN` | ~4.38 bpw Strix K/V + Q5_K embeddings |

- **Via script do projeto** (Git Bash/Linux, equivale ao comando acima):
  `FORMAT=rocmfp4 PROFILE=agent SRC=model-BF16.gguf OUT=model-ROCmFP4-COHERENT.gguf scripts/quantize-rocmfpx-agent.sh`
  (mapeamento: `rocmfp4` + `agent` → `Q4_0_ROCMFP4_COHERENT`)
- **Sem MTP:** a conversão **não** adiciona head MTP/NextN. Se o BF16 de origem não tiver tensores `mtp`, o GGUF final não suporta `--spec-type draft-mtp` (use o servidor sem esse flag).
