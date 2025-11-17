{ pkgs, ... }:
{
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    zinit
  ];

  home.file = {
    ".config/nvim/lua".source = dotfiles/config/nvim/lua;
    ".config/nvim/init.lua".source = dotfiles/config/nvim/init.lua;
    ".config/nvim/nvim-nightly.sh".source = dotfiles/config/nvim/nvim-nightly.sh;
    ".config/nvim/.env".source = dotfiles/config/nvim/.env;

    ".aerospace.toml".source = dotfiles/aerospace.toml;
    ".config/zellij".source = dotfiles/config/zellij;
    ".config/fish/config.fish".source = dotfiles/config/config.fish;
    ".config/ghostty".source = dotfiles/config/ghostty;
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
