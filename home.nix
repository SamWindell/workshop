{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (specialArgs) withGui;

  zig = specialArgs.zig."0.13.0";
  zls = specialArgs.zls.zls.overrideAttrs (prev: {
    nativeBuildInputs = [ zig ];
  });
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

      # IMPROVE: add more proper layouts
      (pkgs.writeShellScriptBin "obsi" ''
        zellij action new-tab --layout ${./zellij/obsi.kdl}
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
      specialArgs.hyprland-contrib.grimblast # screenshot helper
      pkgs.xdg-utils # xdg-open
      pkgs.gnome-system-monitor
      pkgs.blueberry # bluetooth manager
      pkgs.quickemu
      pkgs.musescore

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
    # # You can also set the file content immediately.
    # ".config/hypr/hyprpaper.conf".text = ''
    #   preload = ${wallpaper_path}
    #   wallpaper = ,${wallpaper_path}
    # '';

    ".config/nvim/lua/".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/nvim";
    ".config/starship.toml".source = ./starship.toml;
    ".config/waybar/".source = ./waybar;
    ".config/zellij/config.kdl".source = ./zellij/config.kdl;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "bash";
  };

  programs.home-manager.enable = true;

  programs.kitty = mkIf withGui {
    enable = true;
    themeFile = "kanagawabones";
    shellIntegration.enableBashIntegration = true;
    settings = {
      shell = mkIf isDarwin "bash --login";
      macos_option_as_alt = "left";
      term = "xterm-256color";
      tab_bar_style = "separator";
      tab_bar_edge = "top";
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  # NOTE: NixOS only. You must also set programs.hyprland.enable = true in /etc/nixos/configuration.nix.
  wayland.windowManager.hyprland = mkIf (isLinux && withGui) {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
    extraConfig = ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=DP-4,2560x1440@120,auto,auto,vrr,1
      monitor=Unknown-1,disable
      monitor=,preferred,auto,1 # default for everything else

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      exec-once = uwsm app -- waybar
      exec-once = uwsm app -- vesktop
      exec-once = uwsm app -- keepassxc

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =

          follow_mouse = 1

          repeat_rate = 35 # repeats per second
          repeat_delay = 300 # milliseconds before repeatings

          touchpad {
              natural_scroll = no
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 0
          gaps_out = 0
          border_size = 2
          col.active_border = rgba(606060ff)
          col.inactive_border = rgba(00000080)

          layout = dwindle

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false
      }

      decoration {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 4 

          blur {
              enabled = false
              size = 3
              passes = 1
          }
      }

      animations {
          enabled = yes

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

          bezier = myBezier, 0.05, 0.9, 0.1, 1.05

          animation = windows, 1, 3, myBezier
          animation = windowsOut, 1, 3, default, popin 80%
          animation = border, 1, 5, default
          animation = borderangle, 1, 3, default
          animation = fade, 1, 3, default
          animation = workspaces, 1, 2, default
      }

      dwindle {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }

      master {
          new_status = master
      }

      misc {
          force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
          disable_hyprland_logo = true
          disable_splash_rendering = true
          background_color = 0x090909
          mouse_move_enables_dpms = true
          key_press_enables_dpms = true
      }

      # run hyprctl clients to see class names of current clients
      windowrulev2 = workspace 1,class:(kitty)
      windowrulev2 = workspace 2,class:(vesktop)
      windowrulev2 = workspace 2,class:(Zulip)
      windowrulev2 = workspace 3,class:(firefox)
      windowrulev2 = workspace 3,class:(brave)
      windowrulev2 = workspace 4,class:(thunderbird)
      windowrulev2 = workspace 5,class:(sublime_merge)
      windowrulev2 = workspace 6,class:(obsidian)
      windowrulev2 = workspace 2,tile,class:(Tracy Profiler.*)
      windowrulev2 = workspace 10,class:(org.keepassxc.KeePassXC)

      windowrulev2 = stayfocused, class:^(pinentry-) # fix pinentry losing focus

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, return, exec, uwsm app -- kitty zellij
      bind = $mainMod, X, exec, uwsm app -- kitty -d ~/MEGA/Obsidian nvim "Personal Organisation/Thought Capture.md"
      bind = $mainMod, Q, killactive, 
      bind = $mainMod, M, exit, 
      bind = $mainMod, V, togglefloating, 
      bind = $mainMod, D, exec, uwsm app -- rofi -show drun -show-icons
      bind = $mainMod, E, exec, uwsm app -- rofi -modi emoji -show emoji
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, I, togglesplit, # dwindle

      # Move focus with mainMod + arrow keys
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Example special workspace (scratchpad)
      bind = $mainMod, S, togglespecialworkspace, magic
      bind = $mainMod SHIFT, S, movetoworkspace, special:magic

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      binde=, XF86AudioRaiseVolume, exec, uwsm app -- wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      binde=, XF86AudioLowerVolume, exec, uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      # IMPROVE: add controls for mute

      # IMPROVE: add more screenshot options for example grimblast edit to screenshot and then edit in gimp
      bind = , PRINT, exec, uwsm app -- ${specialArgs.hyprland-contrib.grimblast}/bin/grimblast --notify --freeze copysave area
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  services.swayidle = mkIf (isLinux && withGui) {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      {
        timeout = 100; # seconds
        # absolute path is needed
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  services.megasync.enable = isLinux && withGui; # cloud sync program

  # is pkgs.libnotify needed?
  services.swaync = mkIf (isLinux && withGui) {
    enable = true;
  };

  programs.rofi = mkIf (isLinux && withGui) {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ./rofi/dracula.rasi;
    plugins = [
      pkgs.rofi-emoji-wayland
    ];
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
        export FZF_DEFAULT_OPTS='--bind ctrl-a:toggle-all'

        hyp() {
          exec systemd-cat -t uwsm_start uwsm start default
        }

        cd() { builtin cd "$@" && ls . ; }

        hms() {
          home-manager switch --flake ~/.config/home-manager/flake.nix#''${1:-pcLinux};
        }
          
        # fixes a neovim issue with smart_open plugin taking a long time to open
        clnvim() {
          rm -f ~/.local/share/nvim/telescope_history
          rm -f ~/.local/share/nvim/smart_open.sqlite3
          rm -f ~/.local/state/nvim/shada/main.shada
        }

        # diff 2 binary files
        bindiff() {
          colordiff -y <(xxd "$1") <(xxd "$2")
        }

        floe() {
          cd ~/Projects/floe
          nix develop
        }

        # Change dir with Fuzzy finding
        cf() {
          dir=$(fd . ''${1:-$HOME} --type d 2>/dev/null | fzf)
          cd "$dir"
        }

        # Search content and Edit
        se() {
          rg --files-with-matches "$1" | sad "$1" "$2"
        }

        # Search multiline content and Edit
        sme() {
          rg --multiline --files-with-matches "$1" | sad --flags m "$1" "$2"
        }

        # Search git log, preview shows subject, body, and diff
        fl() {
          git log --oneline --color=always | fzf --ansi --preview="echo {} | cut -d ' ' -f 1 | xargs -I @ sh -c 'git log --pretty=medium -n 1 @; git diff @^ @' | bat --color=always" | cut -d ' ' -f 1 | xargs git log --pretty=short -n 1
        }

        eval "$(zellij setup --generate-completion bash)"
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

  # run zellij setup --dump-config to see the default config
  programs.zellij = {
    enable = true;
    # Let's avoid auto-start for now. For one thing, it behaves strangly when starting Hyprland from TTY
    enableBashIntegration = false;
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
        kdl-vim = pkgs.vimUtils.buildVimPlugin {
          name = "kdl.vim";
          src = pkgs.fetchFromGitHub {
            owner = "imsnif";
            repo = "kdl.vim";
            rev = "b84d7d3a15d8d30da016cf9e98e2cfbe35cddee5";
            hash = "sha256-IajKK1EjrKs6b2rotOj+RlBBge9Ii2m/iuIuefnjAE4=";
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
        which-key-nvim
        typescript-vim
        neodev-nvim
        refactoring-nvim
        plenary-nvim
        nvim-treesitter-textobjects
        text-case-nvim
        vim-just
        copilot-vim
        nvim-dap

        vim-svelte-plugin
        smart-open
        kdl-vim

        # ccc-nvim # color highlighter and picker
        # nvim_context_vt # show function/scope/block in a 'comment' after any } or ]
      ];
    extraLuaConfig = ''
      lldb_vscode_path = '${pkgs.lldb_18}/bin/lldb-dap'
      require "nvim-init"
    '';
  };
}
