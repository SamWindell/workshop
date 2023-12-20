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
    pkgs.vscode-extensions.vadimcn.vscode-lldb # CodeLLDB nvim extension
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
    EDITOR = "nvim";
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
    tmux.enableShellIntegration = true;
  };

  # nicer grep
  programs.ripgrep.enable = true;

  # nicer prompt
  programs.starship.enable = true;

  programs.git = {
    enable = true;
    delta.enable = true; # use the delta program for diff syntax highlighting
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    # customPaneNavigationAndResize = true;
    plugins = [
      pkgs.tmuxPlugins.tmux-fzf
    ];
    extraConfig = ''
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?\.?(view|n?vim?x?)(-wrapped)?(diff)?$'"

      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
      bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
      bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
      bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'

      bind-key -T copy-mode-vi M-h resize-pane -L 1
      bind-key -T copy-mode-vi M-j resize-pane -D 1
      bind-key -T copy-mode-vi M-k resize-pane -U 1
      bind-key -T copy-mode-vi M-l resize-pane -R 1
    '';
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
          config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
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
        tmux-nvim

        vim-svelte-plugin
        smart-open
      ];
    extraLuaConfig = ''
      codelldb_path = '${pkgs.vscode-extensions.vadimcn.vscode-lldb.out}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb'
      require "nvim-init"
    '';
  };

}
