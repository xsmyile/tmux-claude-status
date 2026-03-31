#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATUS_DIR="$HOME/.cache/tmux-claude-status"

# Count active Claude panes for exact popup height
count=0
pane_info=$(tmux list-panes -a -F "#{pane_id}	#{pane_current_command}" 2>/dev/null)
for status_file in "$STATUS_DIR"/*.status; do
    [ -f "$status_file" ] || continue
    pane_id="$(basename "$status_file" .status)"
    echo "$pane_info" | grep -qF "${pane_id}	claude" && count=$((count + 1))
done

# Content: gap(1) + sessions(N) + gap(1) + summary(1) + gap(1) + footer(1) = N + 5
# Empty: gap(1) + message(1) + gap(1) + footer(1) = 4
# +3 for borders (top with title takes extra row) + bottom
if [ "$count" -gt 0 ]; then
    height=$((count + 8))
else
    height=7
fi

# Border style
border_flag=""
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_POPUP_BORDER 2>/dev/null) && {
    border="${raw#*=}"
    [ -n "$border" ] && border_flag="-b $border"
}

# shellcheck disable=SC2086
exec tmux display-popup -E -w 60 -h "$height" $border_flag \
    -T " Claude Status " "$SCRIPT_DIR/popup.sh"
