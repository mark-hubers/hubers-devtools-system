#!/bin/zsh
# ============================================================================
# Configuration Preservation Tests
# ============================================================================

test_config() {
    step "Configuration & Preservation"

    # ~/.zshrc_local should exist (personal customizations)
    if [[ -f "$HOME/.zshrc_local" ]]; then
        pass_test "~/.zshrc_local exists (personal customizations preserved)"

        if [[ -s "$HOME/.zshrc_local" ]]; then
            local line_count=$(wc -l < "$HOME/.zshrc_local" | tr -d ' ')
            info "~/.zshrc_local has $line_count lines of customizations"
        else
            info "~/.zshrc_local is empty (no customizations yet)"
        fi
    else
        skip_test "~/.zshrc_local not created yet"
    fi

    # Main .zshrc should source personal file
    assert_line_in_file "$HOME/.zshrc" "zshrc_local" ".zshrc sources personal customizations"

    # Check .zshrc has devtools header
    assert_line_in_file "$HOME/.zshrc" "Ultimate Developer" ".zshrc has devtools header"

    # Oh-My-Zsh installed
    assert_dir_exists "$HOME/.oh-my-zsh" "Oh-My-Zsh installed"

    # Powerlevel10k config
    if [[ -f "$HOME/.p10k.zsh" ]]; then
        pass_test "Powerlevel10k configured (~/.p10k.zsh)"
    else
        skip_test "Powerlevel10k not configured (run: p10k configure)"
    fi

    # .zsh directory structure
    assert_dir_exists "$HOME/.zsh" "~/.zsh directory exists"

    # Key toolkit files
    local toolkit_files=(
        "favorites.zsh"
        "bookmarks.zsh"
        "network-toolkit.zsh"
    )

    for file in "${toolkit_files[@]}"; do
        if [[ -f "$HOME/.zsh/$file" ]]; then
            pass_test "Toolkit loaded: $file"
        else
            fail_test "Missing toolkit: $file"
        fi
    done

    # GitHub CLI toolkit (if gh installed)
    if has_command gh; then
        assert_file_exists "$HOME/.zsh/github-cli-toolkit.zsh" "GitHub CLI toolkit loaded"
    fi
}
