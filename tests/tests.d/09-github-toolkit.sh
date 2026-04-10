#!/bin/zsh
# ============================================================================
# GitHub Toolkit Tests
# ============================================================================

test_github_toolkit() {
    step "GitHub CLI Toolkit"

    local toolkit_file="$HOME/.zsh/github-cli-toolkit.zsh"
    local source_toolkit_file="$DEVTOOLS_DIR/terminal-config/home/.zsh/github-cli-toolkit.zsh"

    if [[ -f "$source_toolkit_file" ]]; then
        pass_test "Toolkit source file exists"
    else
        fail_test "Toolkit source file missing"
        return
    fi

    if zsh -n "$source_toolkit_file" > /dev/null 2>&1; then
        pass_test "Toolkit syntax check passed"
    else
        fail_test "Toolkit syntax check failed"
    fi

    if zsh -c "source \"$source_toolkit_file\"; typeset -f ghdoctor ghvar ghsecret ghteam gh-as > /dev/null" > /dev/null 2>&1; then
        pass_test "Primary toolkit commands are defined"
    else
        fail_test "Primary toolkit commands not fully defined"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        _gh_parse_target '  owner/repo  ' || exit 1
        [[ \"\$_GH_SCOPE\" == 'repo' ]] || exit 1
        [[ \"\$_GH_API_PATH\" == '/repos/owner/repo/actions/variables' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "_gh_parse_target trims whitespace and parses repo target"
    else
        fail_test "_gh_parse_target repo parsing failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        typeset -ga _GH_TEST_CALLS=()
        gh() { _GH_TEST_CALLS+=(\"\$*\"); return 0; }
        _gh_current_account() { echo 'personal-acct'; }
        typeset -gA GH_ACCOUNT_ALIAS
        GH_ACCOUNT_ALIAS=('work' 'work-acct')
        gh-as work true > /dev/null 2>&1
        [[ \"\${_GH_TEST_CALLS[1]}\" == 'auth switch --user work-acct' ]] || exit 1
        [[ \"\${_GH_TEST_CALLS[2]}\" == 'auth switch --user personal-acct' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "gh-as switches account and restores original"
    else
        fail_test "gh-as account restore behavior failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        _gh_parse_target() {
            _GH_SCOPE='repo'
            _GH_TARGET_LABEL='owner/repo'
            _GH_API_PATH='/repos/owner/repo/actions/variables'
            return 0
        }
        _gh_handle_error() { return 1; }
        _gh_scoped() {
            local payload
            payload=\"\$(cat)\"
            echo \"\$payload\" | jq -e '.name == \"TEST_KEY\" and .value == \"value\\\"with-quotes\"' > /dev/null || return 9
            return 0
        }
        _ghvar_set TEST_KEY 'value\"with-quotes' owner/repo > /dev/null 2>&1 || exit 1
    " > /dev/null 2>&1; then
        pass_test "_ghvar_set safely builds JSON payload"
    else
        fail_test "_ghvar_set JSON payload handling failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        typeset -gi _GH_CALL_COUNT=0
        _gh_parse_target() {
            _GH_SCOPE='repo'
            _GH_TARGET_LABEL='owner/repo'
            _GH_API_PATH='/repos/owner/repo/actions/variables'
            return 0
        }
        _gh_scoped() { ((_GH_CALL_COUNT++)); return 0; }
        _gh_admin() { ((_GH_CALL_COUNT++)); return 0; }
        gh() { ((_GH_CALL_COUNT++)); return 0; }
        _ghvar_set KEY1 value1 owner/repo --dry-run > /dev/null 2>&1 || exit 1
        _gh_parse_target() {
            _GH_SCOPE='org'
            _GH_TARGET_LABEL='example-org'
            _GH_API_PATH='/orgs/example-org/actions/variables'
            return 0
        }
        _ghvar_set KEY2 value2 example-org --visibility selected --repos repo-one,repo-two --dry-run > /dev/null 2>&1 || exit 1
        _ghvar_delete KEY1 owner/repo --dry-run > /dev/null 2>&1 || exit 1
        _ghsecret_set SECRET1 owner/repo --dry-run > /dev/null 2>&1 || exit 1
        _ghsecret_delete SECRET1 owner/repo --dry-run > /dev/null 2>&1 || exit 1
        _ghteam_add_member org1 team1 user1 --dry-run > /dev/null 2>&1 || exit 1
        _ghteam_remove_member org1 team1 user1 --dry-run > /dev/null 2>&1 || exit 1
        _ghteam_set_repo org1 team1 repo1 push --dry-run > /dev/null 2>&1 || exit 1
        _ghteam_fix org1 team1 --description 'desc' --dry-run > /dev/null 2>&1 || exit 1
        [[ \"\$_GH_CALL_COUNT\" -eq 0 ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "--dry-run prevents API calls across destructive commands"
    else
        fail_test "--dry-run behavior failed (API call was attempted)"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        tmp_file=\"\$(mktemp)\"
        capture_file=\"\$(mktemp)\"
        cat > \"\$tmp_file\" << 'EOF'
# comment
  # indented comment
FOO=bar
  BAZ = qux
EOF
        _gh_parse_target() {
            _GH_SCOPE='repo'
            _GH_TARGET_LABEL='owner/repo'
            _GH_API_PATH='/repos/owner/repo/actions/variables'
            return 0
        }
        _gh_scoped() {
            local payload
            payload=\"\$(cat)\"
            echo \"\$payload\" | jq -r '.name' >> \"\$capture_file\"
            return 0
        }
        _ghvar_import \"\$tmp_file\" owner/repo --dry-run > /dev/null 2>&1 || exit 1
        _ghvar_import \"\$tmp_file\" owner/repo > /dev/null 2>&1 || exit 1
        mapfile=(\${(@f)\$(<\"\$capture_file\")})
        [[ \"\${#mapfile[@]}\" -eq 2 ]] || exit 1
        [[ \"\${mapfile[1]}\" == 'FOO' ]] || exit 1
        [[ \"\${mapfile[2]}\" == 'BAZ' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "ghvar import handles env file parsing and apply flow"
    else
        fail_test "ghvar import basic flow failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        empty_file=\"\$(mktemp)\"
        comments_file=\"\$(mktemp)\"
        malformed_file=\"\$(mktemp)\"
        capture_file=\"\$(mktemp)\"
        cat > \"\$comments_file\" << 'EOF'
# only comments
    # still comment

EOF
        cat > \"\$malformed_file\" << 'EOF'
NOEQUALS
=emptykey
GOOD_KEY=ok
EOF
        _gh_parse_target() {
            _GH_SCOPE='repo'
            _GH_TARGET_LABEL='owner/repo'
            _GH_API_PATH='/repos/owner/repo/actions/variables'
            return 0
        }
        _gh_scoped() {
            local payload
            payload=\"\$(cat)\"
            echo \"\$payload\" | jq -r '.name' >> \"\$capture_file\"
            return 0
        }
        _ghvar_import \"\$empty_file\" owner/repo > /dev/null 2>&1 && exit 1
        _ghvar_import \"\$comments_file\" owner/repo > /dev/null 2>&1 && exit 1
        _ghvar_import \"\$malformed_file\" owner/repo > /dev/null 2>&1 || exit 1
        mapfile=(\${(@f)\$(<\"\$capture_file\")})
        [[ \"\${#mapfile[@]}\" -eq 1 ]] || exit 1
        [[ \"\${mapfile[1]}\" == 'GOOD_KEY' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "ghvar import edge cases handled (empty/comments/malformed)"
    else
        fail_test "ghvar import edge-case handling failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        typeset -gA GH_PROFILES
        GH_PROFILES=(
            devprofile   'org=my-org token=gh-auth mode=dev default_vis=all'
            adminprofile 'org=my-org token=gh-auth mode=admin default_vis=all'
        )
        ghprofile list > /dev/null 2>&1 || exit 1
        _gh_profile_parse \"\${GH_PROFILES[devprofile]}\" || exit 1
        [[ \"\$_GH_PROF_ORG\" == 'my-org' ]] || exit 1
        [[ \"\$_GH_PROF_MODE\" == 'dev' ]] || exit 1
        _gh_profile_activate devprofile > /dev/null 2>&1 || exit 1
        [[ \"\$GH_ACTIVE_PROFILE\" == 'devprofile' ]] || exit 1
        [[ \"\$GH_PROFILE_ORG\" == 'my-org' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "ghprofile list/use and _gh_profile_parse work"
    else
        fail_test "ghprofile / profile parse failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        GH_ACTIVE_PROFILE='x'
        GH_PROFILE_MODE='dev'
        _gh_require_admin > /dev/null 2>&1 && exit 1
        GH_PROFILE_MODE='admin'
        _gh_require_admin > /dev/null 2>&1 || exit 1
        unset GH_ACTIVE_PROFILE GH_PROFILE_MODE
        _gh_require_admin > /dev/null 2>&1 || exit 1
    " > /dev/null 2>&1; then
        pass_test "_gh_require_admin blocks dev profile, allows admin or no profile"
    else
        fail_test "_gh_require_admin guardrail failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        typeset -gA GH_PROFILES
        GH_PROFILES=(onlyadmin 'org=o1 token=gh-auth mode=admin')
        ## Subshell does not inherit shell functions; use child zsh to read exported env
        out=\$(ghadmin zsh -c 'echo MODE=\$GH_PROFILE_MODE ORG=\$GH_PROFILE_ORG ACT=\$GH_ACTIVE_PROFILE')
        [[ \"\$out\" == *'MODE=admin'* ]] || exit 1
        [[ \"\$out\" == *'ACT=onlyadmin'* ]] || exit 1
        [[ \"\$out\" == *'ORG=o1'* ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "ghadmin one-shot subshell exports admin profile context"
    else
        fail_test "ghadmin one-shot context failed"
    fi

    if zsh -c "
        source \"$source_toolkit_file\"
        _gh_profile_parse 'org=a token=file:/tmp/x mode=admin'
        [[ \"\$_GH_PROF_ORG\" == 'a' ]] || exit 1
        [[ \"\$_GH_PROF_TOKEN\" == 'file:/tmp/x' ]] || exit 1
    " > /dev/null 2>&1; then
        pass_test "_gh_profile_parse handles standard key=value pairs"
    else
        fail_test "_gh_profile_parse edge case failed"
    fi

    if [[ -f "$toolkit_file" ]]; then
        pass_test "Installed toolkit file exists"
    else
        skip_test "Installed toolkit file not found (run terminal-config/INSTALL.sh)"
    fi
}
