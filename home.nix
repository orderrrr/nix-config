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
    zinit
  ];

  home.file = {
    ".config/nvim".source = dotfiles/config/nvim;
    ".aerospace.toml".source = dotfiles/.aerospace.toml;
    ".config/zellij".source = dotfiles/config/zellij;
    ".config/fish/config.fish".source = dotfiles/config/config.fish;
    ".config/ghostty".source = dotfiles/config/ghostty;
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
