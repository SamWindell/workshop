{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.rename # rename files: rename "s/foo/bar/" *.png
    pkgs.sox # audio file manipulation
    pkgs.imagemagick # image file manipulation
    pkgs.ffmpeg # video/audio manipulaiton
    pkgs.fd # find alternative, run fd -h for consise help
    pkgs.gnused # replace e.g.: sed -s "s/foo/bar/g" file.txt

    pkgs.cmake
    pkgs.ninja

    pkgs.nixd # nix LSP
    pkgs.nixpkgs-fmt # nix code formatting
    pkgs.manix # command-line nix doc search

    pkgs.sqlite # needed by nvim smart-open plugin

    pkgs.gh
    pkgs.git

    # pkgs.neovide

    specialArgs.overlays.zig.master-2023-12-01

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".config/nvim/lua/".source = ./nvim;
    ".config/starship.toml".source = ./starship.toml;
    ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sam/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      PATH=/home/sam/.cargo/bin:$PATH
      PATH=/home/sam/bin:$PATH
    '';
    shellAliases = {
      nvd = "neovide --multigrid";
      froz = "nvd ~/Projects/frozencode";
      ls = "ls -lh --color=always";
    };
  };

  # fancy command history in bash
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  # fuzzy search. this also enables integration with bash e.g.: `nvim **<TAB>`
  programs.fzf.enable = true;

  # nicer grep
  programs.ripgrep.enable = true;

  programs.starship.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      {
        # smart-open requires a path to sqlite, we have to do that here because the 
        # path will not stay the same when we use nix
        plugin = pkgs.vimPlugins.sqlite-lua;
        config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
      }
    ];
    extraLuaConfig = ''
      require "nvim-init"
    '';
  };

}
