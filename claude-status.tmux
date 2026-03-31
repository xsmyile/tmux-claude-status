#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"

status_command="#($CURRENT_DIR/scripts/status.sh)"

# Cache user options in tmux environment so status.sh avoids per-poll lookups
tmux set-environment -g TMUX_CLAUDE_STATUS_COLOR_WORKING "$(get_tmux_option "@claude-status-color-working" "#a6da95")"
tmux set-environment -g TMUX_CLAUDE_STATUS_COLOR_IDLE "$(get_tmux_option "@claude-status-color-idle" "#eed49f")"
tmux set-environment -g TMUX_CLAUDE_STATUS_COLOR_TEXT "$(get_tmux_option "@claude-status-color-text" "#cad3f5")"
tmux set-environment -g TMUX_CLAUDE_STATUS_ICON "$(get_tmux_option "@claude-status-icon" "󰯉 ")"

interpolate() {
    local option="$1"
    local value
    value=$(tmux show-option -gqv "$option")
    if printf '%s' "$value" | grep -qF '#{claude_status}'; then
        local new_value
        new_value=$(printf '%s' "$value" | sed "s|#{claude_status}|${status_command}|g")
        tmux set-option -gq "$option" "$new_value"
        return 0
    fi
    return 1
}

# Try placeholder interpolation in status-right and status-left
interpolated=0
interpolate "status-right" && interpolated=1
interpolate "status-left" && interpolated=1

# Fallback: append to status-right if no placeholder was found
if [ "$interpolated" -eq 0 ]; then
    current_status_right=$(tmux show-option -gqv status-right)
    if ! printf '%s' "$current_status_right" | grep -qF "tmux-claude-status/scripts/status.sh"; then
        tmux set-option -ag status-right " $status_command"
    fi
fi

# Clean up stale status files when sessions close
tmux set-hook -g session-closed "run-shell '$CURRENT_DIR/scripts/cleanup.sh'"

# Bind key to open sessions overview popup
popup_key=$(get_tmux_option "@claude-status-popup-key" "C")
tmux bind-key "$popup_key" display-popup -E -w 50 -h 15 -T " Claude Status " "$CURRENT_DIR/scripts/popup.sh"
