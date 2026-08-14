#!/usr/bin/env bash

set -u

notifications() {
  local active history

  active=$(makoctl list -j 2>/dev/null || printf '[]')
  history=$(makoctl history -j 2>/dev/null || printf '[]')
  jq -cn --argjson active "$active" --argjson history "$history" \
    '$active + $history | unique_by(.id) | sort_by(.id) | reverse'
}

case "${1:-}" in
  count)
    count=$(notifications | jq 'length')
    if (( count == 0 )); then
      jq -cn '{text:"󰂜",tooltip:"No recent notifications",class:["empty"]}'
    else
      noun=notifications
      (( count == 1 )) && noun=notification
      jq -cn --arg text "󰂚 $count" --arg tooltip "$count recent $noun" \
        '{text:$text,tooltip:$tooltip,class:["has-notifications"]}'
    fi
    ;;
  show)
    exec python3 "${HOME}/.config/waybar/modules/status-popup.py" notifications
    ;;
  *)
    exit 1
    ;;
esac
