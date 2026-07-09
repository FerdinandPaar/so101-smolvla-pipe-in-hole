#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

ensure_lerobot_root

mkdir -p "$(dirname "$MODEL_LOCAL_DIR")"
hf download "$MODEL_REPO_ID" \
  --repo-type model \
  --local-dir "$MODEL_LOCAL_DIR"

"$PYTHON" "$SCRIPT_DIR/clean_model_config.py" "$MODEL_LOCAL_DIR/config.json"
