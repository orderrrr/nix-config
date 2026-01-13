# Neovim Multiplexer

A minimal neovim config for using neovim as a terminal multiplexer.

## Usage

```bash
nvim -u ~/.config/nix/dotfiles/config/nvim/multiplexer/init.lua
```

Or create an alias:

```bash
alias mux='nvim -u ~/.config/nix/dotfiles/config/nvim/multiplexer/init.lua'
```

## Concepts

- **Session**: A tab containing one or more terminal splits. Each session has a name (random 4-letter string by default) and its own color.
- **Pane**: A split within a session containing a terminal.

New sessions and panes start in terminal mode. Use `Alt+Esc` to exit to normal mode for copying text.

## Statusline

The global statusline shows:
```
 TRM  [abcd]  efgh  ijkl                    ~/projects/myapp zsh
```

- 3-letter mode indicator with colored background (NOR, INS, TRM, VIS, CMD, REP)
- All sessions with unique colors, active one in brackets and bold
- Right side: current working directory and running process of active terminal
- Command line is hidden until needed (`cmdheight=0`)

## Keybinds

All keybinds use `Alt` and work in both normal and terminal mode.

Press `Alt+/` to show the help window.

### Navigation

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Move between panes |
| `Alt+h/l` | Wrap to prev/next session at edge |
| `Alt+[` | Previous session |
| `Alt+]` | Next session |
| `Alt+s` | Session picker (telescope) |
| `Alt+Esc` | Exit terminal mode |

### Panes

| Key | Action |
|-----|--------|
| `Alt+n` | New vertical pane |
| `Alt+N` | New horizontal pane |
| `Alt+x` | Close pane (quits if last) |

### Resize

| Key | Action |
|-----|--------|
| `Alt+H` | Shrink width |
| `Alt+L` | Grow width |
| `Alt+J` | Shrink height |
| `Alt+K` | Grow height |

### Sessions

| Key | Action |
|-----|--------|
| `Alt+c` | New session |
| `Alt+r` | Rename session |
| `Alt+X` | Close session |

### Help

| Key | Action |
|-----|--------|
| `Alt+/` | Show keybind help |

## Commands

| Command | Description |
|---------|-------------|
| `:SessionName <name>` | Rename current session |

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [kanagawa-paper.nvim](https://github.com/thesimonho/kanagawa-paper.nvim)
