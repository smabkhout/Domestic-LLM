#!/usr/bin/env bash
set -euo pipefail

HOST="${OLLAMA_HOST_URL:-http://localhost:11434}"
MODEL="${MODEL:-hf.co/OBLITERATUS/Qwen3.8-27B-OBLITERATED:Q4_K_M}"
#MODEL="${MODEL:-qwen3-coder:30b}"



if ! curl -sf "${HOST}/api/tags" >/dev/null; then
  echo "error: no Ollama at ${HOST}" >&2
  echo "  local:  make up" >&2
  echo "  remote: export OLLAMA_HOST_URL=http://<server-ip>:11434" >&2
  exit 1
fi

if ! curl -s "${HOST}/api/tags" | jq -e --arg m "$MODEL" '.models[] | select(.name==$m)' >/dev/null; then
  echo "error: model ${MODEL} not pulled on ${HOST}" >&2
  echo "  run: make pull MODEL=${MODEL}" >&2
  exit 1
fi

export ANTHROPIC_BASE_URL="$HOST"
export ANTHROPIC_AUTH_TOKEN="ollama"
export ANTHROPIC_API_KEY=""

exec claude --model "$MODEL" "$@"