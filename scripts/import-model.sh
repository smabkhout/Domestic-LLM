#!/usr/bin/env bash
set -euo pipefail

NAME="${1:?usage: import-model.sh <name>}"
cd "$(dirname "$0")/.."
MF="modelfiles/${NAME}.Modelfile"

[ -f "$MF" ] || { echo "no such modelfile: $MF" >&2; exit 1; }

if docker compose exec -T ollama ollama list 2>/dev/null \
   | awk '{print $1}' | grep -qx "${NAME}:latest"; then
  echo "${NAME} already registered"
  exit 0
fi

docker compose cp "$MF" "ollama:/tmp/${NAME}.Modelfile"
docker compose exec ollama ollama create "$NAME" -f "/tmp/${NAME}.Modelfile"
echo "registered: ${NAME}"
