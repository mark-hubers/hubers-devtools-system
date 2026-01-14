#!/bin/zsh
# ============================================================================
# Alias and Function Tests
# ============================================================================

test_aliases() {
    step "Aliases & Functions"

    # Core aliases from .zshrc
    assert_alias_exists "ll" "ll alias (long list)"
    assert_alias_exists "la" "la alias (list all)"

    # Git aliases
    assert_alias_exists "gs" "gs alias (git status)"
    assert_alias_exists "gp" "gp alias (git push)"
    assert_alias_exists "gl" "gl alias (git pull)"

    # Modern tool aliases (only if tools installed)
    if has_command eza; then
        # Check if ls is aliased (might be function or alias)
        if alias ls &>/dev/null || typeset -f ls &>/dev/null; then
            pass_test "ls enhanced with eza"
        else
            skip_test "ls not aliased to eza"
        fi
    fi

    if has_command bat; then
        if alias cat &>/dev/null || typeset -f cat &>/dev/null; then
            pass_test "cat enhanced with bat"
        else
            skip_test "cat not aliased to bat"
        fi
    fi

    # Key utility functions
    assert_function_exists "mkcd" "mkcd function (mkdir + cd)"
    assert_function_exists "extract" "extract function (archive extraction)"

    # Toolkit functions
    assert_function_exists "fav" "fav function (favorites display)"
    assert_function_exists "bm" "bm function (bookmarks)"
    assert_function_exists "myip" "myip function (show IP addresses)"
}
