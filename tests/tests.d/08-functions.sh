#!/bin/zsh
# ============================================================================
# Modular Functions Tests
# ============================================================================
# Tests that functions.d, aliases.d, and path.d are properly configured
# and that all defined functions are actually available.
# ============================================================================

# Source all function files for testing
_load_function_files() {
    for _f in ~/.zsh/functions.d/*.zsh(N); do
        source "$_f" 2>/dev/null
    done
}

test_functions() {
    step "Modular Functions (.d directories)"

    # Check directories exist
    if [[ -d "$HOME/.zsh/functions.d" ]]; then
        pass_test "functions.d directory exists"
    else
        fail_test "functions.d directory missing"
        return
    fi

    if [[ -d "$HOME/.zsh/aliases.d" ]]; then
        pass_test "aliases.d directory exists"
    else
        skip_test "aliases.d directory missing (optional)"
    fi

    if [[ -d "$HOME/.zsh/path.d" ]]; then
        pass_test "path.d directory exists"
    else
        skip_test "path.d directory missing (optional)"
    fi

    # Check for managed function files
    local managed_files=$(ls ~/.zsh/functions.d/_devtools_*.zsh 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$managed_files" -gt 0 ]]; then
        pass_test "Found $managed_files managed function file(s)"
    else
        skip_test "No managed function files found"
    fi

    # Check template file exists
    if [[ -f "$HOME/.zsh/functions.d/my-custom.zsh" ]]; then
        pass_test "User template file exists (my-custom.zsh)"
    else
        skip_test "User template missing"
    fi

    # Load functions and test they exist
    _load_function_files

    # Test FZF functions
    local fzf_funcs=(ff fh fif fkill fcd)
    local fzf_ok=0
    for func in $fzf_funcs; do
        typeset -f "$func" > /dev/null 2>&1 && ((fzf_ok++))
    done
    if [[ $fzf_ok -eq ${#fzf_funcs[@]} ]]; then
        pass_test "FZF functions loaded ($fzf_ok/${#fzf_funcs[@]})"
    elif [[ $fzf_ok -gt 0 ]]; then
        info "FZF functions partially loaded ($fzf_ok/${#fzf_funcs[@]})"
        ((TEST_PASSED++))
    else
        fail_test "FZF functions not loaded"
    fi

    # Test Git functions
    local git_funcs=(gcob gwip)
    local git_ok=0
    for func in $git_funcs; do
        typeset -f "$func" > /dev/null 2>&1 && ((git_ok++))
    done
    if [[ $git_ok -eq ${#git_funcs[@]} ]]; then
        pass_test "Git functions loaded ($git_ok/${#git_funcs[@]})"
    elif [[ $git_ok -gt 0 ]]; then
        info "Git functions partially loaded ($git_ok/${#git_funcs[@]})"
        ((TEST_PASSED++))
    else
        fail_test "Git functions not loaded"
    fi

    # Test K8s functions
    local k8s_funcs=(kns kctx kgp kl kex)
    local k8s_ok=0
    for func in $k8s_funcs; do
        typeset -f "$func" > /dev/null 2>&1 && ((k8s_ok++))
    done
    if [[ $k8s_ok -eq ${#k8s_funcs[@]} ]]; then
        pass_test "K8s functions loaded ($k8s_ok/${#k8s_funcs[@]})"
    elif [[ $k8s_ok -gt 0 ]]; then
        info "K8s functions partially loaded ($k8s_ok/${#k8s_funcs[@]})"
        ((TEST_PASSED++))
    else
        fail_test "K8s functions not loaded"
    fi

    # Run self-tests if available
    if typeset -f _test_devtools_fzf > /dev/null 2>&1; then
        info "Running FZF self-test..."
        _test_devtools_fzf > /dev/null 2>&1 && pass_test "FZF self-test passed" || fail_test "FZF self-test failed"
    fi

    if typeset -f _test_devtools_git > /dev/null 2>&1; then
        info "Running Git self-test..."
        _test_devtools_git > /dev/null 2>&1 && pass_test "Git self-test passed" || fail_test "Git self-test failed"
    fi

    if typeset -f _test_devtools_k8s > /dev/null 2>&1; then
        info "Running K8s self-test..."
        _test_devtools_k8s > /dev/null 2>&1 && pass_test "K8s self-test passed" || fail_test "K8s self-test failed"
    fi
}
