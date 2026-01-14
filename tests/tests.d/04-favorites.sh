#!/bin/zsh
# ============================================================================
# Favorites System Tests
# ============================================================================
# Note: Tests check if functions are DEFINED in config files,
# since child scripts don't inherit parent shell functions.
# ============================================================================

test_favorites() {
    step "Favorites System"

    local favorites_file="${HOME}/.zsh/my-favorites.txt"
    local favorites_zsh="${HOME}/.zsh/favorites.zsh"

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

    # Favorites functions (check in favorites.zsh)
    if [[ -f "$favorites_zsh" ]]; then
        if grep -qE "^fav\(\)|^function fav\b" "$favorites_zsh" 2>/dev/null; then
            pass_test "fav command defined (show favorites)"
        else
            fail_test "fav command not defined"
        fi

        if grep -qE "^favedit\(\)|^function favedit" "$favorites_zsh" 2>/dev/null; then
            pass_test "favedit command defined (edit favorites)"
        else
            fail_test "favedit command not defined"
        fi

        if grep -qE "^favon\(\)|^function favon" "$favorites_zsh" 2>/dev/null; then
            pass_test "favon command defined (enable startup)"
        else
            fail_test "favon command not defined"
        fi

        if grep -qE "^favoff\(\)|^function favoff" "$favorites_zsh" 2>/dev/null; then
            pass_test "favoff command defined (disable startup)"
        else
            fail_test "favoff command not defined"
        fi

        # Extension favorites discovery
        if grep -qE "_show_extension_favorites\(\)|function _show_extension_favorites" "$favorites_zsh" 2>/dev/null; then
            pass_test "Extension favorites loader defined"
        else
            skip_test "Extension favorites loader not found"
        fi
    else
        fail_test "favorites.zsh not found"
    fi

    # Favorites toggle file
    if [[ -f "${HOME}/.zsh/.favorites_enabled" ]]; then
        pass_test "Favorites enabled (startup display on)"
    else
        info "Favorites disabled (run favon to enable)"
        ((TEST_PASSED++))
    fi
}
