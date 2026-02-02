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

    taps = ["nikitabobko/tap" "sst/tap" "dart-lang/dart" "slp/krunkit" "steipete/tap"];

    brews = [
      "ansible" "ansible-lint" "btop" "cmake" "coreutils" "curl" "docker" "docker-compose" "direnv"
      "eza" "ffmpeg" "fzf" "fish" "gh" "git" "graphviz" "imagemagick" "ipatool" "lazygit" "maven"
       "neofetch" "neovim" "ollama" "python@3.10" "rustup" "spirv-cross" "fisher"
      "sshpass" "opencode" "starship" "tailscale" "telnet" "tinyxml2" "typescript"
      "vulkan-loader" "wget" "yt-dlp" "zig" "zoxide" "jj" "pixi" "colmap" "just" "glfw"
      "llvm@20" "mtr" "molten-vk" "nx" "macmon" "openjdk@17" "dart" "krunkit" "podman"
      "steipete/tap/peekaboo" "ripgrep" "steipete/tap/remindctl" "steipete/tap/summarize" "steipete/tap/wacli"
      "git-delta" "ios-deploy"
      # "krunvm" "podman"
      # "tracy"
    ];

    casks = [
      "anaconda" "bruno" "dropbox" "ghostty" "handbrake-app" "jetbrains-toolbox" "keka"
      "keycastr" "leader-key" "legcord" "microsoft-remote-desktop" "microsoft-teams" "middleclick"
      "obsidian" "ollamac" "orbstack" "raycast" "spotify" "stats" "tunnelblick" "whatsapp"
      "wireshark-app" "zen" "zulu" "zulu@21" "zulu@8" "zed" "postman" "google-chrome" "plugdata"
      "jordanbaird-ice" "aerospace" "flutter" "android-commandlinetools" "claude" "claude-code" 
      "upscayl"
			# "soapui" "splice"
    ];

    masApps = {};

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
