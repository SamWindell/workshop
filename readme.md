# My development environment, managed using Nix & home-manager
The goal is to be able to have a consistent fully-featured, powerful work setup for all of my computers: Linux, macOS and WSL (sadly not native Windows). Most of this configuration focuses on a terminal-based workflow but there's a `withGui` flag too. I've made this public in case it's useful for others to take ideas from; take any parts you like for your own setup.

The nixos folder also contains configuration for a NixOS system; which is designed to work alongside this standalone home-manager setup.

### Key tools:
- Neovim with packages & dependencies managed by nix rather than things like lazy.nvim and mason.
- Zellij
- Modern command-line utilities: ripgrep, fd, fzf, ast-grep, and many more
- Programming language tools: zig, clang, nodejs, and many more

## Installing
- Install nix
- [Enable flakes](https://nixos.wiki/wiki/Flakes)
- Install home-manager
- Run commands below

```bash
cd
mkdir -p .config
cd .config
git clone https://github.com/samwindell/home-config home-manager

# first run:
nix run home-manager/release-24.11 -- init --switch
# any subsequent
home-manager switch --flake .#<configuration>

# rebuilding nixos:
cd /etc/nixos
sudo nixos-rebuild switch --flake .#<configuration>
```

## Notes-to-self
### Shell
- Run `command & detach` to run a program detached: the terminal doesn't wait for it to stop.
- Ctrl+A: Go to start of line
- Ctrl+E: Go to end of line
- Ctrl+W: Erase 1 word backwards
- Alt+D: Erase 1 word forwards
- Ctrl+U: Erase to start of line
- Ctrl+K: Erase to end of line
- Ctrl+Y: Paste what you just erased
- `git clone --filter=blob:none <url>` creates a blobless clone. It only downloads old versions of files on-demand rather than immediately. Useful when the git history contains lots of large binary files that you don't currently need.
### Nix
- Handy web search for home-manager options: [mipmip search](https://mipmip.github.io/home-manager-option-search/)
- `manix` is a CLI tool for searching Nix documentation. Couldn't get it work though.
- Note: "for flakes in git repos, only files in the working tree will be copied to the store. Therefore, if you use git for your flake, ensure to git add any project files after you first create them".
- [NixOS wiki](https://nixos.wiki/wiki/Main_Page) is good.
- [Nix search](https://search.nixos.org/packages) is good for both packages and NixOS configuration.nix options.
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) is good.
- `nix shell nixpkgs/<branch>#<package>` to enter a shell with a package available. (modern version of `nix-shell -p <package>`)
- ALT+c is a fzf bash-integration feature to search all subdirs and `cd` into it.
- To add custom packages, you can use nix-init to generate a default.nix. Let's say we put the default.nix in a folder `my-program-nightly`; in the flake.nix you can than call this package using something like: `my-program = pkgs.callPackage ./my-program-nightly { inherit (pkgs.darwin.apple_sdk.frameworks) Carbon Cocoa ScriptingBridge; };`. This seems to be roughly the same technique used in the nixpkgs repo: we can use that as a reference.

### Notes regarding wezterm (May 2024)
Wezterm would not work on my NixOS wayland system on the nixpkgs 23.11 channel. However, on the unstable channel it would at least run, but there were issues where the GUI would not update promptly. It wasn't usable. After trying various things, I gave up on it. It seems too unstable on a Hyprland wayland system.

### Notes regarding git + GitHub CLI config (December 2023)
I tried getting home-manager to manage git's config file `~/.config/git/config`. But there was a problem when using this in conjunction with `gh` (GitHub CLI) to authenticate myself to access private git repos. This was done by enabling `programs.gh.enable = true;` and `programs.git.enable = true; programs.git.extraConfig {...}`. The problem is that `gh` requires write-access to it's own config file as well as git's config file. But that's not possible because nix manages them though symlinks. It's mainly a problem because `gh` seems like the easiest way to login to GitHub. `git-credential-manager` didn't work on my system due to GUI issues. To workaround this I'm not using these options and so have to manually configure git username+email per machine.

### Notes on yabridge (August 2024)
yabridgectl cannot add yabridge.toml to ~/.nix-profile/lib/clap because the file system is read-only. Not putting any more time into it for now.

### Using firefox effectively
Firefox has some pretty good built-in features for quickly searching bookmarks and history. Go to menu -> bookmarks -> manage bookmarks. You can set tags and keywords for each bookmark. You can just type a keyword in the search bar and hit enter to open it. Additionally the search bar is a fuzzy-finder. Hit CTRL+L to enter the search bar. There are a few prefixes that change the search domain. `*<space>` will filter searches to bookmarks. Some examples:
- `CTRL+t`: new tab -> `CTRL+l`: open search bar -> `my-keyword<enter>`: opens bookmark with the keyword 'my-keyword'.
- `CTRL+l`: open search bar -> `* `: change to bookmark search -> `a<tab><enter>`: fuzzy-finds bookmarks with 'a', selects the first result, opens it.

