Commands for adam pc

# NVIDIA container runtime
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

git clone git@github.com:smabkhout/Domestic-LLM.git
cd Domestic-LLM

make up-gpu
make gpu-check          # must show your 4070
make pull MODEL=qwen3-coder:30b
make ask MODEL=qwen3-coder:30b

node --version          # need 18+
npm install -g @anthropic-ai/claude-code

MODEL=qwen3-coder:30b /path/to/Domestic-LLM/scripts/claude-local.sh

## Custom models

Custom models (with tuned parameters) live in `modelfiles/*.Modelfile`, dispatched
by name:

```bash
make down && make up           # once, to pick up the ./models bind mount
make models-available          # list defined custom modelfiles
make import NAME=turbo         # download + register (first time only)
make use NAME=turbo            # import if needed, then open a chat
```

Each Modelfile that needs a GGUF not in Ollama's library carries its own download
info as `# REPO=` / `# FILE=` comments; `scripts/import-model.sh` downloads that
file into the gitignored `models/` folder (bind-mounted into the container at
`/models`) and points the Modelfile's `FROM` at it. This bypasses Ollama's `hf.co/`
name-length bug (see below), at the cost of double disk usage during import: the
raw download plus Ollama's own copy in its internal store.

- `turbo` — DavidAU's `Qwen3.8-27B-TURBO-Fable-Cold-Fusion-...` repo, Q4_K_M
  quant, ~18GB. Needs a machine with plenty of RAM/VRAM and disk headroom (won't
  run on a 14GB-RAM laptop, and won't import on a machine with less than ~2x the
  model size free). The repo also has an "MTP" (multi-token prediction) variant
  of the same quant, slightly larger and only worth it if speculative decoding
  hits >50% acceptance for your use case — `turbo.Modelfile` uses the plain one.
  Ollama <0.33 (that includes the `0.32.5` pinned in `compose.yaml`) rejects
  `hf.co/...` references longer than 80 characters with `400 Bad Request: invalid
  model name` ([ollama#18274](https://github.com/ollama/ollama/issues/18274)),
  which this repo's full name exceeds — hence the manual-download workaround
  instead of a plain `FROM hf.co/...` line.