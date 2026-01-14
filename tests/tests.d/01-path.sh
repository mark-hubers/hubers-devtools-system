#!/bin/zsh
# ============================================================================
# PATH Verification Tests
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

    # devsetup command findable
    local devsetup_path
    devsetup_path=$(command -v devsetup 2>/dev/null)
    if [[ -n "$devsetup_path" ]]; then
        pass_test "devsetup command found at: $devsetup_path"
    else
        fail_test "devsetup command not in PATH"
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
