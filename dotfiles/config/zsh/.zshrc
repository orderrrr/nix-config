# 1. P10k instant prompt FIRST
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Zinit Optimization flags
if [[ ! -v ZINIT ]]; then
    declare -A ZINIT
fi
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[MUTE_WARNINGS]=1
ZINIT[NO_ALIASES]=1

# 3. General optimization flags
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
DISABLE_AUTO_TITLE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

# 5. ZSH Configuration
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.config/zsh/zsh_history"
export ZDOTDIR="$HOME/.config/zsh/config"
setopt PROMPT_SUBST
unsetopt BEEP

# 6. System Configuration
export ANTIGEN_AUTO_CONFIG=false
export LC_ALL="en_US.UTF-8"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# 7. Default programs
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"
export NEOVIDE_MULTIGRID=true

# 8. XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# 9. Application-specific directories
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"
export UNISON="${XDG_DATA_HOME:-$HOME/.local/share}/unison"
export CHROME_EXECUTABLE=/usr/bin/google-chrome-unstable
export QT_QPA_PLATFORMTHEME=gtk2
export JULIA_DEPOT_PATH="$HOME/.local/share/julia:"
export GRAPHVIZ_DOT=/opt/homebrew/bin/dot
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export DYLD_LIBRARY_PATH=/opt/homebrew/lib

# Word navigation with Ctrl+Arrow keys
bindkey "^[[1;5C" forward-word    # Ctrl+Right Arrow
bindkey "^[[1;5D" backward-word   # Ctrl+Left Arrow

# 10. Consolidated PATH
export PATH="\
$HOME/.bin/nvim/bin:$PATH:\
/opt/homebrew/anaconda3/bin:\
$HOME/.local/bin:\
$HOME/.bin:\
$HOME/.local/share/cargo/bin:\
$HOME/.ghcup/bin:\
$HOME/.pub-cache/bin:\
$HOME/.sdk/flutter/bin:\
$HOME/.node_modules/bin:\
$HOME/git/slang/bin:\
/opt/homebrew/opt/rustup/bin:\
/run/current-system/sw/bin:\
/opt/homebrew/anaconda3/bin:\
/opt/homebrew/anaconda3/envs/bin:\
$HOME/.emacs.d/bin:\
$HOME/.cargo/bin/rust-analyzer:\
$HOME/.cargo/bin:\
$HOME/.spicetify:\
/opt/homebrew/opt/gnu-getopt/bin:\
/opt/homebrew/bin:\
$ANDROID_HOME/platform-tools:\
$ANDROID_HOME/emulator:\
$ANDROID_HOME/build-tools:\
/opt/homebrew/opt/postgresql@15/bin:\
$PATH"

# 11. Initialize Zinit
source "$HOME/.nix-profile/share/zinit/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# # 12. Load Zinit annexes (without Turbo for stability)
# zinit light-mode for \
#     zdharma-continuum/zinit-annex-as-monitor \
#     zdharma-continuum/zinit-annex-bin-gem-node \
#     zdharma-continuum/zinit-annex-patch-dl \
#     zdharma-continuum/zinit-annex-rust

# 13. Load Powerlevel10k theme (non-turbo for instant prompt compatibility)
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load required ZLE widgets before syntax highlighting
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search


# 14. Load plugins with Turbo mode for faster startup
# Fast syntax highlighting (load immediately for better UX)
zinit light zdharma-continuum/fast-syntax-highlighting

# Turbo-loaded plugins (loaded after prompt)
# Add this to your turbo-loaded plugins section (around line 58)
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        bindkey '^P' history-substring-search-up
        bindkey '^N' history-substring-search-down
    " \
        zsh-users/zsh-history-substring-search \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions \
    Aloxaf/fzf-tab

# 15. Git plugin functionality (Oh-My-Zsh git plugin replacement)
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git

# 16. Aliases
alias vim=nvim
alias hms="sudo nix run nix-darwin -- switch --flake ~/.config/nix"
alias m=ncmpcpp
alias ls=lsd
alias t="zellij"
alias gitc="git clone"
alias gitp="git pull"
alias npmr="npm run"
alias npmi="npm install"
alias mv="mv -iv"
alias cp="cp -riv"
alias mkdir="mkdir -vp"
alias e=$EDITOR
alias cat="bat -pP --style plain"
alias ssh="TERM=xterm-256color ssh"
alias brew=/opt/homebrew/bin/brew
alias lsblk="lsblk -e7"
alias virsh="virsh --connect qemu:///system"
alias h="setopt HIST_IGNORE_ALL_DUPS && print -z \$(fc -ln 1 | fzf)"
alias f="print -z $EDITOR \$(find $1 -not -path '*.git*' | fzf)"
alias dnvi="nvim ~/.dots/usr/.config/nvim/"
alias dzsh="nvim ~/.dots/usr/.config/zsh/"
alias obs="VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_pro_icd64.json:/usr/share/vulkan/icd.d/amd_pro_icd32.json OBS_USE_EGL=1 obs"
alias j8="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
alias j21="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
alias j24="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home"

ze() { zi "$@" && nvim; }

# 17. ZSH modules and options
autoload zmv

# 18. Vim mode cursor configuration
MODE_CURSOR_VIINS="#00ff00 blinking bar"
MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #ff0000"
MODE_CURSOR_VICMD="green block"
MODE_CURSOR_SEARCH="#ff00ff steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #00ffff"

# 19. Key bindings
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

# Add this to your key bindings section (around line 94, after your existing bindkeys)
bindkey "^[[3~" delete-char    # Delete key

# 20. Load Powerlevel10k configuration
[[ ! -f ~/.config/zsh/config/.p10k.zsh ]] || source ~/.config/zsh/config/.p10k.zsh

# 21. Completion styling (after plugins are loaded)
zinit wait lucid for \
    atload"
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always \$realpath'
        zstyle ':completion:*:git-checkout:*' sort false
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}
        zstyle ':fzf-tab:*' switch-group ',' '.'
    " \
    zdharma-continuum/null

# 22. Lazy load functions
conda() {
    unset -f conda
    __conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/opt/homebrew/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}

nvm() {
    unset -f nvm
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    nvm "$@"
}

# # 23. Initialize external tools (deferred with Turbo)
# zinit wait lucid for \
#     atload"eval \"\$(zoxide init zsh)\"" \
#     zdharma-continuum/null
eval "$(zoxide init zsh)"

# 24. Load OS-specific configuration (deferred)
zinit wait lucid for \
    atload"[[ -f \$ZDOTDIR/os.sh ]] && source \$ZDOTDIR/os.sh" \
    zdharma-continuum/null
