default:
    #!/usr/bin/env bash
    config={{ if os() == "macos" { "macbook" } else { "pcLinux" } }}
    if [[ "$(uname -r)" == *Microsoft ]]; then
        config="pcWsl"
    fi
    home-manager switch --flake .#$config
    # You must run nvim like this: nvim --listen ~/.cache/nvim/server.pipe;
    # nvim --server ~/.cache/nvim/server.pipe --remote-send " rc" 

rebuild:
    sudo nixos-rebuild switch --flake nixos/#desktop
