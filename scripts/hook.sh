#!/usr/bin/env bash

# Claude Code hook — writes working/idle/waiting status per tmux pane.
#
# Wire this into ~/.claude/settings.json (see README).
# Called as: hook.sh <event_name>
#   Events: UserPromptSubmit, PreToolUse, Stop, Notification

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"
if [ ! -d "$STATUS_DIR" ]; then
    mkdir -p "$STATUS_DIR"
    chmod 700 "$STATUS_DIR"
fi

# Skip if not inside tmux
[ -z "${TMUX:-}" ] && { cat > /dev/null; exit 0; }

PANE_ID=$(tmux display-message -p '#{pane_id}' 2>/dev/null) || { cat > /dev/null; exit 0; }
[ -z "$PANE_ID" ] && { cat > /dev/null; exit 0; }

case "${1:-}" in
    UserPromptSubmit|PreToolUse)
        cat > /dev/null
        echo "working" > "$STATUS_DIR/${PANE_ID}.status"
        ;;
    Stop)
        cat > /dev/null
        echo "idle" > "$STATUS_DIR/${PANE_ID}.status"
        ;;
    Notification)
        input=$(cat)
        ntype=$(jq -r '.notification_type // empty' <<< "$input" 2>/dev/null) ||
            ntype=$(grep -o '"notification_type" *: *"[^"]*"' <<< "$input" | head -1 | cut -d'"' -f4)
        case "$ntype" in
            permission_prompt)
                echo "waiting" > "$STATUS_DIR/${PANE_ID}.status"
                ;;
            idle_prompt)
                echo "idle" > "$STATUS_DIR/${PANE_ID}.status"
                ;;
        esac
        ;;
    *)
        cat > /dev/null
        ;;
esac

exit 0
