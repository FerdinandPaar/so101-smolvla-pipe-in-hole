#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_common.sh"

ensure_lerobot_root

WANDB_ARGS=(--wandb.enable="$WANDB_ENABLE" --wandb.project="$WANDB_PROJECT")
if [[ -n "$WANDB_ENTITY" ]]; then
  WANDB_ARGS+=(--wandb.entity="$WANDB_ENTITY")
fi

PYTHONPATH="src${PYTHONPATH:+:$PYTHONPATH}" CUDA_VISIBLE_DEVICES="$CUDA_VISIBLE_DEVICES" \
  "$PYTHON" src/lerobot/scripts/lerobot_train.py \
  --policy.path="$BASE_POLICY" \
  --dataset.repo_id="$DATASET_REPO_ID" \
  --dataset.revision=main \
  --job_name="$JOB_NAME" \
  --output_dir="$OUTPUT_DIR" \
  --policy.repo_id="$MODEL_REPO_ID" \
  --policy.push_to_hub=true \
  --batch_size="$BATCH_SIZE" \
  --steps="$STEPS" \
  --save_freq="$SAVE_FREQ" \
  "${WANDB_ARGS[@]}" \
  --policy.empty_cameras="$EMPTY_CAMERAS" \
  --policy.use_amp="$USE_AMP" \
  --rename_map="$RENAME_MAP"
