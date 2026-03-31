#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"

color_working=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_WORKING 2>/dev/null | cut -d= -f2-)
color_waiting=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_WAITING 2>/dev/null | cut -d= -f2-)
color_idle=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_IDLE 2>/dev/null | cut -d= -f2-)
color_text=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_TEXT 2>/dev/null | cut -d= -f2-)
icon=$(tmux show-environment -g TMUX_CLAUDE_STATUS_ICON 2>/dev/null | cut -d= -f2-)

[ -z "$color_working" ] && color_working="#a6da95"
[ -z "$color_waiting" ] && color_waiting="#f5a97f"
[ -z "$color_idle" ] && color_idle="#eed49f"
[ -z "$color_text" ] && color_text="#cad3f5"
[ -z "$icon" ] && icon="󰯉 "

total=0
working=0
waiting=0

while IFS=$'\t' read -r pane_id pane_cmd; do
    [[ "$pane_cmd" == "claude" ]] || continue
    ((total++)) || true

    status_file="$STATUS_DIR/${pane_id}.status"
    if [ -f "$status_file" ]; then
        pane_status=$(cat "$status_file" 2>/dev/null)
        if [[ "$pane_status" == "working" ]]; then
            ((working++)) || true
        elif [[ "$pane_status" == "waiting" ]]; then
            ((waiting++)) || true
        fi
    fi
done < <(tmux list-panes -a -F "#{pane_id}	#{pane_current_command}" 2>/dev/null)

idle=$((total - working - waiting))

echo "${icon}#[fg=${color_working}]${working}#[fg=${color_text}] working #[fg=${color_waiting}]${waiting}#[fg=${color_text}] waiting #[fg=${color_idle}]${idle}#[fg=${color_text}] idle"
