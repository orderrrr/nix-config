{ pkgs, ... }:

let
  isDarwin = pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-darwin";
  user = if isDarwin then "nmcintosh" else "order";
in
{
  home.username = user;
  home.homeDirectory = if isDarwin then "/Users/${user}" else "/home/${user}";
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    zinit
    vim
    rename
    btop
    eza
    lsd
    fzf
    fish
    starship
    direnv
    zoxide
    neofetch
    yt-dlp
    zig
    jj
    pixi
    just
    ripgrep
    git
    gh
    lazygit
    curl
    wget
    mtr
    tailscale
    ffmpeg
    imagemagick
    graphviz
    cmake
    coreutils
    nixfmt-rfc-style
    curlie
    ollama
  ];

  home.file = {
    ".config/nvim/nvim-nightly.sh".source = dotfiles/config/nvim/nvim-nightly.sh;

    ".config/nvim/init.lua".source = dotfiles/config/nvim/init.lua;

    ".config/nvim/colors".source = dotfiles/config/nvim/colors;
    ".config/nvim/lua".source = dotfiles/config/nvim/lua;
    ".config/nvim/.env".source = dotfiles/config/nvim/.env;

    ".config/ghostty".source = dotfiles/config/ghostty;

    ".config/opencode/opencode.json".source = dotfiles/config/opencode/opencode.json;

    ".zshenv".source = dotfiles/zshenv;

    ".config/fish/config.fish".source = dotfiles/config/fish/config.fish;
    ".config/fish/os.fish".source = if isDarwin then dotfiles/config/fish/os/macos.fish else dotfiles/config/fish/os/linux.fish;
    ".config/fish/functions/archives.fish".source = dotfiles/config/fish/functions/archives.fish;
    ".config/fish/functions/rsh.fish".source = dotfiles/config/fish/functions/rsh.fish;
    ".config/fish/functions/ai-commit.fish".source = dotfiles/config/fish/functions/ai-commit.fish;
  }
  // pkgs.lib.optionalAttrs isDarwin {
    ".aerospace.toml".source = dotfiles/aerospace.toml;
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
