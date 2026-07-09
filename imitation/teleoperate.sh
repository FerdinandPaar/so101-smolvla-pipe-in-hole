#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

ensure_lerobot_root

lerobot-teleoperate \
  --robot.type="$ROBOT_TYPE" \
  --robot.port="$ROBOT_PORT" \
  --robot.id="$ROBOT_ID" \
  --robot.cameras="$ROBOT_CAMERAS_RECORD" \
  --teleop.type="$TELEOP_TYPE" \
  --teleop.port="$TELEOP_PORT" \
  --teleop.id="$TELEOP_ID" \
  --display_data="$DISPLAY_DATA"
