# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 7;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    default = 2;
  };
  boot.supportedFilesystems = [ "ntfs" ];

  musnix.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  environment.sessionVariables = {
    # fix missing cursor
    # WLR_NO_HARDWARE_CURSORS = "1";
    # hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    open = true;

    # enable nvidia-settings
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [ ];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "sam";

  sound.enable = true;
  security.rtkit.enable = true;
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
