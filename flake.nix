{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
    # https://wezfurlong.org/wezterm/install/linux.html#flake
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      mac-app-util,
      ...
    }:
    let
      pkgsForSystem =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

      mkHomeConfiguration =
        args:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            mac-app-util.homeManagerModules.default
            (import ./home.nix)
          ];
          pkgs = pkgsForSystem args.system;
          extraSpecialArgs = args.extraSpecialArgs // {
            inherit inputs;
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
