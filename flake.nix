{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls/2259c0db3ae8439c3b140e37fde0f71747821598";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # IMPROVE: learn overlays, should that replace my current method for zig?
  # https://nixos.wiki/wiki/Overlays

  outputs = { nixpkgs, nix-vscode-extensions, home-manager, hyprland-contrib, zig, zls, ... }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
        ];
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem args.system;
        extraSpecialArgs = args.extraSpecialArgs // {
          vscode-extensions = nix-vscode-extensions.extensions.${args.system}.vscode-marketplace;
          hyprland-contrib = hyprland-contrib.packages.${args.system};
          overlays.zig = zig.packages.${args.system};
          overlays.zls = zls.packages.${args.system};
        };
      });
    in
    {
      homeConfigurations.pcLinux = mkHomeConfiguration {
        system = "x86_64-linux";
        extraSpecialArgs = {
          withGui = true;
          username = "sam";
          homeDirectory = "/home/sam";
        };
      };

      homeConfigurations.macbook = mkHomeConfiguration {
        system = "aarch64-darwin";
        extraSpecialArgs = {
          withGui = true;
          username = "sam";
          homeDirectory = "/Users/sam";
        };
      };

      inherit home-manager;
      inherit (home-manager) packages;
    };
}
