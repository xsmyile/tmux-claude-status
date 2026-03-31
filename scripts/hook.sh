#!/usr/bin/env bash

# Claude Code hook — writes working/idle/waiting status per tmux pane.
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
    Stop)
        echo "idle" > "$STATUS_DIR/${PANE_ID}.status"
        ;;
    Notification)
        echo "waiting" > "$STATUS_DIR/${PANE_ID}.status"
        ;;
esac

exit 0
