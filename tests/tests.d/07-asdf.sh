#!/bin/zsh
# ============================================================================
# asdf Version Manager Tests
# ============================================================================
# Tests that asdf is installed and configured with the required plugins
# and tool versions for development.
# ============================================================================

# Source asdf if available
_ensure_asdf_loaded() {
    if [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
        . /opt/homebrew/opt/asdf/libexec/asdf.sh
    elif [[ -f /usr/local/opt/asdf/libexec/asdf.sh ]]; then
        . /usr/local/opt/asdf/libexec/asdf.sh
    elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
        . "$HOME/.asdf/asdf.sh"
    fi
}

test_asdf() {
    step "asdf Version Manager"

    # Check asdf is installed
    _ensure_asdf_loaded

    if command -v asdf &>/dev/null; then
        pass_test "asdf command available"

        local asdf_version=$(asdf --version 2>/dev/null | head -1)
        info "asdf version: $asdf_version"
    else
        fail_test "asdf not installed - run: devsetup add asdf"
        return
    fi

    # Check required plugins
    local plugins=$(asdf plugin list 2>/dev/null)

    if echo "$plugins" | grep -q "^terraform$"; then
        pass_test "terraform plugin installed"
        local tf_versions=$(asdf list terraform 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$tf_versions" -gt 0 ]]; then
            pass_test "terraform has $tf_versions version(s) installed"
        else
            fail_test "No terraform versions installed"
        fi
    else
        fail_test "terraform plugin not installed"
    fi

    if echo "$plugins" | grep -q "^kubectl$"; then
        pass_test "kubectl plugin installed"
        local k_versions=$(asdf list kubectl 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$k_versions" -gt 0 ]]; then
            pass_test "kubectl has $k_versions version(s) installed"
        else
            fail_test "No kubectl versions installed"
        fi
    else
        fail_test "kubectl plugin not installed"
    fi

    if echo "$plugins" | grep -q "^java$"; then
        pass_test "java plugin installed"
        local j_versions=$(asdf list java 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$j_versions" -gt 0 ]]; then
            pass_test "java has $j_versions version(s) installed"
        else
            skip_test "No java versions installed (optional)"
        fi
    else
        skip_test "java plugin not installed (optional)"
    fi

    if echo "$plugins" | grep -q "^awscli$"; then
        pass_test "awscli plugin installed"
    else
        skip_test "awscli plugin not installed (optional)"
    fi

    # Check global .tool-versions file
    if [[ -f "$HOME/.tool-versions" ]]; then
        pass_test "Global .tool-versions exists"
        local tool_count=$(wc -l < "$HOME/.tool-versions" | tr -d ' ')
        info "  $tool_count tools configured in ~/.tool-versions"
    else
        fail_test "No global .tool-versions file"
    fi

    # Check that tools are accessible
    if command -v terraform &>/dev/null; then
        local tf_v=$(terraform version 2>/dev/null | head -1 | awk '{print $2}')
        pass_test "terraform accessible: $tf_v"
    else
        fail_test "terraform not accessible in PATH"
    fi

    if command -v kubectl &>/dev/null; then
        local k_v=$(kubectl version --client 2>/dev/null | grep "Client Version" | awk '{print $3}')
        pass_test "kubectl accessible: $k_v"
    else
        fail_test "kubectl not accessible in PATH"
    fi
}
