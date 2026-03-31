#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"

hooks_ok=""
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_HOOKS_OK 2>/dev/null) && hooks_ok="${raw#*=}"

color_working="" color_waiting="" color_idle="" color_text="" icon=""
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_WORKING 2>/dev/null) && color_working="${raw#*=}"
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_WAITING 2>/dev/null) && color_waiting="${raw#*=}"
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_IDLE 2>/dev/null) && color_idle="${raw#*=}"
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_COLOR_TEXT 2>/dev/null) && color_text="${raw#*=}"
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_ICON 2>/dev/null) && icon="${raw#*=}"

[ -z "$color_working" ] && color_working="#a6da95"
[ -z "$color_waiting" ] && color_waiting="#f5a97f"
[ -z "$color_idle" ] && color_idle="#eed49f"
[ -z "$color_text" ] && color_text="#cad3f5"
[ -z "$icon" ] && icon="󰯉 "

total=0
working=0
waiting=0

while IFS=$'\t' read -r pane_id pane_cmd; do
    [ "$pane_cmd" = "claude" ] || continue
    total=$((total + 1))

    status_file="$STATUS_DIR/${pane_id}.status"
    if [ -f "$status_file" ]; then
        pane_status=$(<"$status_file")
        if [ "$pane_status" = "working" ]; then
            working=$((working + 1))
        elif [ "$pane_status" = "waiting" ]; then
            waiting=$((waiting + 1))
        fi
    fi
done < <(tmux list-panes -a -F "#{pane_id}	#{pane_current_command}" 2>/dev/null)

if [ "$hooks_ok" != "1" ] && [ "$total" -gt 0 ]; then
    echo "${icon}#[fg=${color_waiting}]⚠ hooks not configured"
    exit 0
fi

idle=$((total - working - waiting))

echo "${icon}#[fg=${color_working}]${working}#[fg=${color_text}] working #[fg=${color_waiting}]${waiting}#[fg=${color_text}] waiting #[fg=${color_idle}]${idle}#[fg=${color_text}] idle"
