#!/usr/bin/env bash

# Claude Code hook — writes working/idle status per tmux pane.
#
# Wire this into ~/.claude/settings.json (see README).
# Called as: hook.sh <event_name>
#   Events: UserPromptSubmit, PreToolUse, Stop, Notification

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"
mkdir -p "$STATUS_DIR"

# Drain stdin (Claude Code pipes hook context via stdin)
cat > /dev/null

# Skip if not inside tmux
[ -z "${TMUX:-}" ] && exit 0

PANE_ID=$(tmux display-message -p '#{pane_id}' 2>/dev/null)
[ -z "$PANE_ID" ] && exit 0

case "${1:-}" in
    UserPromptSubmit|PreToolUse)
        echo "working" > "$STATUS_DIR/${PANE_ID}.status"
        ;;
    Stop|Notification)
        echo "idle" > "$STATUS_DIR/${PANE_ID}.status"
        # Clean up stale status files for panes that no longer exist
        existing_panes=$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null)
        for f in "$STATUS_DIR"/*.status; do
            [ -f "$f" ] || continue
            pid=$(basename "$f" .status)
            echo "$existing_panes" | grep -qx "$pid" || rm -f "$f"
        done
        ;;
esac

exit 0
