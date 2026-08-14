#!/usr/bin/env bash

if pgrep -x pavucontrol >/dev/null; then
  pkill -TERM -x pavucontrol
  exit 0
fi

exec uwsm app -- pavucontrol
