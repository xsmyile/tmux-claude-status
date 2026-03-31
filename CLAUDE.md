# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A zero-dependency tmux plugin (TPM-compatible) that displays live Claude Code session activity in the tmux status bar. It tracks working/waiting/idle states across all panes using Claude Code hooks and per-pane status files stored in `~/.cache/tmux-claude-status/`.

## Architecture

The plugin has two data paths that never share code:

1. **Hook path** (write): Claude Code fires hook events → `scripts/hook.sh` writes a state (`working`, `waiting`, `idle`) to `~/.cache/tmux-claude-status/%<pane_id>.status`
2. **Display path** (read): tmux polls `scripts/status.sh` every `status-interval` seconds → it scans status files, counts states, and emits tmux-formatted output with `#[fg=...]` color codes

Entry point is `claude-status.tmux` which:
- Caches user options into tmux environment variables (avoids per-poll `show-option` calls)
- Interpolates `#{claude_status}` placeholder in status-left/status-right, or appends to status-right as fallback
- Registers `session-closed` hook for cleanup and binds the popup key

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/hook.sh` | Called by Claude Code hooks; writes per-pane status files. Parses `Notification` JSON for `permission_prompt` (→ waiting) and `idle_prompt` (→ idle) |
| `scripts/status.sh` | Polled by tmux; reads status files and outputs formatted status string |
| `scripts/cleanup.sh` | Removes status files for panes that no longer exist |
| `scripts/popup.sh` | Renders the sessions overview popup (ANSI-colored, sorted by status) |
| `scripts/popup-open.sh` | Calculates dynamic popup height and launches `tmux display-popup` |
| `scripts/helpers.sh` | Single helper: `get_tmux_option` with default fallback |

## Development

There is no build step, test suite, or linter configured. All scripts are plain Bash.

### Testing locally

1. Symlink or clone to `~/.config/tmux/plugins/tmux-claude-status`
2. Add the hook configuration from README to `~/.claude/settings.json`
3. Run `tmux source ~/.config/tmux/tmux.conf` to reload
4. Verify with: `cat ~/.cache/tmux-claude-status/*.status`

### Shell conventions

- All scripts use `#!/usr/bin/env bash` with `set -euo pipefail`
- `hook.sh` must always drain stdin (`cat > /dev/null`) on non-Notification events — Claude Code hooks pipe JSON via stdin and will block if it's not consumed
- Status detection relies on `pane_current_command` equaling `"claude"` exactly
- Colors in `status.sh` use tmux `#[fg=...]` format; colors in `popup.sh` use ANSI escape codes
