#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="$HOME/Pictures/Screenshots"
output="$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')"
mkdir -p "$screenshot_dir"

grim -o "$output" -t ppm - |
	satty --filename - \
		--floating-hack \
		--copy-command wl-copy \
		--early-exit all \
		--output-filename "$screenshot_dir/screenshot-%Y%m%d-%H%M%S.png"
