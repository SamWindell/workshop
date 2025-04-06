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

  mimeTypes = import ./mime-types.nix;

  wezterm = inputs.wezterm.packages.${pkgs.system}.default;

  # we have nixpkgs-unstable in input and we want to use it for neovim
  neovim-unwrapped = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.neovim-unwrapped;

  tracy-wayland = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.tracy-wayland;
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
      pkgs.parallel

      pkgs.cmake
      pkgs.ninja
      pkgs.llvmPackages.clang
      pkgs.llvmPackages.clang-unwrapped
      pkgs.llvmPackages.libllvm
      pkgs.lldb_18
      pkgs.python3
      pkgs.just
      pkgs.awscli2
      pkgs.optipng

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
      pkgs.yaml-language-server

      pkgs.gh
      pkgs.git
      pkgs.rclone

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

      pkgs.zig
      pkgs.zls

      pkgs.hunspell
      pkgs.hunspellDicts.en_GB-ise

      (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ]
    ++ pkgs.lib.optionals (isLinux && withGui) [
      pkgs.loupe # gnome image viewer
      pkgs.sushi # gnome file previewer
      pkgs.wl-clipboard # needed to get neovim clipboard working
      pkgs.vesktop # discord
      pkgs.waybar
      pkgs.firefox
      pkgs.hyprpicker
      pkgs.google-chrome
      pkgs.appimage-run # `appimage-run foo.AppImage` https://nixos.wiki/wiki/Appimage
      pkgs.inkscape
      pkgs.adwaita-icon-theme
      pkgs.vlc
      pkgs.obsidian
      pkgs.sublime-merge
      pkgs.libreoffice
      pkgs.xdg-utils # xdg-open
      pkgs.gnome-system-monitor
      pkgs.blueberry # bluetooth manager
      pkgs.bemoji
      pkgs.wtype
      pkgs.hyprshot # screenshot tool
      pkgs.slurp # screen selection tool needed by record-screen
      pkgs.wf-recorder # screen recording tool

      tracy-wayland

      pkgs.playerctl # used by waybar
      pkgs.zenity # used by waybar

      # fonts
      (pkgs.nerdfonts.override { fonts = [ "Ubuntu" ]; })
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
      pkgs.noto-fonts-emoji
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

        meta = with lib; {
          description = "Outfit Fonts";
          homepage = "https://github.com/Outfitio/Outfit-Fonts";
          license = licenses.ofl;
          maintainers = [ ];
          platforms = platforms.all;
        };
      })

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
      pkgs.musescore
      pkgs.bitwig-studio
      pkgs.zrythm
      pkgs.qtractor

      (pkgs.writeShellScriptBin "colour-picker" ''
        colour=$(hyprpicker -a)
        notify-send "Colour Picker" "$colour copied to clipboard"
      '')

      (pkgs.writers.writeBashBin "firefox-bookmarks" { } (
        builtins.readFile ./scripts/firefox-bookmarks.sh
      ))

      (pkgs.writeShellScriptBin "pick-firefox-bookmark" ''
        selected=$(firefox-bookmarks --list menu | sed 's|^menu/||' | fuzzel --dmenu) 
        [ -z "$selected" ] && exit 0
        firefox-bookmarks --url "menu/$selected" | xargs firefox
        hyprctl dispatch workspace 3 
      '')

      (pkgs.writeShellScriptBin "search-web" ''
        query=$(fuzzel --dmenu --prompt-only "Web search: " --width 50)
        [ -z "$query" ] && exit 0
        encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
        firefox --new-tab "https://www.google.com/search?q=''${encoded_query}"
        hyprctl dispatch workspace 3
      '')

      (pkgs.writers.writePython3Bin "weekly-note-review" {
        libraries = with pkgs.python3Packages; [ watchdog ];
        doCheck = false;
      } (builtins.readFile ./scripts/weekly-note-review.py))

      (pkgs.writers.writeBashBin "pick-symbol" { } (builtins.readFile ./scripts/pick-symbol.sh))
      (pkgs.writers.writeBashBin "take-screenshot" { } (builtins.readFile ./scripts/take-screenshot.sh))
      (pkgs.writers.writeBashBin "record-screen" { } (builtins.readFile ./scripts/record-screen.sh))
    ]
    ++ pkgs.lib.optionals withGui [
      pkgs.keepassxc
      wezterm
    ]
    ++ pkgs.lib.optionals isLinux [
      pkgs.wineWow64Packages.waylandFull
    ]
    ++ pkgs.lib.optionals isDarwin [
      pkgs.tracy
    ];

  fonts.fontconfig.enable = true;

  home.file = {
    # mkOutOfStoreSymlink is a handy trick to allow apps to reload their config files without
    # needing to `home-manager switch`
    ".config/nvim/lua/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    ".config/wezterm/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/wezterm";
    ".config/starship.toml".source = ./starship/starship.toml;
    ".config/waybar/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/waybar";
    # nautilus extensions is configured in nixos-configuration.nix
    ".local/share/nautilus-python/extensions/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nautilus";
    ".config/fd/ignore".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/search-ignore";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.bashInteractive}/bin/bash";
    TERMINAL = "wezterm";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.config/home-manager/quick-utils"
  ];

  programs.home-manager.enable = true;

  xdg = {
    desktopEntries = mkIf (isLinux && withGui) {
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
      "wezterm-nvim" = {
        name = "Wezterm Neovim";
        icon = "nvim";
        exec = "wezterm start -- nvim %F";
        terminal = false;
        categories = [ "Development" ];
        comment = "Open Neovim in Wezterm";
        genericName = "Text Editor";
        type = "Application";
        mimeType = mimeTypes.sourceCodeTypes;
      };
      # this is purely to override the default nvim desktop entry - we want
      # no mimeTypes and noDisplay to be true
      "nvim" = {
        name = "Neovim";
        icon = "nvim";
        exec = "nvim %F";
        terminal = false;
        categories = [ "Development" ];
        comment = "Open Neovim";
        genericName = "Text Editor";
        type = "Application";
        mimeType = [
        ];
        noDisplay = true;
      };
    };
  };

  # You must also set programs.hyprland.enable = true in /etc/nixos/configuration.nix.
  wayland.windowManager.hyprland = mkIf (isLinux && withGui) {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
    plugins = [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.hyprlandPlugins.hyprbars
    ];
    extraConfig = ''
      source = ~/.config/home-manager/hypr/config.conf
    '';
  };

  services.hyprpaper = mkIf (isLinux && withGui) {
    enable = true;
    settings = {
      ipc = "off";
      preload = [
        "~/Pictures/wallpaper.jpg"
      ];

      wallpaper = [
        "DP-4,~/Pictures/wallpaper.jpg"
      ];
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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  services.megasync.enable = isLinux && withGui; # cloud sync program
  systemd.user.services.megasync = mkIf (isLinux && withGui) {
    Service = {
      ExecStart = "${config.services.megasync.package}/bin/megasync";
      Restart = "always";
      RestartSec = 3;
      Type = "simple";
      Environment = [
        "PATH=${pkgs.xorg.xrdb}/bin:${config.home.profileDirectory}/bin"
      ];
      # Inherit environment variables from user session
      PassEnvironment = [
        "XDG_CURRENT_DESKTOP"
        "WAYLAND_DISPLAY"
        "XDG_SESSION_TYPE"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # notifications
  services.swaync = mkIf (isLinux && withGui) {
    enable = true;
    settings = {
      scripts = {
        play-sound = {
          exec = "${pkgs.sox}/bin/play ${sounds/definite-555.ogg}";
          app-name = ".*";
        };
      };
    };
  };

  # picker
  programs.fuzzel = mkIf (isLinux && withGui) {
    enable = true;
    settings = {
      colors = {
        background = "1e1e2eff";
        text = "cdd6f4ff";
        prompt = "bac2deff";
        placeholder = "7f849cff";
        input = "cdd6f4ff";
        match = "cba6f7ff";
        selection = "585b70ff";
        selection-text = "cdd6f4ff";
        selection-match = "cba6f7ff";
        counter = "7f849cff";
        border = "cba6f7ff";
      };
    };
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
        source "${./scripts/init.sh}"
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
    defaultOptions = [
      "--bind ctrl-a:toggle-all"
    ];
  };

  # better cd
  programs.zoxide = {
    enable = true;
  };

  # nicer grep
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--ignore-file=${config.home.homeDirectory}/.config/home-manager/search-ignore"
    ];
  };

  # nicer prompt
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    delta.enable = true; # use the delta program for diff syntax highlighting
    userName = "Sam Windell";
    userEmail = "info@frozenplain.com";
    # https://blog.gitbutler.com/how-git-core-devs-configure-git/
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
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
    package = neovim-unwrapped;
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
        visual-whitespace = pkgs.vimUtils.buildVimPlugin {
          name = "visual-whitespace";
          src = pkgs.fetchFromGitHub {
            owner = "mcauley-penney";
            repo = "visual-whitespace.nvim";
            rev = "31d0ed71ad7e376879d7e0df0c8cc4f1467702d4";
            hash = "sha256-W8ZzGdm1bYNt6vUKI6WJ5zh+wL+0SXFuIp6tQun7iVA=";
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
        nvim-notify
        cmp-dap

        vim-svelte-plugin
        smart-open
        visual-whitespace
      ];
    extraLuaConfig = ''
      lldb_vscode_path = '${pkgs.lldb_18}/bin/lldb-dap'
      require "nvim-init"
    '';
  };
}
