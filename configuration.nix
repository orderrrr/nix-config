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

  # homebrew = {
  #   enable = true;
  #
  #   taps = [];
  #
  #   brews = [
  #   ];
  #
  #   casks = [
  #       # "zed"
  #   ];
  #
  #   masApps = {
  #     "Xcode" = 497799835;
  #   };
  #
  #   onActivation = {
  #     autoUpdate = true;
  #     upgrade = true;
  #     cleanup = "zap"; # remove old versions
  #   };
  # };
}
