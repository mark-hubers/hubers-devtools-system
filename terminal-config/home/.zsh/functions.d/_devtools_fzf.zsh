#!/bin/zsh
# ============================================================================
# FZF Helper Functions
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom functions, create your own file without _devtools_ prefix
# ============================================================================

# ff - Find files with preview
# Usage: ff [query]
ff() {
    local file
    file=$(fd --type f --hidden --follow --exclude .git | \
        fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
            --preview-window=right:60% \
            --query="${1:-}")
    [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}

# fh - Search command history
# Usage: fh [query]
fh() {
    local cmd
    cmd=$(history -1 0 | fzf --tac --query="${1:-}" | sed 's/^[ ]*[0-9]*[ ]*//')
    if [[ -n "$cmd" ]]; then
        print -z "$cmd"
    fi
}

# fif - Find in files (grep + fzf)
# Usage: fif <pattern>
fif() {
    if [[ -z "$1" ]]; then
        echo "Usage: fif <search-pattern>"
        return 1
    fi
    local file line
    read file line <<< $(rg --color=always --line-number --no-heading "$1" | \
        fzf --ansi --delimiter=: \
            --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
            --preview-window=right:60%:+{2}-10 | \
        awk -F: '{print $1, $2}')
    [[ -n "$file" ]] && ${EDITOR:-vim} "+$line" "$file"
}

# fkill - Kill process with fzf
# Usage: fkill [signal]
fkill() {
    local pid signal="${1:-9}"
    pid=$(ps -ef | sed 1d | fzf -m --header="Select process(es) to kill" | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -"$signal"
        echo "Killed process(es): $pid"
    fi
}

# fcd - cd with fzf directory picker
# Usage: fcd [starting-dir]
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git "${1:-.}" | \
        fzf --preview 'eza --icons --git --color=always {}' \
            --preview-window=right:50%)
    [[ -n "$dir" ]] && cd "$dir"
}

# ============================================================================
# Self-test function (used by devsetup test)
# ============================================================================
_test_devtools_fzf() {
    local passed=0 failed=0

    # Test that functions are defined
    for func in ff fh fif fkill fcd; do
        if typeset -f "$func" > /dev/null 2>&1; then
            ((passed++))
        else
            echo "FAIL: $func not defined"
            ((failed++))
        fi
    done

    # Test dependencies
    for cmd in fzf fd rg bat; do
        if command -v "$cmd" > /dev/null 2>&1; then
            ((passed++))
        else
            echo "WARN: $cmd not installed (some functions may not work)"
        fi
    done

    echo "FZF functions: $passed passed, $failed failed"
    return $failed
}
