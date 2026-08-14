#!/usr/bin/env bash

set -u

confirm() {
  local action answer
  action=$1
  answer=$(printf 'No\nYes\n' | rofi -dmenu -i -p "Confirm ${action}?") || return 1
  [[ "$answer" == "Yes" ]]
}

action=$(printf 'Suspend\nReboot\nPower off\n' | rofi -dmenu -i -p 'Power') || exit 0

case "$action" in
  Suspend)
    systemctl suspend
    ;;
  Reboot)
    confirm reboot && systemctl reboot
    ;;
  "Power off")
    confirm "power off" && systemctl poweroff
    ;;
esac
