# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}:

{
  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 7;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
    default = 2;
  };
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
  ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  musnix.enable = true;

  # lutris esync
  # https://github.com/lutris/docs/blob/master/HowToEsync.md
  systemd.settings.Manager = {
    DefaultLimitNOFILE = "524288";
  };
  security.pam.loginLimits = [
    {
      domain = "sam";
      type = "hard";
      item = "nofile";
      value = "524288";
    }
  ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # enable wayland on chromium
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
  };

  environment.systemPackages = [
    pkgs.nautilus
    pkgs.nautilus-python
    pkgs.xwayland-satellite
  ];

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "wezterm";
  };

  services.gnome.sushi = {
    enable = true;
  };

  environment = {
    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  hardware.graphics.enable32Bit = true;

  hardware.nvidia = {
    # modesetting.enable = true;

    open = true;

    # enable nvidia-settings
    nvidiaSettings = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = pkgs-unstable.hyprland;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
  };

  programs.niri = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    config = {
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # # Automatic Garbage Collection
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 7d";
  # };

  services.xserver = {
    # Configure keymap in X11
    xkb = {
      variant = "";
      layout = "us";
    };
    videoDrivers = [ "nvidia" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "Sam Windell";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "input"
    ];
    packages = [ ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "sam";

  # services.kmscon = {
  #   enable = true;
  #   hwRender = true;
  #   useXkbConfig = true;
  #   autologinUser = "sam";
  #   fonts = [
  #     {
  #       name = "JetBrainsMono Nerd Font Mono";
  #       package = pkgs.nerd-fonts.jetbrains-mono;
  #     }
  #   ];
  # };

  security.rtkit.enable = true;

  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
