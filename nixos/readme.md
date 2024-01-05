# NixOS config
This is not part of the home configuration. Instead, it is designed to be symlinked as /etc/nixos:
```
sudo mv /etc/nixos /etc/nixos.bak  # Backup the original configuration
sudo ln -s ~/.config/home-manager/nixos/ /etc/nixos

# Deploy the flake.nix located at the default location (/etc/nixos)
sudo nixos-rebuild switch
```
