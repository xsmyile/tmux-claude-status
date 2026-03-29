# tmux-claude-status

Show live [Claude Code](https://docs.anthropic.com/en/docs/claude-code) activity in your tmux status bar. See at a glance how many instances are working vs idle across all panes.

## Install

Requires [TPM](https://github.com/tmux-plugins/tpm).

Add to `~/.config/tmux/tmux.conf` (or `~/.tmux.conf`):

```tmux
set -g @plugin 'xsmyile/tmux-claude-status'
```

Then press `prefix + I` to install.

## Setup

The plugin tracks Claude Code activity via [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks). Add this to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/tmux/plugins/tmux-claude-status/scripts/hook.sh UserPromptSubmit"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/tmux/plugins/tmux-claude-status/scripts/hook.sh PreToolUse"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/tmux/plugins/tmux-claude-status/scripts/hook.sh Stop"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/tmux/plugins/tmux-claude-status/scripts/hook.sh Notification"
          }
        ]
      }
    ]
  }
}
```

## How it works

```
Claude Code hooks          Status files              tmux status bar
┌──────────────┐   write   ┌────────────────────┐   read   ┌──────────┐
│ UserPrompt   ├──────────>│ ~/.cache/           ├────────>│ 2 working│
│ PreToolUse   │           │ tmux-claude-status/ │         │ 1 idle   │
│ Stop         │           │ %42.status          │         └──────────┘
│ Notification │           └────────────────────┘
└──────────────┘
```

1. Claude Code fires hook events as it works
2. `hook.sh` writes `working` or `idle` to a per-pane status file
3. `status.sh` counts Claude panes and their states, renders to the status bar
4. Stale status files are cleaned up automatically when panes close

## Options

All options are optional. Set them in `tmux.conf` **before** the TPM `run` line.

```tmux
# Colors (any tmux-compatible color: hex, name, or terminal color number)
set -g @claude-status-color-working "#a6da95"   # green (default)
set -g @claude-status-color-idle    "#eed49f"   # yellow (default)
set -g @claude-status-color-text    "#cad3f5"   # foreground (default)

# Icon shown before the status (Nerd Font icon, emoji, or text)
set -g @claude-status-icon "󰯉 "
```

The defaults use [Catppuccin Macchiato](https://catppuccin.com/) colors but work on any theme.

## Requirements

- tmux 3.0+
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- A terminal with true color support (for hex colors)

## License

MIT
