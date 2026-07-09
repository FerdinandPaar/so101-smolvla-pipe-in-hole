#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

ensure_lerobot_root

"$PYTHON" src/lerobot/scripts/lerobot_record.py \
  --robot.type="$ROBOT_TYPE" \
  --robot.port="$ROBOT_PORT" \
  --robot.id="$ROBOT_ID" \
  --robot.cameras="$ROBOT_CAMERAS_RECORD" \
  --teleop.type="$TELEOP_TYPE" \
  --teleop.port="$TELEOP_PORT" \
  --teleop.id="$TELEOP_ID" \
  --dataset.repo_id="$DATASET_REPO_ID" \
  --dataset.num_episodes="$NUM_EPISODES" \
  --dataset.single_task="$TASK_NAME" \
  --dataset.push_to_hub="$PUSH_DATASET_TO_HUB" \
  --display_data="$DISPLAY_DATA"
