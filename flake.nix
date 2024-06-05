{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-lldb.url = "github:nixos/nixpkgs/b67fc24e4acf7189590d229c2f286896527f849e";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls/2259c0db3ae8439c3b140e37fde0f71747821598";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-lldb, nix-vscode-extensions, home-manager, hyprland-contrib, zig, zls, ... }:
    let
      pkgsForSystem = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-24.8.6" # obsidian-wayland
          ];
        };
        overlays = [
          (final: prev: {
            # workaround a bug where obsidian doesn't work on wayland
            obsidian-wayland = prev.obsidian.override { electron = final.electron_24; };
          })
        ];
      };

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration (rec {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem args.system;
        extraSpecialArgs = args.extraSpecialArgs // {
          vscode-extensions = nix-vscode-extensions.extensions.${args.system}.vscode-marketplace;
          hyprland-contrib = hyprland-contrib.packages.${args.system};
          zig = zig.packages.${args.system};
          zls = zls.packages.${args.system};
          pkgs-lldb = import nixpkgs-lldb { system = args.system; };
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

      homeConfigurations.pcWsl = mkHomeConfiguration {
        system = "x86_64-linux";
        extraSpecialArgs = {
          withGui = false;
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
