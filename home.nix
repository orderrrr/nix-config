{ pkgs, ... }:
{
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    zinit
  ];

  home.file = {
    ".config/nvim/nvim-nightly.sh".source = dotfiles/config/nvim/nvim-nightly.sh;

    ".config/nvim/init.lua".source = dotfiles/config/nvim/init.lua;
    ".config/nvim/init_multiplexer.lua".source = dotfiles/config/nvim/init_multiplexer.lua;

    ".config/nvim/colors".source = dotfiles/config/nvim/colors;
    ".config/nvim/lua".source = dotfiles/config/nvim/lua;
    ".config/nvim/.env".source = dotfiles/config/nvim/.env;

    ".aerospace.toml".source = dotfiles/aerospace.toml;
    ".config/ghostty".source = dotfiles/config/ghostty;

    ".config/opencode/opencode.json".source = dotfiles/config/opencode/opencode.json;


    ".config/fish/config.fish".source = dotfiles/config/fish/config.fish;
    ".config/fish/functions/archives.fish".source = dotfiles/config/fish/functions/archives.fish;
    ".config/fish/functions/rsh.fish".source = dotfiles/config/fish/functions/rsh.fish;
    ".config/fish/functions/ai-commit.fish".source = dotfiles/config/fish/functions/ai-commit.fish;
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
