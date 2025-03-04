default:
    #!/usr/bin/env bash
    config={{ if os() == "macos" { "macbook" } else { "pcLinux" } }}
    if [[ "$(uname -r)" == *microsoft* ]]; then
        config="pcWsl"
        
        # Get Windows username properly using PowerShell
        windows_username=$(powershell.exe -Command '$env:USERNAME' | tr -d '\r')
        
        echo "Windows username: $windows_username"
        
        # Ensure source file exists
        if [ -f "wezterm/wezterm.lua" ]; then
            cp wezterm/wezterm.lua /mnt/c/Users/$windows_username/.wezterm.lua
            echo "Config copied to /mnt/c/Users/$windows_username/.wezterm.lua"
        else
            echo "Error: Source file wezterm/wezterm.lua not found"
        fi
    fi

    echo "Switching to $config"
    home-manager switch --flake .#$config
    # You must run nvim like this: nvim --listen ~/.cache/nvim/server.pipe;
    # nvim --server ~/.cache/nvim/server.pipe --remote-send " rc" 

rebuild:
    #!/usr/bin/env bash
    config="desktop"
    if [[ "$(uname -r)" == *microsoft* ]]; then
        config="wsl"
    fi
    sudo nixos-rebuild switch --flake nixos/#$config
