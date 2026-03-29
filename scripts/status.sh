#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

STATUS_DIR="$HOME/.cache/tmux-claude-status"

color_working=$(get_tmux_option "@claude-status-color-working" "#a6da95")
color_idle=$(get_tmux_option "@claude-status-color-idle" "#eed49f")
color_text=$(get_tmux_option "@claude-status-color-text" "#cad3f5")
icon=$(get_tmux_option "@claude-status-icon" "󰯉 ")

total=0
working=0

while IFS=$'\t' read -r pane_id pane_cmd; do
    [[ "$pane_cmd" == "claude" ]] || continue
    ((total++)) || true

    status_file="$STATUS_DIR/${pane_id}.status"
    if [ -f "$status_file" ] && [[ "$(cat "$status_file" 2>/dev/null)" == "working" ]]; then
        ((working++)) || true
    fi
done < <(tmux list-panes -a -F "#{pane_id}	#{pane_current_command}" 2>/dev/null)

[ "$total" -eq 0 ] && exit 0

idle=$((total - working))

echo "${icon}#[fg=${color_working}]${working}#[fg=${color_text}] working #[fg=${color_idle}]${idle}#[fg=${color_text}] idle"
