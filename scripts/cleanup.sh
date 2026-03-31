#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"
[ -d "$STATUS_DIR" ] || exit 0

existing_panes=$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null) || existing_panes=""

for f in "$STATUS_DIR"/*.status; do
    [ -f "$f" ] || continue
    pid=$(basename "$f" .status)
    if ! grep -qFx "$pid" <<< "$existing_panes"; then
        rm -f "$f"
    fi
done
