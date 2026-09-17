MODEL ?= qwen3:8b

.PHONY: help up pull run ask list ps bench logs down clean

help:
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/\t/'

up:
	docker compose up -d
	@echo "Ollama running on http://localhost:11434"

pull:
	docker compose exec ollama ollama pull $(MODEL)

run:
	docker compose exec ollama ollama run $(MODEL)

ask: ## One API request (Q="your question")
	@curl -s http://localhost:11434/v1/chat/completions \
	  -H 'Content-Type: application/json' \
	  -d '{"model":"$(MODEL)","messages":[{"role":"user","content":"$(or $(Q),Say hello in one sentence)"}],"stream":false}' \
	  | jq -r '.choices[0].message.content'

list: ## Models downloaded
	docker compose exec ollama ollama list

ps: ## Models currently loaded in RAM
	docker compose exec ollama ollama ps

bench: ## Speed test for MODEL
	docker compose exec ollama ollama run --verbose $(MODEL) "Count from 1 to 20."

logs: ## Follow logs
	docker compose logs -f

down: ## Stop (models kept)
	docker compose down

clean: ## Stop and DELETE all models
	docker compose down -v