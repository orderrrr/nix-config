{ pkgs, ... }: {

  environment.systemPackages =
    [
      pkgs.vim
      pkgs.rename
    ];

  # Auto upgrade nix package and the daemon service.
  nix.enable = true;
  #services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.nmcintosh = {
    name = "nmcintosh";
    home = "/Users/nmcintosh";
  };
}
