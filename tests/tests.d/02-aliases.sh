#!/bin/zsh
# ============================================================================
# Alias and Function Tests
# ============================================================================
# Note: Tests check if aliases/functions are DEFINED in config files,
# since child scripts don't inherit parent shell aliases.
# ============================================================================

# Check if alias is defined in zshrc or aliases.d
_alias_defined_in_config() {
    local name="$1"
    # Check .zshrc
    grep -qE "^\s*alias\s+${name}=" "$HOME/.zshrc" 2>/dev/null && return 0
    # Check aliases.d directory
    grep -qE "^\s*alias\s+${name}=" "$HOME/.zsh/aliases.d"/*.zsh 2>/dev/null && return 0
    return 1
}

# Check if function is defined in zsh config files or functions.d
_function_defined_in_config() {
    local name="$1"
    # Check .zshrc and .zsh/*.zsh files
    grep -qE "^${name}\(\)|^function ${name}" "$HOME/.zshrc" "$HOME/.zsh"/*.zsh 2>/dev/null && return 0
    # Check functions.d directory
    grep -qE "^${name}\(\)|^function ${name}" "$HOME/.zsh/functions.d"/*.zsh 2>/dev/null && return 0
    return 1
}

test_aliases() {
    step "Aliases & Functions (checking config files)"

    # Core aliases from .zshrc
    if _alias_defined_in_config "ll"; then
        pass_test "ll alias defined (long list)"
    else
        fail_test "ll alias not defined"
    fi

    if _alias_defined_in_config "la"; then
        pass_test "la alias defined (list all)"
    else
        fail_test "la alias not defined"
    fi

    # Git aliases
    if _alias_defined_in_config "gs"; then
        pass_test "gs alias defined (git status)"
    else
        fail_test "gs alias not defined"
    fi

    if _alias_defined_in_config "gp"; then
        pass_test "gp alias defined (git push)"
    else
        fail_test "gp alias not defined"
    fi

    if _alias_defined_in_config "gl"; then
        pass_test "gl alias defined (git pull)"
    else
        fail_test "gl alias not defined"
    fi

    # Modern tool aliases (only if tools installed)
    if has_command eza; then
        if _alias_defined_in_config "ls"; then
            pass_test "ls aliased to eza"
        else
            skip_test "ls not aliased to eza"
        fi
    else
        skip_test "eza not installed"
    fi

    if has_command bat; then
        if _alias_defined_in_config "cat"; then
            pass_test "cat aliased to bat"
        else
            skip_test "cat not aliased to bat"
        fi
    else
        skip_test "bat not installed"
    fi

    # Key utility functions (check in .zshrc or functions.d)
    if _function_defined_in_config "mkcd"; then
        pass_test "mkcd function defined (mkdir + cd)"
    else
        fail_test "mkcd function not defined"
    fi

    if _function_defined_in_config "extract"; then
        pass_test "extract function defined (archive extraction)"
    else
        fail_test "extract function not defined"
    fi

    # Toolkit functions (check in toolkit files)
    if grep -qE "^fav\(\)|^function fav" "$HOME/.zsh/favorites.zsh" 2>/dev/null; then
        pass_test "fav function defined (favorites display)"
    else
        fail_test "fav function not defined"
    fi

    if grep -qE "^bm\(\)|^function bm" "$HOME/.zsh/bookmarks.zsh" 2>/dev/null; then
        pass_test "bm function defined (bookmarks)"
    else
        fail_test "bm function not defined"
    fi

    # myip is in functions.d/_devtools_utils.zsh or .zshrc
    if _function_defined_in_config "myip"; then
        pass_test "myip function defined (show IP addresses)"
    else
        fail_test "myip function not defined"
    fi
}
