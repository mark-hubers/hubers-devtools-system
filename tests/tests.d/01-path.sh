#!/bin/zsh
# ============================================================================
# PATH Verification Tests
# ============================================================================
# Note: Some PATH checks verify file existence since child scripts
# don't inherit the full PATH from parent shell.
# ============================================================================

test_path() {
    step "PATH Configuration"

    # Homebrew path (platform-specific)
    if is_macos; then
        if [[ $(uname -m) == "arm64" ]]; then
            assert_in_path "/opt/homebrew/bin" "Homebrew (Apple Silicon) in PATH"
        else
            assert_in_path "/usr/local/bin" "Homebrew (Intel) in PATH"
        fi
    fi

    # devsetup command - check file exists and .zshrc adds it to PATH
    local devsetup_path="$DEVTOOLS_DIR/bin/devsetup"
    if [[ -x "$devsetup_path" ]]; then
        pass_test "devsetup command exists: $devsetup_path"
        # Also verify .zshrc adds bin/ to PATH
        if grep -q 'PATH="$possible_location/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
            pass_test "devsetup bin/ added to PATH in .zshrc"
        else
            skip_test "devsetup PATH setup not found in .zshrc"
        fi
    else
        fail_test "devsetup command not found"
    fi

    # ~/.local/bin for user tools (Claude Code, etc.)
    if [[ -d "$HOME/.local/bin" ]]; then
        assert_in_path "$HOME/.local/bin" "~/.local/bin in PATH (user tools)"
    else
        skip_test "~/.local/bin doesn't exist (optional)"
    fi

    # DEVTOOLS_DIR set and valid
    if [[ -n "$DEVTOOLS_DIR" ]]; then
        assert_dir_exists "$DEVTOOLS_DIR" "DEVTOOLS_DIR points to valid directory"
    else
        skip_test "DEVTOOLS_DIR not set (optional)"
    fi
}
