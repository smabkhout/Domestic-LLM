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

Custom models (with tuned parameters, pulled straight from Hugging Face) live in
`modelfiles/*.Modelfile`, dispatched by name:

```bash
make models-available          # list defined custom modelfiles
make import NAME=turbo         # download + register (first time only)
make use NAME=turbo            # import if needed, then open a chat
```

- `turbo` — `hf.co/DavidAU/Qwen3.8-27B-TURBO-...-MTP-GGUF:Q4_K_M`, ~17GB. Needs a
  machine with plenty of RAM/VRAM (won't run on a 14GB laptop).