status is-interactive; or return

# ============================================================================
# Environment Variables & Settings
# ============================================================================

# NVM
set -U nvm_default_version v22.21.1

set -l paths \
    /opt/homebrew/sbin \
    /opt/homebrew/bin \
    /run/current-system/sw/bin \
    /usr/local/bin \
    ~/.cargo/bin \
    ~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin \
    ~/.local/share/cargo/bin \
    ~/.local/bin \
    ~/.bin/nvim/bin/ \
    ~/.bin \
    ~/.bin/slang/bin \
    ~/Library/Android/Sdk/emulator \
    ~/Library/Android/Sdk/platform-tools \
    ~/.sdk/flutter/bin \
    ~/.zvm/bin \
    ~/.zvm/self \
    /opt/homebrew/anaconda3/bin \
    /opt/homebrew/anaconda3/envs/myenv/bin

for p in $paths
    test -d $p; and fish_add_path --move --path $p
end

# Fish settings
set -g fish_greeting ""
set -g fish_key_bindings fish_vi_key_bindings

# Core environment
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS "-RFX"
set -gx GPG_TTY (tty)

# Browser
test (uname) = "Darwin"; and set -gx BROWSER open; or set -gx BROWSER xdg-open

# Android SDK
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools

# Vulkan
set -gx VK_ICD_FILENAMES /opt/homebrew/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json

# FZF
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Man pages
set -gx MANPAGER 'sh -c "col -bx | bat -l man -p"'

# ============================================================================
# Shell Integrations
# ============================================================================

# >>> conda initialize >>>
# Lazy-load conda to speed up shell startup
set -gx CONDA_EXE /Users/nmcintosh/.anaconda3/bin/conda
set -gx CONDA_PREFIX /Users/nmcintosh/.anaconda3

function conda --description 'Lazy-load conda on first use'
    functions -e conda  # Remove this function
    eval $CONDA_EXE "shell.fish" "hook" $argv | source
    conda $argv  # Run the actual conda command
end
# <<< conda initialize <<<

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
alias hms="sudo darwin-rebuild switch --flake ~/.config/nix"
alias hh="sudo darwin-rebuild switch --flake ~/.config/nix --fast"
alias j8="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
alias j17="JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"
alias j21="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
alias j24="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home"
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

function vk --description 'Run command with Vulkan/MoltenVK environment'
    set -lx VK_ICD_FILENAMES /opt/homebrew/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json
    set -lx DYLD_FALLBACK_LIBRARY_PATH /opt/homebrew/opt/vulkan-loader/lib /opt/homebrew/opt/molten-vk/lib
    set -lx MTL_HUD_ENABLED 1
    $argv
end

alias ss=rsh
alias oo=opencode
alias cc=claude
