# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # inotify settings to help reduce inotify watch limit errors
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 4096;
    "fs.inotify.max_user_watches" = 524288;
  };

  # Load uinput kernel module for antimicrox
  boot.kernelModules = [ "uinput" ];

  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
  programs.gamemode.enable = true;

  programs.nix-ld.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
  programs.steam.gamescopeSession = {
    enable = true;
    args = [
      "--immediate-flips"
      "--hdr-enabled"
      "--adaptive-sync"
    ];
    steamArgs = [
      "-tenfoot"
      "-pipewire-dmabuf"
    ];
  };

  # fix pinentry-gnome3
  services.dbus.packages = [ pkgs.gcr ];

  fileSystems."/mnt/FrozenVault" = {
    device = "//192.168.1.192/frozenvault1";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=4s,x-systemd.mount-timeout=4s,nofail";

      in
      [
        "${automount_opts},file_mode=0777,dir_mode=0777,credentials=/home/sam/.config/home-manager/secrets/smb-credentials.txt"
      ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  environment.enableDebugInfo = true;

  nixpkgs.config.allowUnfree = true;
  services.gvfs.enable = true;

  # udev rules for antimicrox to access uinput
  services.udev.extraRules = ''
    # Allow users in the input group to access uinput
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    cifs-utils
    neovim
    pinentry-tty
    antimicrox
    gamescope-wsi # HDR support for gamescope
    bottles

    # Wine for running Windows applications
    wineWowPackages.waylandFull
    winetricks
  ];

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.ubuntu
    pkgs.league-of-moveable-type
    pkgs.roboto
    pkgs.inter
    pkgs.quicksand
    (pkgs.noto-fonts.override {
      variants = [
        "NotoSans"
        "NotoSerif"
        "NotoMusic"
        "NotoSansSymbols"
        "NotoSansMath"
        "NotoSansMono"
      ];
    })
    pkgs.noto-fonts-color-emoji
    pkgs.barlow
    (pkgs.stdenvNoCC.mkDerivation rec {
      pname = "outfit-fonts";
      version = "1.1";

      src = pkgs.fetchzip {
        url = "https://github.com/Outfitio/Outfit-Fonts/archive/refs/tags/${version}.zip";
        hash = "sha256-d12SnIhD5LdrgZYH7zzQ8otnRyp45VTCC9vEXVsVKLY=";
      };

      installPhase = ''
        runHook preInstall
        install -Dm644 fonts/variable/*.ttf fonts/ttf/*.ttf -t $out/share/fonts/opentype
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Outfit Fonts";
        homepage = "https://github.com/Outfitio/Outfit-Fonts";
        license = licenses.ofl;
        maintainers = [ ];
        platforms = platforms.all;
      };
    })
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
