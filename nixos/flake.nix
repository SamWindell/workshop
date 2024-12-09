{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = { url = "github:musnix/musnix"; };
  };

  # The `@` syntax here is used to alias the attribute set of the
  # inputs's parameter, making it convenient to use inside the function.
  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";

      mkSystem = isWsl:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.musnix.nixosModules.musnix
            ./configuration.nix
          ] ++ inputs.nixpkgs.lib.optionals isWsl [
            ./wsl-configuration.nix
            inputs.nixos-wsl.nixosModules.wsl
          ] ++ inputs.nixpkgs.lib.optionals (!isWsl) [
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
