#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

hooks_ok=""
raw=$(tmux show-environment -g TMUX_CLAUDE_STATUS_HOOKS_OK 2>/dev/null) && hooks_ok="${raw#*=}"

# Count active Claude panes for exact popup height
count=0
while IFS=$'\t' read -r _ pane_cmd; do
    [ "$pane_cmd" = "claude" ] && count=$((count + 1))
done < <(tmux list-panes -a -F "#{pane_id}	#{pane_current_command}" 2>/dev/null)

# Content: gap(1) + sessions(N) + gap(1) + summary(1) + gap(1) + footer(1) = N + 5
# Empty: gap(1) + message(1) + gap(1) + footer(1) = 4
# +3 for popup borders
if [ "$count" -gt 0 ]; then
    height=$((count + 8))
    # Add space for hooks warning
    if [ "$hooks_ok" != "1" ]; then
        height=$((height + 3))
    fi
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
