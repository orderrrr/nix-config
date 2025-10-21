{ pkgs, ... }:
{
  home.stateVersion = "24.05";
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
