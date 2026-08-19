#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"

geometry="$(slurp)"

grim -g "$geometry" -t ppm - |
	satty --filename - \
		--floating-hack \
		--copy-command wl-copy \
		--early-exit all \
		--output-filename "$screenshot_dir/screenshot-%Y%m%d-%H%M%S.png"
