#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

ensure_lerobot_root

EVAL_REPO_ID="${EVAL_REPO_ID:-local/eval_run_$(date +%s)}"

"$PYTHON" src/lerobot/scripts/lerobot_record.py \
  --robot.type="$ROBOT_TYPE" \
  --robot.port="$ROBOT_PORT" \
  --robot.cameras="$ROBOT_CAMERAS_INFERENCE" \
  --policy.path="$MODEL_LOCAL_DIR" \
  --dataset.num_episodes="$EVAL_EPISODES" \
  --dataset.episode_time_s="$EPISODE_TIME_S" \
  --dataset.reset_time_s="$RESET_TIME_S" \
  --dataset.repo_id="$EVAL_REPO_ID" \
  --dataset.single_task="$TASK_NAME" \
  --dataset.push_to_hub="$PUSH_EVAL_TO_HUB"
