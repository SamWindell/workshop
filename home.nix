{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (specialArgs) withGui;
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

  home.packages = [
    pkgs.rename # rename files: rename "s/foo/bar/" *.png
    pkgs.sox # audio file manipulation
    pkgs.imagemagick # image file manipulation
    pkgs.ffmpeg # video/audio manipulaiton
    pkgs.fd # find alternative, run fd -h for consise help
    pkgs.gnused # replace e.g.: sed -s "s/foo/bar/g" file.txt
    pkgs.ast-grep # powerful grep for code https://ast-grep.github.io/
    pkgs.sad # better sed

    pkgs.cmake
    pkgs.ninja
    pkgs.llvmPackages_17.clang-unwrapped # clangd
    pkgs.python3

    pkgs.nixd # nix LSP
    pkgs.nixpkgs-fmt # nix code formatting
    pkgs.nurl # command-line tool to generate Nix fetcher calls from repository URLs

    pkgs.sqlite # needed by nvim smart-open plugin
    pkgs.lua-language-server
    pkgs.nodejs_21
    pkgs.cmake-language-server
    pkgs.nodePackages.svelte-language-server
    pkgs.nodePackages.prettier
    pkgs.nodePackages.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.python3Packages.python-lsp-server
    pkgs.cmake-format

    pkgs.gh
    pkgs.git

    specialArgs.overlays.zig.master-2023-12-01

    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # TODO: add more proper layouts
    (pkgs.writeShellScriptBin "obsi" ''
      zellij action new-tab --layout ${./zellij/obsi.kdl}
    '')
  ] ++ pkgs.lib.optionals (isLinux && withGui) [
    pkgs.thunderbird
    pkgs.loupe
    pkgs.gnome.nautilus
    pkgs.wl-clipboard # needed to get neovim clipboard working
    pkgs.discord
    pkgs.waybar
    pkgs.firefox
    pkgs.appimage-run # `appimage-run foo.AppImage` https://nixos.wiki/wiki/Appimage
    (pkgs.nerdfonts.override { fonts = [ "Ubuntu" ]; })
    pkgs.bitwarden
    pkgs.obsidian
    pkgs.vlc
  ] ++ pkgs.lib.optionals withGui [
  ];

  home.file = {
    # # You can also set the file content immediately.
    # ".config/hypr/hyprpaper.conf".text = ''
    #   preload = ${wallpaper_path}
    #   wallpaper = ,${wallpaper_path}
    # '';

    ".config/nvim/lua/".source = ./nvim;
    ".config/starship.toml".source = ./starship.toml;
    ".config/alacritty/alacritty.yml".source = ./alacritty.yml; # TODO: remove
    ".config/waybar/".source = ./waybar;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  programs.kitty = mkIf withGui {
    enable = true;
    theme = "kanagawabones";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  # NOTE: NixOS only. You must also set programs.hyprland.enable = true in /etc/nixos/configuration.nix.
  wayland.windowManager.hyprland = mkIf (isLinux && withGui) {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true;
    extraConfig = ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=,2560x1440@120,auto,auto

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      exec-once = waybar

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,24

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
              enabled = true
              size = 3
              passes = 1
          }

          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
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
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true
      }

      misc {
          force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
          disable_hyprland_logo = true
          disable_splash_rendering = true
          background_color = 0x090909
      }

      windowrulev2 = workspace 1,class:(kitty)
      windowrulev2 = workspace 2,class:(discord)
      windowrulev2 = workspace 3,class:(firefox)

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, return, exec, kitty
      bind = $mainMod, Q, killactive, 
      bind = $mainMod, M, exit, 
      bind = $mainMod, V, togglefloating, 
      bind = $mainMod, D, exec, rofi -show drun -show-icons
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

      binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      binde=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      # IMPROVE: add controls for mute
    '';
  };

  # is pkgs.libnotify needed?
  services.dunst = mkIf (isLinux && withGui) {
    enable = true;
  };

  programs.rofi = mkIf (isLinux && withGui) {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "purple";
  };

  gtk = mkIf (isLinux && withGui) {
    enable = true;
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  programs.bash = {
    enable = true;
    bashrcExtra = mkIf isLinux ''
      #PATH=/home/sam/.cargo/bin:$PATH
      #PATH=/home/sam/bin:$PATH
    '';
    shellAliases = {
      # TODO: remove these. and add things like '.. = cd ..' ?
      nvd = "neovide --multigrid";
      froz = "nvd ~/Projects/frozencode";
      hm = "home-manager";
    };
  };

  # fancy command history in bash
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  # fuzzy search. this also enables integration with bash e.g.: `nvim **<TAB>`
  programs.fzf = {
    enable = true;
  };

  # run zellij setup --dump-config to see the default config
  programs.zellij = {
    enable = true;
    # Let's avoid auto-start for now. For one thing, it behaves strangly when starting Hyprland from TTY
    enableBashIntegration = false;
    settings = {
      theme = "kanagawa";
    };
  };

  # nicer grep
  programs.ripgrep.enable = true;

  # nicer prompt
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    delta.enable = true; # use the delta program for diff syntax highlighting
  };

  # better ls
  programs.eza = {
    enable = true;
    enableAliases = true;
    icons = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins;
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
            rev = "612b34640919c29b5cf2d85289dbc762b099858a";
            hash = "sha256-YmIKDicfn9GZiLp3rvYEEFT2D4KQZoKbJ2HPrdqcLLw=";
          };
        };
      in
      [
        {
          # smart-open requires a path to sqlite, we have to do that here because the 
          # path will not stay the same when we use nix
          plugin = pkgs.vimPlugins.sqlite-lua;
          config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${if isLinux then "so" else "dylib"}'";
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
        telescope-dap-nvim
        nvim-dap
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

        vim-svelte-plugin
        smart-open
      ];
    # As of now (December 2023) the vscode-llbd package in NixPkgs fails to compile on arm64 macOS so instead we're using the package from vscode-extensions.
    extraLuaConfig = ''
      codelldb_path = '${specialArgs.vscode-extensions.vadimcn.vscode-lldb.out}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb'
      require "nvim-init"
    '';
  };

}
