#!/bin/zsh
# ============================================================================
# Favorites System Tests
# ============================================================================

test_favorites() {
    step "Favorites System"

    local favorites_file="${HOME}/.zsh/my-favorites.txt"

    # Favorites file exists
    if [[ -f "$favorites_file" ]]; then
        pass_test "Favorites file exists: $favorites_file"

        # Check for section headers
        if grep -q "^#= " "$favorites_file" 2>/dev/null; then
            pass_test "Favorites has section headers"
        else
            skip_test "Favorites file has no sections yet"
        fi
    else
        skip_test "Favorites file not created yet (run favedit)"
    fi

    # Favorites functions
    assert_function_exists "fav" "fav command (show favorites)"
    assert_function_exists "favedit" "favedit command (edit favorites)"
    assert_function_exists "favon" "favon command (enable startup display)"
    assert_function_exists "favoff" "favoff command (disable startup display)"

    # Favorites toggle file
    if [[ -f "${HOME}/.zsh/.favorites_enabled" ]]; then
        pass_test "Favorites enabled (startup display on)"
    else
        info "Favorites disabled (run favon to enable)"
        ((TEST_PASSED++))
    fi

    # Extension favorites discovery
    if typeset -f _show_extension_favorites &>/dev/null; then
        pass_test "Extension favorites loader available"
    else
        skip_test "Extension favorites loader not found"
    fi
}
