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

REPO=$(sed -n 's/^# *REPO=//p' "$MF" | head -1)
FILE=$(sed -n 's/^# *FILE=//p' "$MF" | head -1)

if [ -n "$FILE" ]; then
  mkdir -p models
  if [ -f "models/${FILE}" ]; then
    echo "models/${FILE} already downloaded"
  else
    echo "fetching ${FILE}"
    curl -fL -C - --retry 3 -o "models/${FILE}" \
      "https://huggingface.co/${REPO}/resolve/main/${FILE}"
  fi
fi

docker compose cp "$MF" "ollama:/tmp/${NAME}.Modelfile"
docker compose exec ollama ollama create "$NAME" -f "/tmp/${NAME}.Modelfile"
echo "registered: ${NAME}"
