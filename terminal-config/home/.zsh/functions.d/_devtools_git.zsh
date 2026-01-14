#!/bin/zsh
# ============================================================================
# Git Helper Functions
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom functions, create your own file without _devtools_ prefix
# ============================================================================

# Clear conflicting aliases from oh-my-zsh git plugin
unalias gbd gbD gclean gcob gfb gwip gunwip gcom gpush gdiff 2>/dev/null

# gcob - Git checkout new branch
# Usage: gcob <branch-name>
gcob() {
    if [[ -z "$1" ]]; then
        echo "Usage: gcob <branch-name>"
        return 1
    fi
    git checkout -b "$1"
}

# gbd - Git branch delete (with confirmation)
# Usage: gbd <branch-name>
gbd() {
    if [[ -z "$1" ]]; then
        echo "Usage: gbd <branch-name>"
        return 1
    fi
    echo "Delete branch '$1'? (y/n)"
    read -q && git branch -d "$1"
    echo ""
}

# gbD - Git branch force delete (with confirmation)
# Usage: gbD <branch-name>
gbD() {
    if [[ -z "$1" ]]; then
        echo "Usage: gbD <branch-name>"
        return 1
    fi
    echo "FORCE delete branch '$1'? (y/n)"
    read -q && git branch -D "$1"
    echo ""
}

# gfb - Git fetch and checkout branch (from remote)
# Usage: gfb <branch-name>
gfb() {
    if [[ -z "$1" ]]; then
        echo "Usage: gfb <branch-name>"
        return 1
    fi
    git fetch origin "$1" && git checkout "$1"
}

# gclean - Clean merged branches (except main/master/develop)
# Usage: gclean [--dry-run]
gclean() {
    local dry_run=""
    [[ "$1" == "--dry-run" ]] && dry_run="echo Would delete:"

    git branch --merged | grep -vE '^\*|main|master|develop' | while read branch; do
        if [[ -n "$dry_run" ]]; then
            echo "Would delete: $branch"
        else
            git branch -d "$branch"
        fi
    done
}

# gwip - Git work in progress commit
# Usage: gwip [message]
gwip() {
    git add -A
    git commit -m "WIP: ${1:-work in progress}"
}

# gunwip - Undo last WIP commit (keeps changes staged)
# Usage: gunwip
gunwip() {
    local last_msg=$(git log -1 --pretty=%s)
    if [[ "$last_msg" == WIP:* ]]; then
        git reset --soft HEAD~1
        echo "Undid WIP commit, changes are staged"
    else
        echo "Last commit is not a WIP commit: $last_msg"
        return 1
    fi
}

# gcom - Quick git add all and commit
gcom() {
    git add -A && git commit -m "$*"
}

# gpush - Quick git add, commit, and push
gpush() {
    git add -A && git commit -m "$*" && git push
}

# gdiff - Git diff with delta
gdiff() {
    git diff "$@" | delta
}

# ============================================================================
# Self-test function (used by devsetup test)
# ============================================================================
_test_devtools_git() {
    local passed=0 failed=0

    # Test that functions are defined
    for func in gcob gbd gbD gfb gclean gwip gunwip; do
        if typeset -f "$func" > /dev/null 2>&1; then
            ((passed++))
        else
            echo "FAIL: $func not defined"
            ((failed++))
        fi
    done

    # Test git is available
    if command -v git > /dev/null 2>&1; then
        ((passed++))
    else
        echo "FAIL: git not installed"
        ((failed++))
    fi

    echo "Git functions: $passed passed, $failed failed"
    return $failed
}
