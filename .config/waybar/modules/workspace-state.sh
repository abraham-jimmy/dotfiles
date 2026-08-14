#!/usr/bin/env bash

set -u

cache_dir="${WAYBAR_WORKSPACE_CACHE_DIR:-${XDG_RUNTIME_DIR:-/tmp}/waybar-workspaces}"
middle_monitor='ASUSTek COMPUTER INC VG27B L2LMQS041890'
right_monitor='ASUSTek COMPUTER INC VG27B K7LMQS089435'

mkdir -p "$cache_dir"

read_workspace() {
  local workspace=$1 file="$cache_dir/$1.json" output

  if [[ -r "$file" ]]; then
    IFS= read -r output < "$file"
    printf '%s\n' "$output"
  elif [[ $workspace == games ]]; then
    printf '{"text":"","tooltip":"Steam games","class":["hidden"]}\n'
  elif (( workspace <= 3 )); then
    printf '{"text":"○","tooltip":"Middle monitor workspace %s","class":["empty"]}\n' "$workspace"
  else
    printf '{"text":"%s","tooltip":"Right monitor workspace %s","class":["empty"]}\n' "$workspace" "$workspace"
  fi
}

workspace_fifo() {
  printf '%s/%s.fifo\n' "$cache_dir" "$1"
}

ensure_fifo() {
  local fifo

  fifo=$(workspace_fifo "$1")
  [[ -p "$fifo" ]] || {
    rm -f "$fifo"
    mkfifo "$fifo" 2>/dev/null || [[ -p "$fifo" ]]
  }
}

stream_workspace() {
  local workspace=$1 fifo output

  ensure_fifo "$workspace"
  fifo=$(workspace_fifo "$workspace")
  read_workspace "$workspace"

  while true; do
    while IFS= read -r output; do
      printf '%s\n' "$output"
    done < "$fifo"
    sleep 0.1
  done
}

refresh_workspaces() {
  local clients monitors workspace encoded temporary output fd
  local steam_class app_id manifest key value steam_name
  local steam_names='{}'

  clients=$(hyprctl clients -j 2>/dev/null || printf '[]')
  monitors=$(hyprctl monitors -j 2>/dev/null || printf '[]')

  while IFS= read -r steam_class; do
    app_id=${steam_class#steam_app_}
    manifest="${HOME}/.local/share/Steam/steamapps/appmanifest_${app_id}.acf"
    steam_name=""
    if [[ -r $manifest ]]; then
      while read -r key value; do
        if [[ $key == '"name"' ]]; then
          steam_name=${value#\"}
          steam_name=${steam_name%\"}
          break
        fi
      done < "$manifest"
    fi
    if [[ -n $steam_name ]]; then
      steam_names=$(jq -cn \
        --argjson names "$steam_names" \
        --arg class "$steam_class" \
        --arg name "$steam_name" \
        '$names + {($class): $name}')
    fi
  done < <(jq -r '[.[] | .class | select(test("^steam_app_[0-9]+$"))] | unique[]' <<< "$clients")

  while IFS=$'\t' read -r workspace encoded; do
    output=$(printf '%s' "$encoded" | base64 -d)
    temporary="$cache_dir/$workspace.json.tmp"
    printf '%s\n' "$output" > "$temporary"
    mv "$temporary" "$cache_dir/$workspace.json"
    fd=${workspace_fds[$workspace]}
    printf '%s\n' "$output" >&"$fd"
  done < <(
    jq -nr \
      --argjson clients "$clients" \
      --argjson monitors "$monitors" \
      --argjson steamNames "$steam_names" \
      --arg middle "$middle_monitor" \
      --arg right "$right_monitor" '
          def app_name:
            .class as $class
            | if $class == "Alacritty" then "alacritty"
            elif $class == "google-chrome" then "Chrome"
            elif $class == "org.mozilla.Thunderbird" then "Thunderbird"
            elif $class == "md.obsidian.Obsidian" then "Obsidian"
            elif ($class | test("^steam_app_[0-9]+$")) then
              ($steamNames[$class] // (if .title == "" then $class else .title end))
            elif ($class | test("^(org|com|net|io|dev|md)\\.")) then
              ($class | split(".") | last)
            else $class
            end;

          def active_workspace($monitor):
            first($monitors[] | select(.description == $monitor) | .activeWorkspace.id) // 0;

          def active_workspace_name($monitor):
            first($monitors[] | select(.description == $monitor) | .activeWorkspace.name) // "";

          (
            range(1; 11) as $workspace
            | [
              $clients[]
              | select(.workspace.id == $workspace)
              | app_name
            ]
            | unique
            | join(", ") as $applications
          | ($workspace <= 3) as $is_middle
          | (if $is_middle then $middle else $right end) as $monitor
          | (active_workspace($monitor) == $workspace) as $active
          | (if $applications == "" then "empty" else "occupied" end) as $state
          | {
              text: (
                if $is_middle then
                  if $applications == "" then "○" else $applications end
                else
                  if $applications == "" then ($workspace | tostring)
                  else "\($workspace) \($applications)"
                  end
                end
              ),
              tooltip: "\(if $is_middle then "Middle" else "Right" end) monitor workspace \($workspace)",
              class: (if $active then ["active", $state] else [$state] end)
            } as $output
            | "\($workspace)\t\($output | @base64)"
          ),
          (
            [
              $clients[]
              | select(.workspace.name == "games")
              | app_name
            ]
            | unique
            | join(", ") as $applications
          | (active_workspace_name($middle) == "games") as $active
          | {
              text: (
                if $applications == "" and ($active | not) then ""
                elif $applications == "" then "games"
                else $applications
                end
              ),
              tooltip: "Steam game workspace on the left monitor",
              class: (
                if $applications == "" and ($active | not) then ["hidden"]
                elif $active and $applications == "" then ["active", "empty", "game"]
                elif $active then ["active", "occupied", "game"]
                else ["occupied", "game"]
                end
              )
            } as $output
            | "games\t\($output | @base64)"
          )
        '
  )
}

watch_workspaces() {
  local workspace fifo fd _event socket
  local -a workspaces=({1..10} games)
  declare -gA workspace_fds

  printf '{"text":""}\n'

  for workspace in "${workspaces[@]}"; do
    ensure_fifo "$workspace"
    fifo=$(workspace_fifo "$workspace")
    exec {fd}<>"$fifo"
    workspace_fds[$workspace]=$fd
  done

  refresh_workspaces
  socket="${XDG_RUNTIME_DIR:?}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:?}/.socket2.sock"

  while true; do
    while IFS= read -r _event; do
      refresh_workspaces
    done < <(
      perl -MIO::Select -MIO::Socket::UNIX -MSocket=SOCK_STREAM -e '
        $| = 1;
        $socket = IO::Socket::UNIX->new(Type => SOCK_STREAM, Peer => $ARGV[0]) or exit 1;
        $select = IO::Select->new($socket);
        while (1) {
          if ($select->can_read(5)) {
            $line = <$socket>;
            last unless defined $line;
            print $line if $line =~ /^(workspace|workspacev2|focusedmon|openwindow|closewindow|movewindow|movewindowv2|monitoradded|monitorremoved)>>/;
          } else {
            print "refresh>>\n";
          }
        }
      ' "$socket"
    )
    sleep 1
  done
}

case "${1:-}" in
  read) read_workspace "${2:?workspace is required}" ;;
  stream) stream_workspace "${2:?workspace is required}" ;;
  watch) watch_workspaces ;;
  *) exit 1 ;;
esac
