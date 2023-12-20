{
  description = "Home Manager configuration of sam";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
      # TODO: we need to set a different username + home-path for each config, not have the same from home.nix
      # then we can use this syntax on each system: home-manager switch --flake .#<configuration>
      homeConfigurations.sam = mkHomeConfiguration {
        system = "aarch64-darwin";
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
