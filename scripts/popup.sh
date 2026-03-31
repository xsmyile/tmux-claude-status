#!/usr/bin/env bash

set -euo pipefail

STATUS_DIR="$HOME/.cache/tmux-claude-status"

GREEN='\033[32m'
YELLOW='\033[33m'
ORANGE='\033[38;5;208m'
DIM='\033[2m'
RESET='\033[0m'

pane_info=$(tmux list-panes -a -F "#{pane_id}	#{pane_current_path}	#{pane_current_command}" 2>/dev/null)

working_out=""
waiting_out=""
idle_out=""
working_count=0
waiting_count=0
idle_count=0

for status_file in "$STATUS_DIR"/*.status; do
    [ -f "$status_file" ] || continue

    pane_id="$(basename "$status_file" .status)"

    pane_line=$(echo "$pane_info" | grep -F "${pane_id}	" | head -1)
    [ -n "$pane_line" ] || continue

    pane_cmd=$(echo "$pane_line" | cut -f3)
    [ "$pane_cmd" = "claude" ] || continue

    status=$(<"$status_file") || status="idle"
    [ -n "$status" ] || status="idle"

    path=$(echo "$pane_line" | cut -f2)
    path="${path/#$HOME/\~}"

    max_path=34
    if [ "${#path}" -gt "$max_path" ]; then
        trim=$((${#path} - max_path + 2))
        path="..${path:$trim}"
    fi

    line=$(printf "%-4s %-${max_path}s %7s" "$pane_id" "$path" "$status")

    case "$status" in
        working)
            working_out="${working_out}  ${GREEN}●${RESET} ${line}\n"
            working_count=$((working_count + 1))
            ;;
        waiting)
            waiting_out="${waiting_out}  ${ORANGE}◉${RESET} ${line}\n"
            waiting_count=$((waiting_count + 1))
            ;;
        *)
            idle_out="${idle_out}  ${YELLOW}○${RESET} ${line}\n"
            idle_count=$((idle_count + 1))
            ;;
    esac
done

total=$((working_count + waiting_count + idle_count))

echo ""
if [ "$total" -eq 0 ]; then
    printf "  No active Claude sessions\n"
else
    [ -n "$working_out" ] && printf '%b' "$working_out"
    [ -n "$waiting_out" ] && printf '%b' "$waiting_out"
    [ -n "$idle_out" ] && printf '%b' "$idle_out"
    echo ""
    summary="  $total sessions:"
    sep=""
    [ "$working_count" -gt 0 ] && summary="$summary $working_count working" && sep=" · "
    [ "$waiting_count" -gt 0 ] && summary="${summary}${sep}$waiting_count waiting" && sep=" · "
    [ "$idle_count" -gt 0 ] && summary="${summary}${sep}$idle_count idle"
    printf '  %b%s%b\n' "$DIM" "$summary" "$RESET"
fi
echo ""
printf '  %bPress q or Esc to close%b\n' "$DIM" "$RESET"
read -rsn1
