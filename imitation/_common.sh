#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -n "${CONFIG_FILE:-}" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
elif [[ -f "$SCRIPT_DIR/config.sh" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/config.sh"
fi

: "${LEROBOT_ROOT:=$PWD}"
: "${PYTHON:=python}"

: "${ROBOT_TYPE:=so101_follower}"
: "${ROBOT_PORT:=/dev/tty.usbmodem5A7C1223701}"
: "${ROBOT_ID:=ferdis_awesome_follower_arm}"
: "${TELEOP_TYPE:=so101_leader}"
: "${TELEOP_PORT:=/dev/tty.usbmodem5A7C1184361}"
: "${TELEOP_ID:=ferdis_awesome_leader_arm}"

DEFAULT_ROBOT_CAMERAS_RECORD='{"front": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30, "rotation": 0}, "side": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30, "rotation": 0}}'
DEFAULT_ROBOT_CAMERAS_INFERENCE='{"camera1": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30}, "camera2": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30}}'
: "${ROBOT_CAMERAS_RECORD:=$DEFAULT_ROBOT_CAMERAS_RECORD}"
: "${ROBOT_CAMERAS_INFERENCE:=$DEFAULT_ROBOT_CAMERAS_INFERENCE}"

: "${DATASET_REPO_ID:=mundgelenk/so101_50_pipe_in_hole}"
: "${MODEL_REPO_ID:=mundgelenk/smolvla_so101_pipe_in_hole}"
: "${BASE_POLICY:=lerobot/smolvla_base}"
: "${TASK_NAME:=Pipe in hole}"

: "${NUM_EPISODES:=50}"
: "${DATASET_ROOT:=data/so101_50_pipe_in_hole}"
: "${PUSH_DATASET_TO_HUB:=true}"
: "${DISPLAY_DATA:=true}"

: "${CUDA_VISIBLE_DEVICES:=0}"
: "${JOB_NAME:=smolvla_pipe_in_hole}"
: "${OUTPUT_DIR:=outputs/train/smolvla_pipe_in_hole}"
: "${BATCH_SIZE:=16}"
: "${STEPS:=30000}"
: "${SAVE_FREQ:=2500}"
: "${USE_AMP:=true}"
: "${EMPTY_CAMERAS:=1}"
: "${WANDB_ENABLE:=true}"
: "${WANDB_ENTITY:=}"
: "${WANDB_PROJECT:=lerobot-smolvla}"
DEFAULT_RENAME_MAP='{"observation.images.front": "observation.images.camera1", "observation.images.side": "observation.images.camera2"}'
: "${RENAME_MAP:=$DEFAULT_RENAME_MAP}"

: "${MODEL_LOCAL_DIR:=my_models/smolvla_pipe_in_hole}"
: "${EVAL_EPISODES:=10}"
: "${EPISODE_TIME_S:=30}"
: "${RESET_TIME_S:=20}"
: "${PUSH_EVAL_TO_HUB:=false}"

ensure_lerobot_root() {
  if [[ ! -f "$LEROBOT_ROOT/src/lerobot/scripts/lerobot_record.py" ]]; then
    echo "LEROBOT_ROOT does not point to a LeRobot checkout: $LEROBOT_ROOT" >&2
    echo "Set LEROBOT_ROOT in imitation/config.sh or CONFIG_FILE." >&2
    exit 1
  fi
  cd "$LEROBOT_ROOT"
}
