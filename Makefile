
MODEL ?= qwen3-coder:30b 

#MODEL=hf.co/DavidAU/Qwen3.8-27B-TURBO-Fable-Cold-Fusion-735-882-Heretic-Uncensored-NEO-CODER-MAX-MTP-GGUF:Q4_K_M
#MODEL=hf.co/OBLITERATUS/Qwen3.8-27B-OBLITERATED:Q4_K_M (khateeeeer)
#qwen3-coder:30b (claude code )
# dolphin-llama3:8B (uncensored waa3er + khfif)
# qwen3:8b
# Wizard-Vicuna-Uncensored
# dolphin-mistral for coding tasks
# hf.co/DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF (hadra bzf +machi bsah uncensored)

.PHONY: help up pull run ask list ps bench logs down clean up-gpu gpu-check serve claude

help:
	@grep -E '^[a-z-]+:.##' $(MAKEFILE_LIST) | sed 's/:.##/\t/'

up:
	docker compose up -d
	@echo "Ollama running on http://localhost:11434"

pull:
	docker compose exec ollama ollama pull $(MODEL)

run:
	docker compose exec ollama ollama run $(MODEL)

run-fast: ## Interactive chat, thinking disabled
	docker compose exec ollama ollama run --think=false $(MODEL)

ask: ## One API request (Q="your question")
	@curl -s http://localhost:11434/v1/chat/completions \
	  -H 'Content-Type: application/json' \
	  -d '{"model":"$(MODEL)","messages":[{"role":"user","content":"$(or $(Q),Say hello in one sentence)"}],"stream":false}' \
	  | jq -r '.choices[0].message.content'

ask-fast: ## Ask with thinking disabled
	@curl -s http://localhost:11434/api/chat \
	  -H 'Content-Type: application/json' \
	  -d '{"model":"$(MODEL)","messages":[{"role":"user","content":"$(or $(Q),Say hello)"}],"think":false,"stream":false}' \
	  | jq -r '.message.content'

list: ## Models downloaded
	docker compose exec ollama ollama list

ps: ## Models currently loaded in RAM
	docker compose exec ollama ollama ps

bench: ## Speed test for MODEL
	docker compose exec ollama ollama run --verbose $(MODEL) "Count from 1 to 20."

logs: ## Follow logs
	docker compose logs -f

up-gpu: ## Start with NVIDIA GPU
	docker compose -f compose.yaml -f compose.gpu.yaml up -d

gpu-check: ## Verify GPU is visible in the container
	docker compose exec ollama nvidia-smi

serve: ## Start bound to LAN (see README security note)
	BIND_ADDR=0.0.0.0 docker compose -f compose.yaml -f compose.gpu.yaml up -d
	@echo "Serving on $$(hostname -I | awk '{print $$1}'):11434"

claude: ## Claude Code against local/remote Ollama
	@./scripts/claude-local.sh

down: ## Stop (models kept)
	docker compose down

clean: ## Stop and DELETE all models
	docker compose down -v