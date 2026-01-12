status is-interactive; or return

set --universal nvm_default_version v22.21.1
# set --universal nvm_default_version v20.19.6

set paths \
/opt/homebrew/sbin \
/run/current-system/sw/bin \
/usr/local/bin \
/opt/homebrew/bin \
/opt/homebrew/anaconda3/bin \
~/.local/nvim/bin \
~/Library/Android/Sdk/emulator \
~/Library/Android/Sdk/platform-tools \
~/.bin \
~/.local/bin \
~/.cargo/bin \
~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin \
~/.local/share/cargo/bin \
/opt/homebrew/anaconda3/envs/myenv/bin/ \
~/.sdk/flutter/bin \
~/.cargo/bin \
~/.bin/nvim/bin \
~/.bin/slang/bin

for p in $paths
    fish_add_path --move $p
end

set -gx DYLD_LIBRARY_PATH "/opt/homebrew/lib"
# set -gx VK_LAYER_PATH (brew --prefix)/share/vulkan/explicit_layer.d
# set -gx VK_INSTANCE_LAYERS VK_LAYER_KHRONOS_validation
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
set -gx ANDROID_HOME "/opt/homebrew/share/android-commandlinetools"
set -gx VK_ICD_FILENAMES "/usr/local/share/vulkan/icd.d/MoltenVK_icd.json"

set -g fish_greeting
set -g fish_key_bindings fish_vi_key_bindings

# Core environment
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx PAGER less
set -gx LESS -RFX
set -gx GPG_TTY (tty)

# Open command by OS
switch (uname)
    case Darwin
        set -gx BROWSER open
    case Linux
        set -gx BROWSER xdg-open
end

# Better defaults for fzf (if fd is available)
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

# Pretty man pages via bat (if available)
set -gx MANPAGER 'sh -c "col -bx | bat -l man -p"'

direnv hook fish | source
starship init fish | source
zoxide init fish | source
fzf_configure_bindings --directory=\ct --history=\cr --variables=\cv --git_status=\cg

function ls --description 'ls via eza'
    eza --group-directories-first --git --icons=auto -- $argv
end

function ll --description 'long ls via eza'
    eza -lAh --group-directories-first --git --icons=auto -- $argv
end

function lt --description 'tree via eza'
    eza -T --group-directories-first --icons=auto -- $argv
end

function cat --description 'cat via bat'
    bat --paging=never -- $argv
end

function f
    set -l file (find (test -n "$argv[1]"; and echo $argv[1]; or echo .) -type f ! -path "*/.git/*" 2>/dev/null | fzf)
    and commandline -r "$EDITOR $file"
end

function extract --description "Extract archives: extract <file>"
    set -l file $argv[1]
    if test -z "$file"
        echo "Usage: extract <archive>"
        return 1
    end
    if not test -f "$file"
        echo "Not a file: $file"
        return 1
    end
    switch $file
        case '*.tar.bz2' '*.tbz2'
            tar xjf "$file"
        case '*.tar.gz' '*.tgz'
            tar xzf "$file"
        case '*.tar.xz' '*.txz'
            tar xJf "$file"
        case '*.tar.zst' '*.tzst'
            tar --use-compress-program=unzstd -xvf "$file"
        case '*.tar'
            tar xf "$file"
        case '*.zip'
            unzip -q "$file"
        case '*.rar'
            unrar x "$file"
        case '*.7z'
            7z x "$file"
        case '*'
            echo "Don't know how to extract: $file"
            return 1
    end
end

