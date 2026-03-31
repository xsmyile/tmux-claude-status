#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"

GREEN="\033[32m"
YELLOW="\033[33m"
ORANGE="\033[38;5;208m"
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"

working_lines=()
waiting_lines=()
idle_lines=()

working_count=0
waiting_count=0
idle_count=0

declare -A pane_paths
while IFS=$'\t' read -r pane_id pane_path; do
    pane_paths["$pane_id"]="$pane_path"
done < <(tmux list-panes -a -F "#{pane_id}	#{pane_current_path}" 2>/dev/null)

for status_file in "$STATUS_DIR"/*.status; do
    [ -f "$status_file" ] || continue

    filename=$(basename "$status_file")
    pane_id="${filename%.status}"

    [ -n "${pane_paths[$pane_id]+x}" ] || continue

    status=$(cat "$status_file" 2>/dev/null)
    [ -n "$status" ] || status="idle"

    path="${pane_paths[$pane_id]}"
    path="${path/#$HOME/\~}"

    line=$(printf "  %-5s %-30s %s" "$pane_id" "$path" "$status")

    case "$status" in
        working)
            working_lines+=("$(printf "  ${GREEN}●${RESET} ${line}")")
            ((working_count++)) || true
            ;;
        waiting)
            waiting_lines+=("$(printf "  ${ORANGE}◉${RESET} ${line}")")
            ((waiting_count++)) || true
            ;;
        *)
            idle_lines+=("$(printf "  ${YELLOW}○${RESET} ${line}")")
            ((idle_count++)) || true
            ;;
    esac
done

echo ""
printf "  ${BOLD}Claude Code Sessions${RESET}\n"
printf "  ${DIM}────────────────────────────────────────${RESET}\n"
echo ""

total=$((working_count + waiting_count + idle_count))

if [ "$total" -eq 0 ]; then
    printf "  No active Claude sessions\n"
    echo ""
    exit 0
fi

for line in "${working_lines[@]}"; do
    printf '%b\n' "$line"
done
for line in "${waiting_lines[@]}"; do
    printf '%b\n' "$line"
done
for line in "${idle_lines[@]}"; do
    printf '%b\n' "$line"
done

echo ""
summary="  $total sessions:"
parts=()
[ "$working_count" -gt 0 ] && parts+=("$working_count working")
[ "$waiting_count" -gt 0 ] && parts+=("$waiting_count waiting")
[ "$idle_count" -gt 0 ] && parts+=("$idle_count idle")

first=1
for part in "${parts[@]}"; do
    if [ "$first" -eq 1 ]; then
        summary="$summary $part"
        first=0
    else
        summary="$summary · $part"
    fi
done

printf "  ${DIM}%s${RESET}\n" "$summary"
echo ""
