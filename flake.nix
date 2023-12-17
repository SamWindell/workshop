{
  description = "Home Manager configuration of sam";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
  };

  # TODO: learn overlays, should that replace my current method for zig?
  # https://nixos.wiki/wiki/Overlays

  outputs = { nixpkgs, home-manager, zig, ... }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem (args.system or "x86_64-linux");
        extraSpecialArgs = args.extraSpecialArgs // {
          overlays.zig = zig.packages.${args.system};
        };
      });
    in
    {
      homeConfigurations.sam = mkHomeConfiguration {
        system = "x86_64-linux";
        extraSpecialArgs = {
          withGUI = true;
        };
      };

      homeConfigurations.macbook = mkHomeConfiguration {
        system = "aarch64-darwin";
        extraSpecialArgs = {
          withGUI = true;
        };
      };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}
