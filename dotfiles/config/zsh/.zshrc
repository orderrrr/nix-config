export ZDOTDIR="$HOME/.config/zsh/config";
export HISTFILE="$HOME/.config/zsh/zsh_history"
export ZSH="$HOME/.config/zsh/ohmyzsh"

setopt PROMPT_SUBST
unsetopt BEEP

# setting user directories
export ANTIGEN_AUTO_CONFIG=false
export LC_ALL="en_US.UTF-8"
# Default programs:
export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"
export NEOVIDE_MULTIGRID=true

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
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

# these will hold important dotfiles
# export DOT=$HOME/dotfiles

#### PATH
# adding to path variables
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/share/cargo/bin:$PATH"
export PATH="$HOME/.ghcup/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.sdk/flutter/bin:$PATH"
export PATH="$HOME/.node_modules/bin/:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="/run/current-system/sw/bin:$PATH"

export PATH="/opt/homebrew/anaconda3/bin:$PATH"
export PATH="/opt/homebrew/anaconda3/envs/bin:$PATH"

export PATH="$HOME/.emacs.d/bin:$PATH"
export PATH="$HOME/.cargo/bin/rust-analyzer:$PATH"

export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.spicetify


[[ -x $ZSH ]] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

install_oh_my_zsh_resource_if_not_exists() {
  local resource_type="$1"
  local resource_name="$2"
  local resource_url="$3"
  local oh_my_zsh_resource_dir=$ZSH/custom/$resource_type/$resource_name
  
  # Check if the plugin already exists
  if [ ! -d "$oh_my_zsh_resource_dir" ]; then
    echo "Installing $resource_name of type $resource_type in path: $oh_my_zsh_resource_dir"
    git clone --quiet --depth 1 "$resource_url" "$oh_my_zsh_resource_dir"
  fi
}

install_oh_my_zsh_resource_if_not_exists "plugins" "fzf-tab" "https://github.com/Aloxaf/fzf-tab.git"
install_oh_my_zsh_resource_if_not_exists "plugins" "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
install_oh_my_zsh_resource_if_not_exists "plugins" "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_oh_my_zsh_resource_if_not_exists "plugins" "fast-syntax-highlighting" "https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
install_oh_my_zsh_resource_if_not_exists "themes" "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git"

plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
)

ZSH_THEME="powerlevel10k/powerlevel10k"

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias vim=nvim
alias hms="nix run nix-darwin -- switch --flake ~/.config/nix"
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

export PATH="/opt/homebrew/bin:$PATH"
alias brew=/opt/homebrew/bin/brew

export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/build-tools
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

alias lsblk="lsblk -e7"

alias virsh="virsh --connect qemu:///system"

# alias dot="print -z $EDITOR \$(find ~/.dot/ -not -path '*.git*' | fzf)"
alias h="setopt HIST_IGNORE_ALL_DUPS && print -z \$(history | sed 's/ *[0-9]*.//' | fzf)"
alias f="print -z $EDITOR \$(find $1 -not -path '*.git*' | fzf)"

alias dnvi="nvim ~/.dots/usr/.config/nvim/"
alias dzsh="nvim ~/.dots/usr/.config/zsh/"
alias obs="VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_pro_icd64.json:/usr/share/vulkan/icd.d/amd_pro_icd32.json OBS_USE_EGL=1 obs"

autoload zmv

# eval "$(pyenv init --path)"
# eval "$(pyenv virtualenv-init -)"

## vim mode configs ##
MODE_CURSOR_VIINS="#00ff00 blinking bar"
MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #ff0000"
MODE_CURSOR_VICMD="green block"
MODE_CURSOR_SEARCH="#ff00ff steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #00ffff"

bindkey -M vicmd "k" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search

bindkey -M vicmd "j" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

bindkey "^P" up-line-or-beginning-search
####

source $ZDOTDIR/os.sh

eval "$(zoxide init zsh)"

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'


source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

bindkey -e
bindkey '[C' forward-word
bindkey '[D' backward-word

alias ls=lsd

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
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
# <<< conda initialize <<<

# To customize prompt, run `p10k configure` or edit ~/dot/.config/zsh/.p10k.zsh.
[[ ! -f ~/dot/.config/zsh/.p10k.zsh ]] || source ~/dot/.config/zsh/.p10k.zsh
