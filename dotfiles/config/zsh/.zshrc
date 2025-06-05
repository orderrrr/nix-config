# 1. P10k instant prompt FIRST
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Optimization flags
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
DISABLE_AUTO_TITLE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# 3. Optimized completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"
else
    compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"
fi
autoload -Uz bashcompinit && bashcompinit

# 4. ZSH Configuration
export ZDOTDIR="$HOME/.config/zsh/config"
export HISTFILE="$HOME/.config/zsh/zsh_history"
export ZSH="$HOME/.config/zsh/ohmyzsh"
setopt PROMPT_SUBST
unsetopt BEEP

# 5. System Configuration
export ANTIGEN_AUTO_CONFIG=false
export LC_ALL="en_US.UTF-8"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# 6. Default programs
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"
export NEOVIDE_MULTIGRID=true

# 7. XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# 8. Application-specific directories
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

# 9. Consolidated PATH (readable format)
export PATH="\
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

# 10. Oh-My-Zsh Configuration
plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  fast-syntax-highlighting
)
ZSH_THEME="powerlevel10k/powerlevel10k"

# 11. Aliases
alias vim=nvim
alias hms="sudo nix run nix-darwin -- switch --flake ~/.config/nix"
alias m=ncmpcpp
alias ls=lsd
alias tt="zellij"
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
alias h="setopt HIST_IGNORE_ALL_DUPS && print -z \$(history | sed 's/ _[0-9]_.//' | fzf)"
alias f="print -z $EDITOR \$(find $1 -not -path '*.git*' | fzf)"
alias dnvi="nvim ~/.dots/usr/.config/nvim/"
alias dzsh="nvim ~/.dots/usr/.config/zsh/"
alias obs="VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_pro_icd64.json:/usr/share/vulkan/icd.d/amd_pro_icd32.json OBS_USE_EGL=1 obs"

# 12. ZSH modules and options
autoload zmv

# 13. Vim mode cursor configuration
MODE_CURSOR_VIINS="#00ff00 blinking bar"
MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #ff0000"
MODE_CURSOR_VICMD="green block"
MODE_CURSOR_SEARCH="#ff00ff steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #00ffff"

# 14. Key bindings
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

# 15. Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# 16. Load Powerlevel10k configuration
[[ ! -f ~/.config/zsh/config/.p10k.zsh ]] || source ~/.config/zsh/config/.p10k.zsh

# 17. Completion styling (after Oh-My-Zsh)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'

# 18. Lazy load functions
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

# 19. Initialize external tools (at the end for performance)
eval "$(zoxide init zsh)"
source $ZDOTDIR/os.sh
