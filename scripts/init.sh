# Change dir with Fuzzy finding
cf() {
    dir=$(fd . ${1:-$HOME} --type d 2>/dev/null | fzf)
    cd "$dir"
}

# ls after cd
cd() { builtin cd "$@" && ls . ; }

# Tab completion for dgui in quick_utils
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
