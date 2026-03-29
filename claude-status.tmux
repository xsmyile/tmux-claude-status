#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"

# Ensure status bar refreshes every 2 seconds
interval=$(get_tmux_option "status-interval" "15")
if [ "$interval" -gt 2 ] 2>/dev/null; then
    tmux set-option -g status-interval 2
fi

# Append to status-right if not already present
current_status_right=$(tmux show-option -gqv status-right)
if ! printf '%s' "$current_status_right" | grep -qF "tmux-claude-status/scripts/status.sh"; then
    tmux set-option -ag status-right " #($CURRENT_DIR/scripts/status.sh)"
fi
