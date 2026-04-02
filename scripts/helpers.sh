#!/usr/bin/env bash

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

get_claude_panes() {
    local pane_info claude_parents
    pane_info=$(tmux list-panes -a -F '#{pane_pid} #{pane_id}' 2>/dev/null) || pane_info=""
    claude_parents=$(ps -eo ppid,comm,args 2>/dev/null | awk '
        $2 == "claude" { gsub(/^ +/, "", $1); print $1; next }
        $2 == "node" && /claude-code/ { gsub(/^ +/, "", $1); print $1 }
    ' | sort -u) || claude_parents=""

    [ -z "$claude_parents" ] && return

    while read -r pane_pid pane_id; do
        grep -qFx "$pane_pid" <<< "$claude_parents" && echo "$pane_id"
    done <<< "$pane_info" || true
}
