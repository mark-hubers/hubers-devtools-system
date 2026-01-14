#!/bin/zsh
# ============================================================================
# Core Tool Availability Tests
# ============================================================================

test_core_tools() {
    step "Core Tools"

    # Absolutely required
    assert_command_exists "git" "Git version control"
    assert_command_exists "zsh" "ZSH shell"

    # Homebrew (required for most installs)
    assert_command_exists "brew" "Homebrew package manager"

    # Modern CLI replacements (core)
    assert_command_exists "eza" "eza (modern ls)"
    assert_command_exists "bat" "bat (modern cat)"
    assert_command_exists "rg" "ripgrep (modern grep)"
    assert_command_exists "fd" "fd (modern find)"
    assert_command_exists "fzf" "fzf (fuzzy finder)"
    assert_command_exists "zoxide" "zoxide (smart cd)"

    # Data processing
    assert_command_exists "jq" "jq (JSON processor)"
    assert_command_exists "yq" "yq (YAML processor)"

    # Git enhancements
    if has_command delta; then
        pass_test "delta (git diff pager) available"
    else
        skip_test "delta not installed (optional)"
    fi

    # Optional but recommended
    if has_command lazygit; then
        pass_test "lazygit available"
    else
        skip_test "lazygit not installed (optional)"
    fi

    if has_command gh; then
        pass_test "GitHub CLI (gh) available"
    else
        skip_test "GitHub CLI not installed (optional)"
    fi

    if has_command glow; then
        pass_test "glow (markdown viewer) available"
    else
        skip_test "glow not installed (optional)"
    fi
}
