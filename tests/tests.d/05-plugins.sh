#!/bin/zsh
# ============================================================================
# Plugin Detection and Loading Tests
# ============================================================================

test_plugins() {
    step "Plugin System"

    # Plugin discovery function available
    assert_function_exists "find_plugins" "find_plugins function available"

    # my-tools directory
    local my_tools_dir
    my_tools_dir="$(find_my_tools_dir 2>/dev/null)"

    if [[ -n "$my_tools_dir" && -d "$my_tools_dir" ]]; then
        pass_test "my-tools directory found: $my_tools_dir"

        # Count plugins with .devtools-plugin marker
        local plugin_count=0
        local plugin_names=()
        for dir in "$my_tools_dir"/*/; do
            if [[ -f "${dir}.devtools-plugin" ]]; then
                ((plugin_count++))
                plugin_names+=("$(basename "$dir")")
            fi
        done

        if [[ $plugin_count -gt 0 ]]; then
            pass_test "Found $plugin_count plugin(s): ${plugin_names[*]}"
        else
            info "No plugins found (add .devtools-plugin marker to enable)"
            ((TEST_PASSED++))
        fi
    else
        skip_test "my-tools directory not found"
    fi

    # Extensions directory
    assert_dir_exists "$HOME/.zsh/extensions.d" "Extensions directory exists"

    # Count loaded extensions
    local ext_count=0
    if [[ -d "$HOME/.zsh/extensions.d" ]]; then
        ext_count=$(ls -1 "$HOME/.zsh/extensions.d"/*.zsh 2>/dev/null | wc -l | tr -d ' ')
    fi

    if [[ $ext_count -gt 0 ]]; then
        pass_test "Extensions loaded: $ext_count"
    else
        info "No extensions loaded in extensions.d/"
        ((TEST_PASSED++))
    fi

    # hubers-devtools-system location
    if [[ -n "$DEVTOOLS_DIR" && -f "$DEVTOOLS_DIR/setup.sh" ]]; then
        pass_test "DEVTOOLS_DIR valid: $DEVTOOLS_DIR"
    elif [[ -d "$HOME/my-tools/hubers-devtools-system" ]]; then
        pass_test "hubers-devtools-system found at ~/my-tools/"
    else
        skip_test "hubers-devtools-system location unclear"
    fi
}
