default:
    home-manager switch --flake .#pcLinux
    # You must run nvim like this: nvim --listen ~/.cache/nvim/server.pipe;
    nvim --server ~/.cache/nvim/server.pipe --remote-send " rc" 
