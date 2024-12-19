{
  description = "order nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, ... }:
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#nathaniels-MacBook-Pro
    darwinConfigurations."nathaniels-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
                    ./configuration.nix
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
