{
  config,
  lib,
  pkgs,
  specialArgs,
  inputs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (specialArgs) withGui;

  zig = inputs.zig.packages.${pkgs.system}."0.13.0";
  zls = inputs.zls.packages.${pkgs.system}.zls.overrideAttrs (prev: {
    nativeBuildInputs = [ zig ];
  });
  grimblast = inputs.hyprland-contrib.packages.${pkgs.system}.grimblast;
  wezterm = inputs.wezterm.packages.${pkgs.system}.default;
in
{
  home.username = specialArgs.username;
  home.homeDirectory = specialArgs.homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages =
    [
      pkgs.rename # rename files: rename "s/foo/bar/" *.png
      pkgs.sox # audio file manipulation
      pkgs.imagemagick # image file manipulation
      pkgs.ffmpeg # video/audio manipulaiton
      pkgs.fd # find alternative, run fd -h for consise help
      pkgs.gnused # replace e.g.: sed -s "s/foo/bar/g" file.txt
      pkgs.ast-grep # powerful grep for code https://ast-grep.github.io/
      pkgs.sad # better sed
      pkgs.jq # json manipulation
      pkgs.unzip
      pkgs.zip
      pkgs.bashInteractive
      pkgs.wget
      pkgs.colordiff
      pkgs.reuse # https://reuse.software/
      pkgs.cloc # count lines of code
      pkgs.lnav # log file viewer
      pkgs.git-town

      pkgs.cmake
      pkgs.ninja
      pkgs.llvmPackages_18.clang-unwrapped # clangd
      pkgs.llvmPackages_18.libllvm # llvm-symbolizer
      pkgs.lldb_18
      pkgs.python3
      pkgs.just
      pkgs.awscli2

      pkgs.nixd # nix LSP
      pkgs.nixpkgs-fmt # nix code formatting
      pkgs.nurl # command-line tool to generate Nix fetcher calls from repository URLs
      pkgs.nix-init
      pkgs.nixfmt-rfc-style

      pkgs.sqlite # needed by nvim smart-open plugin
      pkgs.lua-language-server
      pkgs.nodejs_22
      pkgs.cmake-language-server
      pkgs.nodePackages.svelte-language-server
      pkgs.nodePackages.prettier
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.typescript
      pkgs.vscode-langservers-extracted
      pkgs.python3Packages.python-lsp-server
      pkgs.black # python formatter
      pkgs.cmake-format

      pkgs.gh
      pkgs.git

      pkgs.transcrypt
      # I'm not sure why I have to add these too, the nixpkgs source for transcrypt looks like it
      # should manage these dependencies itself
      pkgs.openssl # transcrypt
      pkgs.coreutils # transcrypt
      pkgs.util-linux # transcrypt
      pkgs.gnugrep # transcrypt
      pkgs.gnused # transcrypt
      pkgs.gawk # transcrypt
      pkgs.xxd # transcrypt

      zig
      zls

      pkgs.hunspell
      pkgs.hunspellDicts.en_GB-ise

      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

      (pkgs.writeShellScriptBin "colour-picker" ''
        colour=$(hyprpicker -a)
        notify-send "Colour Picker" "$colour copied to clipboard"
      '')

      (pkgs.writeShellScriptBin "workshop" ''
        wezterm start -- nvim ~/.config/home-manager
        hyprctl dispatch focuswindow "org.wezfurlong.wezterm"
      '')

      (pkgs.writeShellScriptBin "floe" ''
        wezterm start --cwd ~/Projects/floe -- nix develop
        hyprctl dispatch focuswindow "org.wezfurlong.wezterm"
      '')

      (pkgs.writeShellScriptBin "froz" ''
        wezterm start --cwd ~/Projects/frozenplain.com
        hyprctl dispatch focuswindow "org.wezfurlong.wezterm"
      '')

      (pkgs.writers.writeBashBin "firefox-bookmarks" { } (builtins.readFile ./bash/firefox-bookmarks.sh))

      (pkgs.writeShellScriptBin "pick-firefox-bookmark" ''
        selected=$(firefox-bookmarks --list | fuzzel --dmenu) 
        [ -z "$selected" ] && exit 0
        firefox-bookmarks --url "$selected" | xargs firefox
        hyprctl dispatch workspace 3 
      '')
    ]
    ++ pkgs.lib.optionals (isLinux && withGui) [
      pkgs.thunderbird
      pkgs.loupe # gnome image viewer
      pkgs.nautilus # gnome files
      pkgs.sushi # gnome file previewer
      pkgs.wl-clipboard # needed to get neovim clipboard working
      pkgs.vesktop # discord
      pkgs.zulip
      pkgs.waybar
      pkgs.firefox
      pkgs.brave
      pkgs.hyprpicker
      pkgs.google-chrome
      pkgs.appimage-run # `appimage-run foo.AppImage` https://nixos.wiki/wiki/Appimage
      (pkgs.nerdfonts.override { fonts = [ "Ubuntu" ]; })
      # pkgs.bitwarden # opens but never syncs vault, Sept 2024
      pkgs.gimp
      pkgs.inkscape
      pkgs.zeal
      pkgs.vlc
      pkgs.obs-studio
      pkgs.obsidian
      pkgs.sublime-merge
      pkgs.libreoffice
      grimblast # screenshot helper
      pkgs.xdg-utils # xdg-open
      pkgs.gnome-system-monitor
      pkgs.blueberry # bluetooth manager
      pkgs.quickemu
      pkgs.musescore
      wezterm
      pkgs.bemoji
      pkgs.wtype

      pkgs.pinentry-gnome3

      pkgs.geonkick
      pkgs.reaper
      pkgs.lsp-plugins
      pkgs.distrho-ports
      pkgs.sfizz
      pkgs.surge-XT
      pkgs.decent-sampler
      pkgs.fluidsynth
      pkgs.qsynth

      # DAWs
      pkgs.bitwig-studio
      pkgs.zrythm
      # pkgs.carla
      pkgs.qtractor

    ]
    ++ pkgs.lib.optionals withGui [
      pkgs.tracy
      pkgs.keepassxc
    ]
    ++ pkgs.lib.optionals isLinux [
      pkgs.wineWow64Packages.waylandFull
    ];

  home.file = {
    # config.lib.file.mkOutOfStoreSymlink is a handy trick to allow apps to reload their config files
    # without needing to home-manager switch
    ".config/nvim/lua/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    ".config/wezterm/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/wezterm";
    ".config/starship.toml".source = ./starship/starship.toml;
    ".config/waybar/".source = ./waybar;
    ".config/hypr/hyprland.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/hypr/config.conf";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.bashInteractive}/bin/bash";
  };

  programs.home-manager.enable = true;

  # Allow commands to be run from pickers such as fuzzel
  xdg.desktopEntries = mkIf (isLinux && withGui) {
    "hyprpicker" = {
      name = "Colour Picker";
      icon = "color-picker";
      exec = "colour-picker";
      terminal = false;
      categories = [ "Utility" ];
      comment = "Pick a colour from the screen and copy it to the clipboard";
    };
    "system-shutdown" = {
      name = "Shutdown System";
      icon = "system-shutdown";
      exec = "systemctl poweroff";
      terminal = false;
      categories = [ "System" ];
      comment = "Shutdown the computer";
    };
    "system-reboot" = {
      name = "Reboot System";
      icon = "system-reboot";
      exec = "reboot";
      terminal = false;
      categories = [ "System" ];
      comment = "Restart the computer";
    };
    "hyprland-stop" = {
      name = "Exit Hyprland";
      icon = "system-log-out";
      exec = "uwsm stop";
      terminal = false;
      categories = [ "System" ];
      comment = "Stop Hyprland session";
    };
    "nix-search" = {
      name = "Nix Search";
      icon = "system-search";
      exec = "firefox https://search.nixos.org/packages";
      terminal = false;
      categories = [ "System" ];
      comment = "Search for a package in Nix";
    };
    "workshop" = {
      name = "Workshop";
      icon = "applications-development";
      exec = "workshop";
      terminal = false;
      categories = [ "Development" ];
      comment = "Open Home Manager in Neovim";
    };
    "floe" = {
      name = "Floe";
      icon = "applications-development";
      exec = "floe";
      terminal = false;
      categories = [ "Development" ];
      comment = "Open Floe project in Nix shell";
    };
    "froz" = {
      name = "Frozenplain";
      icon = "applications-development";
      exec = "froz";
      terminal = false;
      categories = [ "Development" ];
      comment = "Open Frozenplain Website project";
    };
  };

  # You must also set programs.hyprland.enable = true in /etc/nixos/configuration.nix.
  wayland.windowManager.hyprland = mkIf (isLinux && withGui) {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  services.hypridle = mkIf (isLinux && withGui) {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 100; # seconds
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };

  services.megasync.enable = isLinux && withGui; # cloud sync program

  # notifications
  services.swaync = mkIf (isLinux && withGui) {
    enable = true;
  };

  # picker
  programs.fuzzel = mkIf (isLinux && withGui) {
    enable = true;
  };

  programs.bat = {
    enable = true;
    extraPackages = [
      pkgs.bat-extras.batman
    ];
  };

  gtk = mkIf (isLinux && withGui) {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    cursorTheme = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ".2" = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      ".6" = "cd ../../../../../..";
      "gs" = "git status";
      "ga" = "git add";
      "gap" = "git add -p";
      "gc" = "git commit --verbose";
      "gd" = "git diff";
      "gds" = "git diff --staged";
      "gpsh" = "git push";
      "gpll" = "git pull";
      "gclone" = "git clone";
      "gclone-bl" = "git clone --filter=blob:none";
    };
    initExtra =
      pkgs.lib.optionalString isDarwin ''
        export LLDB_DEBUGSERVER_PATH=/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/debugserver
      ''
      + ''
        source "${./bash/init.sh}"
        source "${pkgs.wezterm}/etc/profile.d/wezterm.sh"
      '';
  };

  programs.ssh.enable = true;

  # fancy command history in bash
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  # fuzzy search. this also enables integration with bash e.g.: `nvim **<TAB>`
  programs.fzf = {
    enable = true;
  };

  # better cd
  programs.zoxide = {
    enable = true;
  };

  # nicer grep
  programs.ripgrep.enable = true;

  # nicer prompt
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true; # use the delta program for diff syntax highlighting
    userName = "Sam Windell";
    userEmail = "info@frozenplain.com";
    extraConfig = {
      "init" = {
        "defaultBranch" = "main";
      };
      "credential \"https://github.com\"" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      "credential \"https://gist.github.com\"" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
    };
  };

  # better ls
  programs.eza = {
    enable = true;
    icons = "auto";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins =
      with pkgs.vimPlugins;
      let
        # use nurl CLI to generate these
        smart-open = pkgs.vimUtils.buildVimPlugin {
          name = "smart-open";
          src = pkgs.fetchFromGitHub {
            owner = "danielfalk";
            repo = "smart-open.nvim";
            rev = "cf8cbaab3b802f4690eda3b1cc6dfc606d313695";
            hash = "sha256-57UmLohd47/b6ytTMcJTPU/rk5g4sRxznBeHe/1ppEk=";
          };
        };
        vim-svelte-plugin = pkgs.vimUtils.buildVimPlugin {
          name = "vim-svelte-plugin";
          src = pkgs.fetchFromGitHub {
            owner = "leafOfTree";
            repo = "vim-svelte-plugin";
            rev = "fcc81292340c0969e83131021c5a6c9aa0c741dc";
            hash = "sha256-WGM21vSuqX8SDu3KCuJBjSCd4dZpeJYpEOHuuZK4T30=";
          };
        };
      in
      [
        {
          # smart-open requires a path to sqlite, we have to do that here because the
          # path will not stay the same when we use nix
          plugin = pkgs.vimPlugins.sqlite-lua;
          config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
            if isLinux then "so" else "dylib"
          }'";
        }

        telescope-fzf-native-nvim
        zig-vim
        bufferline-nvim
        vim-illuminate
        telescope-nvim
        telescope-dap-nvim
        leap-nvim
        gitsigns-nvim
        nvim-surround
        kanagawa-nvim
        targets-vim
        nvim-treesitter
        nvim-treesitter.withAllGrammars
        nvim-treesitter-textobjects
        nvim-lspconfig
        nvim-tree-lua
        nvim-web-devicons
        lualine-nvim
        nvim-cmp
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-cmdline
        cmp-path
        cmp_luasnip
        luasnip
        comment-nvim
        typescript-vim
        refactoring-nvim
        plenary-nvim
        nvim-treesitter-textobjects
        text-case-nvim
        vim-just
        copilot-vim
        nvim-dap

        vim-svelte-plugin
        smart-open
      ];
    extraLuaConfig = ''
      lldb_vscode_path = '${pkgs.lldb_18}/bin/lldb-dap'
      require "nvim-init"
    '';
  };
}
