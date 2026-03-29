#!/usr/bin/env bash

STATUS_DIR="$HOME/.cache/tmux-claude-status"
[ -d "$STATUS_DIR" ] || exit 0

existing_panes=$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null)

for f in "$STATUS_DIR"/*.status; do
    [ -f "$f" ] || continue
    pid=$(basename "$f" .status)
    echo "$existing_panes" | grep -qx "$pid" || rm -f "$f"
done
