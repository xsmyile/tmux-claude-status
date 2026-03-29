#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"

color_working=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_WORKING 2>/dev/null | cut -d= -f2-)
color_idle=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_IDLE 2>/dev/null | cut -d= -f2-)
color_text=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_TEXT 2>/dev/null | cut -d= -f2-)
icon=$(tmux show-environment -g TMUX_CLAUDE_STATUS_ICON 2>/dev/null | cut -d= -f2-)

[ -z "$color_working" ] && color_working="#a6da95"
[ -z "$color_idle" ] && color_idle="#eed49f"
[ -z "$color_text" ] && color_text="#cad3f5"
[ -z "$icon" ] && icon="󰯉 "

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
