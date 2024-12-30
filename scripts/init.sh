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

# Tab completion for dgui
_dgui_completion() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=($(compgen -c -- "$cur"))
    else
        COMPREPLY=($(compgen -f -- "$cur"))
    fi
}
complete -F _dgui_completion dgui
