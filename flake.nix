{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
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
    # Add hyprshot as a new input
    hyprshot = {
      url = "github:Gustash/hyprshot";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      mac-app-util,
      hyprshot,
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
          overlays = [
            # Add an overlay to create a custom hyprshot package
            (final: prev: {
              hyprshot = final.callPackage (
                {
                  stdenvNoCC,
                  lib,
                  hyprland,
                  jq,
                  grim,
                  slurp,
                  wl-clipboard,
                  libnotify,
                  withFreeze ? true,
                  hyprpicker,
                  makeWrapper,
                }:
                stdenvNoCC.mkDerivation {
                  pname = "hyprshot";
                  version = "git-${builtins.substring 0 8 (builtins.readFile (builtins.toFile "hash" hyprshot.rev))}";
                  src = hyprshot;
                  nativeBuildInputs = [ makeWrapper ];
                  installPhase = ''
                    runHook preInstall
                    install -Dm755 hyprshot -t "$out/bin"
                    wrapProgram "$out/bin/hyprshot" \
                      --prefix PATH ":" ${
                        lib.makeBinPath (
                          [
                            hyprland
                            jq
                            grim
                            slurp
                            wl-clipboard
                            libnotify
                          ]
                          ++ lib.optionals withFreeze [ hyprpicker ]
                        )
                      }
                    runHook postInstall
                  '';
                  meta = with lib; {
                    homepage = "https://github.com/Gustash/hyprshot";
                    description = "Hyprshot is an utility to easily take screenshots in Hyprland using your mouse";
                    license = licenses.gpl3Only;
                    platforms = hyprland.meta.platforms;
                  };
                }
              ) { };
            })
          ];
        };

      unstablePkgsForSystem =
        system:
        import nixpkgs-unstable {
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
            pkgs-unstable = unstablePkgsForSystem args.system;
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