# compress: create archives by extension
# Usage:
#   compress [-f] [archive.{tar.gz|tar.zst|tar.xz|tar.bz2|tar|zip|7z}] <paths...>
# Examples:
#   compress src dist            # -> src.tar.gz (includes src and dist)
#   compress site.tgz public     # -> site.tgz
#   compress -f app.tar.zst app  # force overwrite
function compress --description "Create archives by extension"
    set -l force 0

    # Parse flags
    while test (count $argv) -gt 0
        switch $argv[1]
            case -f --force
                set force 1
                set -e argv[1]
            case --
                set -e argv[1]
                break
            case '-*'
                echo "Unknown option: $argv[1]"
                echo "Usage: compress [-f] [archive.ext] <paths...>"
                return 2
            case '*'
                break
        end
    end

    if test (count $argv) -lt 1
        echo "Usage: compress [-f] [archive.{tar.gz|tar.zst|tar.xz|tar.bz2|tar|zip|7z}] <paths...>"
        return 1
    end

    # Determine destination and paths
    set -l dest
    set -l paths

    switch $argv[1]
        case '*.tar.gz' '*.tgz' '*.tar.xz' '*.txz' '*.tar.bz2' '*.tbz2' '*.tar.zst' '*.tzst' '*.tar' '*.zip' '*.7z'
            if test (count $argv) -lt 2
                echo "No input paths provided."
                return 1
            end
            set dest $argv[1]
            set paths $argv[2..-1]
        case '*'
            # Default to <first_path>.tar.gz
            set paths $argv
            set -l base (basename $paths[1])
            set dest "$base.tar.gz"
    end

    # Validate inputs
    for p in $paths
        if not test -e "$p"
            echo "Not found: $p"
            return 1
        end
    end

    if test -e "$dest"; and test $force -eq 0
        echo "Refusing to overwrite: $dest (use -f to force)"
        return 1
    end

    # Create archive based on extension
    switch $dest
        case '*.tar.gz' '*.tgz'
            if type -q pigz
                tar --exclude-vcs --use-compress-program=pigz -cf "$dest" -- $paths
            else
                tar -czf "$dest" --exclude-vcs -- $paths
            end
        case '*.tar.xz' '*.txz'
            if type -q pxz
                tar --exclude-vcs --use-compress-program=pxz -cf "$dest" -- $paths
            else if type -q xz
                tar -cJf "$dest" --exclude-vcs -- $paths
            else
                echo "xz not found; install xz or choose a different format."
                return 1
            end
        case '*.tar.bz2' '*.tbz2'
            tar -cjf "$dest" --exclude-vcs -- $paths
        case '*.tar.zst' '*.tzst'
            if type -q zstd
                tar --exclude-vcs --use-compress-program='zstd -T0 -19' -cf "$dest" -- $paths
            else
                echo "zstd not found; install zstd or choose a different format."
                return 1
            end
        case '*.tar'
            tar -cf "$dest" --exclude-vcs -- $paths
        case '*.zip'
            if not type -q zip
                echo "zip not found; install zip or choose a different format."
                return 1
            end
            zip -r -9 "$dest" $paths
        case '*.7z'
            if not type -q 7z
                echo "7z not found; install p7zip/7z or choose a different format."
                return 1
            end
            7z a -mx=9 "$dest" $paths
        case '*'
            echo "Unsupported archive type: $dest"
            return 1
    end

    echo "Created: $dest"
end

function please --description "Repeat last command with sudo"
    set -l last (history | head -n1)
    if test -n "$last"
        eval command sudo $last
    end
end

if type -q rg
    function rga --description "rg -uu --hidden (ignores .git)"
        rg -uu --hidden --glob '!.git' $argv
    end
end

function t
    zellij
end

# function hms
#     sudo nix run nix-darwin -- switch --flake ~/.config/nix
# end

function ssh
    TERM=xterm-256color command ssh $argv
end

alias hms="sudo nix run nix-darwin -- switch --flake ~/.config/nix"
alias j8="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
alias j17="JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"
alias j21="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
alias j24="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home"
alias cb="nvm_default_version=v22.21.1 clawdbot"

alias e="$EDITOR"

function vk
    # Use homebrew's MoltenVK ICD file (relative path resolves from its location)
    set -lx VK_ICD_FILENAMES /opt/homebrew/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json

    # Add Homebrew Vulkan loader to library path so SDL can find it
    set -lx DYLD_FALLBACK_LIBRARY_PATH "/opt/homebrew/opt/vulkan-loader/lib:/opt/homebrew/opt/molten-vk/lib:$DYLD_FALLBACK_LIBRARY_PATH"

    # Metal HUD
    set -lx MTL_HUD_ENABLED 1

    # Run the provided command with all arguments
    $argv
end
