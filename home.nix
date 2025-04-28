{ pkgs, ... }:
{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.packages = with pkgs; [
    pkgs.orbstack
  ];

  home.file = {
    ".config/nvim".source = dotfiles/config/nvim;
    ".config/zsh/config".source = dotfiles/config/zsh;
    ".config/wezterm".source = dotfiles/config/wezterm;
    ".aerospace.toml".source = dotfiles/.aerospace.toml;
    ".config/zellij".source = dotfiles/config/zellij;
  };

  programs.zsh.enable = true;

  home.sessionVariables = {
    HISTFILE="$HOME/.config/zsh/zsh_history";
    ZDOTDIR="$HOME/.config/zsh/config";
    ZSH_COMPDUMP="$HOME/.config/zsh/.zcompdump";
    ZSH="$HOME/.config/zsh/ohmyzsh";
  };

  programs.home-manager.enable = true;
}
