#!/usr/bin/env python3
"""Remove training-only fields from a downloaded LeRobot policy config."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("config", type=Path, help="Path to config.json")
    args = parser.parse_args()

    with args.config.open("r", encoding="utf-8") as f:
        data = json.load(f)

    removed = []
    for key in ("pretrained_path", "rtc_config"):
        if key in data:
            data.pop(key)
            removed.append(key)

    with args.config.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)
        f.write("\n")

    if removed:
        print(f"Removed: {', '.join(removed)}")
    else:
        print("No training-only fields found.")


if __name__ == "__main__":
    main()
