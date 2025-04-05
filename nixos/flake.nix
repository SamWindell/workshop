{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Import unstable packages
      overlay-unstable = final: prev: {
        unstable = nixpkgs-unstable.legacyPackages.${system};
      };

      mkSystem =
        isWsl:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            # Pass unstable packages to modules
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          };
          modules =
            [
              # Add the overlay to make unstable packages available
              { nixpkgs.overlays = [ overlay-unstable ]; }
              inputs.musnix.nixosModules.musnix
              ./configuration.nix
            ]
            ++ nixpkgs.lib.optionals isWsl [
              ./wsl-configuration.nix
              inputs.nixos-wsl.nixosModules.wsl
            ]
            ++ nixpkgs.lib.optionals (!isWsl) [
              ./hardware-configuration.nix
              ./nixos-configuration.nix
            ];
        };
    in

    {
      nixosConfigurations = {
        wsl = mkSystem true;
        desktop = mkSystem false;
      };
    };
}
