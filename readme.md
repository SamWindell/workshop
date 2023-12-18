Prerequists:
- Install nix
- [enable flakes](https://nixos.wiki/wiki/Flakes)


```bash
cd ~/
mkdir -p .config
git clone https://github.com/samwindell/home-config home-manager
nix run home-manager/master switch
# or home-manager switch
```

Handy notes-to-self:
- Run `home-manager switch` when you change the nix config to apply the changes.
- Run `command & detach` to run the program detached: the terminal doesn't wait for it to stop.
- Handy web search for home-manager options: [mipmip search](https://mipmip.github.io/home-manager-option-search/)
- `manix` is a CLI tool for searching Nix documentation. Couldn't get it work though.
- `gnome.eog` seems like a capable image-viewer

### Notes regarding git + GitHub CLI config
I tried getting home-manager to manage git's config file `~/.config/git/config`. But there was a problem when using this in conjuction with `gh` (GitHub CLI) to authenticate myself to access private git repos. This was done by enabling `programs.gh.enable = true;` and `programs.git.enable = true; programs.git.extraConfig {...}`. The problem is that `gh` requires write-access to it's own config file as well as git's config file. But that's not possible because nix manages them though symlinks. It's mainly a problem because `gh` seems like the easist way to login to GitHub. `git-credential-manager` didn't work on my system due to GUI issues.

