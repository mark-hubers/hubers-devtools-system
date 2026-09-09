#!/bin/zsh
# ============================================================================
# GitHub Toolkit Integration Tests (opt-in)
# ============================================================================

test_github_toolkit_integration() {
    step "GitHub Toolkit Integration (opt-in)"

    if [[ "${RUN_GH_LIVE_TESTS:-0}" != "1" ]]; then
        skip_test "Set RUN_GH_LIVE_TESTS=1 to run live GitHub integration tests"
        return
    fi

    local source_toolkit_file="$DEVTOOLS_DIR/terminal-config/home/.zsh/github-cli-toolkit.zsh"
    if [[ ! -f "$source_toolkit_file" ]]; then
        fail_test "Toolkit source file missing"
        return
    fi

    if zsh -c "source \"$source_toolkit_file\"; ghdoctor > /dev/null 2>&1" > /dev/null 2>&1; then
        pass_test "ghdoctor runs in live shell"
    else
        fail_test "ghdoctor failed in live shell"
    fi

    if gh auth status > /dev/null 2>&1; then
        pass_test "gh authentication works live"
    else
        fail_test "gh auth status failed live"
        return
    fi

    if gh api user --jq '.login' > /dev/null 2>&1; then
        pass_test "gh api user works live"
    else
        fail_test "gh api user failed live"
    fi

    if [[ -n "${GH_TOOLKIT_TEST_ORG:-}" ]]; then
        if zsh -c "source \"$source_toolkit_file\"; ghteam list \"$GH_TOOLKIT_TEST_ORG\" --json > /dev/null 2>&1" > /dev/null 2>&1; then
            pass_test "ghteam list works for GH_TOOLKIT_TEST_ORG"
        else
            fail_test "ghteam list failed for GH_TOOLKIT_TEST_ORG"
        fi
    else
        skip_test "Set GH_TOOLKIT_TEST_ORG to include live org-level integration checks"
    fi
}
