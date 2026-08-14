#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"

grimblast -t ppm save output - |
	satty --filename - \
		--floating-hack \
		--copy-command wl-copy \
		--early-exit all \
		--output-filename "$screenshot_dir/screenshot-%Y%m%d-%H%M%S.png"
