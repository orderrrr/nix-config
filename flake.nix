{
  description = "order nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, nix-homebrew, ... }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#nathaniels-MacBook-Pro
    darwinConfigurations."nathaniels-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "nmcintosh";
            autoMigrate = true;
          };
        }

        home-manager.darwinModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nmcintosh = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."nathaniels-MacBook-Pro".pkgs;
  };
}
