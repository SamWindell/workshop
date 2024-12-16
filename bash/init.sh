export FZF_DEFAULT_OPTS='--bind ctrl-a:toggle-all'

hyp() {
    exec systemd-cat -t uwsm_start uwsm start default
}

# New Tab Neovim. Use provided path or current directory path
ntn() {
    local target="$(readlink -f "${1:-$(pwd)}")"  # Convert to absolute path
    wezterm cli spawn -- nvim "$target"
}

# New Window Neovim. Use provided path or current directory path
nwn() {
    local target="$(readlink -f "${1:-$(pwd)}")"  # Convert to absolute path
    wezterm cli spawn --new-window -- nvim "$target"
}

cd() { builtin cd "$@" && ls . ; }

hms() {
    home-manager switch --flake ~/.config/home-manager/#${1:-pcLinux};
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
    dir=$(fd . ${1:-$HOME} --type d 2>/dev/null | fzf)
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
