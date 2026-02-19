status is-interactive; or return

# ============================================================================
# Environment Variables & Settings
# ============================================================================

# NVM
set -U nvm_default_version v22.21.1

set NVIM_MODE "dev"

# Common paths (both OS)
set -l common_paths \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/.local/share/cargo/bin \
    ~/.bin/nvim/bin/ \
    ~/.bin \
    ~/.bin/slang/bin \
    /run/current-system/sw/bin \
    /usr/local/bin

for p in $common_paths
    test -d $p; and fish_add_path --move --path $p
end

# Load OS-specific config
source ~/.config/fish/os.fish

# Fish settings
set -g fish_greeting ""
set -g fish_key_bindings fish_vi_key_bindings

# Core environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS "-RFX"
set -gx GPG_TTY (tty)

# FZF
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Man pages
set -gx MANPAGER 'sh -c "col -bx | bat -l man -p"'

# ============================================================================
# Shell Integrations
# ============================================================================

direnv hook fish | source
starship init fish | source
zoxide init fish | source
fzf_configure_bindings --directory=\ct --history=\cr --variables=\cv --git_status=\cg

# Load custom functions
source ~/.config/fish/functions/archives.fish

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

# ============================================================================
# Aliases
# ============================================================================

alias e="$EDITOR"
alias cb="nvm_default_version=v22.21.1 clawdbot"

# ============================================================================
# Functions
# ============================================================================

function ls --description 'ls via lsd'
    lsd --group-directories-first --icon=auto $argv
end

function ll --description 'long ls via lsd'
    lsd -lAh --group-directories-first --icon=auto $argv
end

function lt --description 'tree via lsd'
    lsd --tree --icon=auto $argv
end

function cat --description 'cat via bat'
    bat --paging=never $argv
end

function f --description 'Fuzzy find and edit file'
    set -l search_path (test -n "$argv[1]"; and echo $argv[1]; or echo .)
    set -l file (fd --type f --hidden --exclude .git . $search_path 2>/dev/null | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    and commandline -r "$EDITOR $file"
end

function please --description "Repeat last command with sudo"
    set -l last (history --max 1)
    test -n "$last"; and eval command sudo $last
end

if type -q rg
    function rga --description "rg -uu --hidden (ignores .git)"
        rg -uu --hidden --glob '!.git' $argv
    end
end

function t --description 'Launch multiplexer'
  NVIM_MODE="multiplexer" nvim
end

function ssh --description 'SSH with xterm-256color support'
    TERM=xterm-256color command ssh $argv
end

# ============================================================================
# Keybindings
# ============================================================================

# Ctrl+O: Open whatever is on the command line in nvim (read-only).
# Designed to pair with Ghostty's Cmd+Shift+S (write_scrollback_file:paste),
# which pastes a scrollback temp-file path onto the command line.
# Workflow: Cmd+Shift+S → Ctrl+O → scrollback opens in nvim for searching.
function __open_cmdline_in_nvim
    set -l buf (string trim (commandline -b))
    test -z "$buf"; and return
    set -l prev_cmd (commandline -b)
    commandline -r ""
    commandline -f repaint
    nvim -R $buf
    commandline -r ""
    commandline -f repaint
end
bind -M insert \co __open_cmdline_in_nvim
bind -M default \co __open_cmdline_in_nvim

alias ss=rsh
alias oo=opencode
alias co=claude