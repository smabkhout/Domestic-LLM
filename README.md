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