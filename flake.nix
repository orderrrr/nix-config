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

  outputs = { self, home-manager, nix-darwin, nix-homebrew, nixpkgs, ... }:
  let
    user = if builtins.getEnv "USER" != "" then builtins.getEnv "USER" else "order";
    hostname = if builtins.getEnv "HOSTNAME" != "" then builtins.getEnv "HOSTNAME" else "arch-linux";
  in
  {
    darwinConfigurations."nathaniels-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        ./configuration.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = user;
            autoMigrate = true;
          };
        }

        home-manager.darwinModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ./home.nix;
        }
      ];
    };

    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [ ./home.nix ];
    };

    darwinPackages = self.darwinConfigurations."nathaniels-MacBook-Pro".pkgs;
  };
}
