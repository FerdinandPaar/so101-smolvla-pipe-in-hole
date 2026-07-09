#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export EVAL_EPISODES="${EVAL_EPISODES:-10}"
export EPISODE_TIME_S="${EPISODE_TIME_S:-30}"
export RESET_TIME_S="${RESET_TIME_S:-20}"

exec "$SCRIPT_DIR/run_inference.sh"
