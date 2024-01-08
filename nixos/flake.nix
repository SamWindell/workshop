{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux"; #current system
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;

      mkSystem = pkgs: isWsl:
        pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix

            # home-manager.nixosModules.home-manager
            # {
            #     home-manager = {
            #         useUserPackages = true;
            #         useGlobalPkgs = true;
            #         extraSpecialArgs = { inherit inputs; };
            #         # users.notus = (./. + "/hosts/${hostname}/user.nix");
            #     };
            #     nixpkgs.overlays = [
            #         # Add nur overlay for Firefox addons
            #         nur.overlay
            #         (import ./overlays)
            #     ];
            # }
          ] ++ pkgs.lib.optionals (isWsl) [
            ./wsl-configuration.nix
            inputs.nixos-wsl.nixosModules.wsl
          ] ++ pkgs.lib.optionals (!isWsl) [
            ./hardware-configuration.nix
            ./nixos-configuration.nix
          ];
        };
    in

    {
      nixosConfigurations = {
        wsl = mkSystem inputs.nixpkgs true;
        desktop = mkSystem inputs.nixpkgs false;
      };
    };
}
