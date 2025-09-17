{ pkgs, ... }: {

  environment.systemPackages =
    [
      pkgs.vim
      pkgs.rename
    ];

  nix.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.nmcintosh = {
    name = "nmcintosh";
    home = "/Users/nmcintosh";
  };

  system.primaryUser = "nmcintosh";

  homebrew = {
    enable = true;

    taps = [];

    brews = [
      "ansible"
      "ansible-lint"
      "btop"
      "cmake"
      "coreutils"
      "curl"
      "docker"
      "docker-compose"
      "eza"
      "ffmpeg"
      "fzf"
      "gh"
      "git"
      "graphviz"
      "imagemagick"
      "ipatool"
      "lazygit"
      "maven"
      "molten-vk"
      "neofetch"
      "neovim"
      "nvm"
      "ollama"
      "python@3.10"
      "rustup"
      "spirv-cross"
      "sshpass"
      "sst/tap/opencode"
      "starship"
      "tailscale"
      "telnet"
      "tinyxml2"
      # "tracy"
      "typescript"
      "vulkan-loader"
      "wget"
      "yt-dlp"
      "zellij"
      "zig"
      "zoxide"
    ];

    casks = [
      "anaconda"
      "bruno"
      "dropbox"
      # "flutter"
      "ghostty"
      # "google-chrome"
      "handbrake-app"
      "jetbrains-toolbox"
      "keka"
      "keycastr"
      "leader-key"
      "legcord"
      "microsoft-remote-desktop"
      "microsoft-teams"
      "middleclick"
      "obsidian"
      "ollamac"
      "orbstack"
      "raycast"
      # "soapui"
      # "splice"
      "spotify"
      "stats"
      "tunnelblick"
      "whatsapp"
      "wireshark-app"
      "zen-browser"
      "zulu@21"
      "zulu@8"
      "zed"
    ];

    masApps = {
      "Xcode" = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # remove old versions
    };
  };
}
