# SO-101 SmolVLA Pipe-in-Hole

This repository contains the report source and the minimal project files for a SmolVLA fine-tuning experiment on an SO-101 robot arm. The task was to pick up a test tube and place it into a target hole.

## Links

- Report PDF: `main.pdf`
- Training dataset: https://huggingface.co/datasets/mundgelenk/so101_50_pipe_in_hole
- Trained model: https://huggingface.co/mundgelenk/smolvla_so101_pipe_in_hole

## Repository Contents

- `main.tex`: LaTeX report source.
- `references.bib`: APA-style bibliography entries.
- `main.pdf`: Compiled report.
- `images/`: Only the images referenced by the report.

Generated LaTeX files, local model downloads, local datasets, full LeRobot source files, and workspace/editor artifacts are intentionally not included.

## Setup

Run these commands from a working LeRobot checkout with the SO-101 hardware connected.

```bash
cd lerobot
conda activate lerobot
```

## Teleoperation Check

Use teleoperation first to verify robot connection, camera indices, lighting, and whether the task is possible from the camera views alone.

```bash
lerobot-teleoperate \
  --robot.type=so101_follower \
  --robot.port=/dev/tty.usbmodem5A7C1223701 \
  --robot.id=ferdis_awesome_follower_arm \
  --robot.cameras='{"front": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30, "rotation": 0}, "side": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30, "rotation": 0}}' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/tty.usbmodem5A7C1184361 \
  --teleop.id=ferdis_awesome_leader_arm \
  --display_data=true
```

## Data Collection

Final training used 50 episodes. During development, more than 300 total episodes were recorded while tuning camera placement, lighting, reset timing, and gripper approach.

```bash
python src/lerobot/scripts/lerobot_record.py \
  --robot.type=so101_follower \
  --robot.port=/dev/tty.usbmodem5A7C1223701 \
  --robot.id=ferdis_awesome_follower_arm \
  --robot.cameras='{"front": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30}, "side": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30}}' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/tty.usbmodem5A7C1184361 \
  --teleop.id=ferdis_awesome_leader_arm \
  --dataset.repo_id=mundgelenk/so101_50_pipe_in_hole \
  --dataset.num_episodes=50 \
  --dataset.single_task="Pipe in hole" \
  --dataset.push_to_hub=true \
  --display_data=true
```

Resume recording after an interrupted session:

```bash
python src/lerobot/scripts/lerobot_record.py \
  --robot.type=so101_follower \
  --robot.port=/dev/tty.usbmodem5A7C1223701 \
  --robot.id=ferdis_awesome_follower_arm \
  --robot.cameras='{"front": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30}, "side": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30}}' \
  --teleop.type=so101_leader \
  --teleop.port=/dev/tty.usbmodem5A7C1184361 \
  --teleop.id=ferdis_awesome_leader_arm \
  --dataset.repo_id=mundgelenk/so101_50_pipe_in_hole \
  --dataset.num_episodes=50 \
  --dataset.single_task="Pipe in hole" \
  --dataset.push_to_hub=true \
  --display_data=true \
  --resume=true \
  --dataset.root=data/so101_50_pipe_in_hole
```

Recording controls:

| Key | Function | Use |
| --- | --- | --- |
| Right Arrow | Save and next | Save a successful episode and start the next one. |
| Left Arrow | Scrap and retry | Delete the current attempt and retry the same episode number. |
| Escape | Save and quit | End the session early and upload the recorded episodes. |

## Training

The final training run used one NVIDIA A100 40 GB GPU.

```bash
cd lerobot
conda activate smolvla
```

```bash
PYTHONPATH=src CUDA_VISIBLE_DEVICES=0 python src/lerobot/scripts/lerobot_train.py \
  --policy.path=lerobot/smolvla_base \
  --dataset.repo_id=mundgelenk/so101_50_pipe_in_hole \
  --dataset.revision=main \
  --job_name=smolvla_pipe_in_hole \
  --output_dir=outputs/train/smolvla_pipe_in_hole \
  --policy.repo_id=mundgelenk/smolvla_so101_pipe_in_hole \
  --policy.push_to_hub=true \
  --batch_size=16 \
  --steps=30000 \
  --save_freq=2500 \
  --wandb.enable=true \
  --wandb.entity=<your-wandb-entity> \
  --wandb.project=lerobot-smolvla \
  --policy.empty_cameras=1 \
  --policy.use_amp=true \
  --rename_map='{"observation.images.front": "observation.images.camera1", "observation.images.side": "observation.images.camera2"}'
```

Main parameters:

| Parameter | Value |
| --- | --- |
| Base policy | `lerobot/smolvla_base` |
| Dataset | `mundgelenk/so101_50_pipe_in_hole` |
| Output policy | `mundgelenk/smolvla_so101_pipe_in_hole` |
| Batch size | `16` |
| Steps | `30000` |
| Checkpoint frequency | `2500` |
| Mixed precision | `true` |
| Cameras | `front`, `side` renamed to `camera1`, `camera2` |

## Inference

Run inference locally beside the robot. In this project, this was the real bottleneck because the next motor command had to be produced on the MacBook in time.

```bash
mkdir -p my_models
hf download mundgelenk/smolvla_so101_pipe_in_hole \
  --repo-type model \
  --local-dir my_models/smolvla_pipe_in_hole

python -c 'import json; p="my_models/smolvla_pipe_in_hole/config.json"; d=json.load(open(p)); d.pop("pretrained_path", None); d.pop("rtc_config", None); json.dump(d, open(p, "w"), indent=4)'
```

```bash
python src/lerobot/scripts/lerobot_record.py \
  --robot.type=so101_follower \
  --robot.port=/dev/tty.usbmodem5A7C1223701 \
  --robot.cameras='{"camera1": {"type": "opencv", "index_or_path": 1, "width": 640, "height": 480, "fps": 30}, "camera2": {"type": "opencv", "index_or_path": 0, "width": 640, "height": 480, "fps": 30}}' \
  --policy.path=my_models/smolvla_pipe_in_hole \
  --dataset.num_episodes=10 \
  --dataset.episode_time_s=30 \
  --dataset.reset_time_s=20 \
  --dataset.repo_id=local/eval_run_$(date +%s) \
  --dataset.single_task="Pipe in hole" \
  --dataset.push_to_hub=false
```

## Report Build

The report was built with XeLaTeX and Biber:

```bash
xelatex -interaction=nonstopmode -halt-on-error main.tex
biber main
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode -halt-on-error main.tex
```
