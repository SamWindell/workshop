{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls/a26718049a8657d4da04c331aeced1697bc7652b";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-vscode-extensions, home-manager, hyprland-contrib, zig, zls, ... }:
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

      mkHomeConfiguration = args: home-manager.lib.homeManagerConfiguration {
        modules = [ (import ./home.nix) ];
        pkgs = pkgsForSystem args.system;
        extraSpecialArgs = args.extraSpecialArgs // {
          vscode-extensions = nix-vscode-extensions.extensions.${args.system}.vscode-marketplace;
          hyprland-contrib = hyprland-contrib.packages.${args.system};
          zig = zig.packages.${args.system};
          zls = zls.packages.${args.system};
        };
      };
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
