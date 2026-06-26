#!/bin/zsh
# ============================================================================
# GitHub Identity Isolation Tests (ghid)
# ============================================================================
# Verifies per-session identity isolation via GH_CONFIG_DIR:
#   - name validation / path-traversal guard
#   - binding sets GH_CONFIG_DIR + GH_ACTIVE_IDENTITY, creates dir 700
#   - current-identity derivation (under GH_ID_HOME vs external)
#   - .gh-id marker discovery + chpwd autodetect
#   - account parsing (mocked gh)
#   - import flow (mocked gh auth token / login)
#   - SIMULTANEOUS isolation: two separate shells hold different identities
# ============================================================================

test_github_identity() {
    step "GitHub Identity Isolation (ghid)"

    local source_toolkit_file="$DEVTOOLS_DIR/terminal-config/home/.zsh/github-cli-toolkit.zsh"

    if [[ ! -f "$source_toolkit_file" ]]; then
        fail_test "Toolkit source file missing (cannot test ghid)"
        return
    fi

    ## --- Module loads and ghid functions exist ---
    if zsh -c "source \"$source_toolkit_file\"; typeset -f ghid _gh_id_use_quiet _gh_id_valid_name _gh_id_current_name _gh_id_account_in_dir _gh_id_find_marker _gh_id_chpwd_hook _gh_id_prompt_info > /dev/null"; then
        pass_test "ghid functions exist after load"
    else
        fail_test "ghid functions missing after load"
    fi

    ## --- Name validation / path-traversal guard ---
    if zsh -c "
        source \"$source_toolkit_file\"
        _gh_id_valid_name 'personal'    || exit 1
        _gh_id_valid_name 'work-admin'  || exit 1
        _gh_id_valid_name 'a.b_c-1'     || exit 1
        _gh_id_valid_name ''            && exit 1
        _gh_id_valid_name '../etc'      && exit 1
        _gh_id_valid_name 'a/b'         && exit 1
        _gh_id_valid_name '/abs'        && exit 1
        _gh_id_valid_name 'has space'   && exit 1
        _gh_id_valid_name 'semi;colon'  && exit 1
        ## Adversarial inputs (cursor finding 9/10): single dot, newline, glob, unicode
        _gh_id_valid_name '.'           && exit 1
        _gh_id_valid_name \$'work\n'     && exit 1
        _gh_id_valid_name \$'a\nb'       && exit 1
        _gh_id_valid_name 'a*b'         && exit 1
        _gh_id_valid_name 'a?b'         && exit 1
        _gh_id_valid_name 'café'        && exit 1
        _gh_id_valid_name '.hidden'     || exit 1   ## leading dot (not bare '.') is allowed
        exit 0
    "; then
        pass_test "ghid name validation rejects dot/newline/glob/unicode, accepts safe names"
    else
        fail_test "ghid name validation failed"
    fi

    ## --- Binding sets env + creates dir with 700 perms ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        _gh_id_use_quiet 'personal' || exit 1
        [[ \"\$GH_CONFIG_DIR\" == \"\$GH_ID_HOME/personal\" ]] || exit 1
        [[ \"\$GH_ACTIVE_IDENTITY\" == 'personal' ]] || exit 1
        [[ -d \"\$GH_CONFIG_DIR\" ]] || exit 1
        perms=\$(stat -f '%Lp' \"\$GH_CONFIG_DIR\" 2>/dev/null || stat -c '%a' \"\$GH_CONFIG_DIR\" 2>/dev/null)
        [[ \"\$perms\" == '700' ]] || exit 1
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid use creates isolated config dir (700) and exports binding"
    else
        fail_test "ghid use binding/dir-creation failed"
    fi

    ## --- current-name derivation: under GH_ID_HOME vs external ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME='/tmp/ghid-test-home'
        export GH_CONFIG_DIR='/tmp/ghid-test-home/work'
        [[ \"\$(_gh_id_current_name)\" == 'work' ]] || exit 1
        export GH_CONFIG_DIR='/somewhere/else'
        [[ -z \"\$(_gh_id_current_name)\" ]] || exit 1
        unset GH_CONFIG_DIR
        [[ -z \"\$(_gh_id_current_name)\" ]] || exit 1
        exit 0
    "; then
        pass_test "ghid current-name derives from GH_ID_HOME, empty for external/unbound"
    else
        fail_test "ghid current-name derivation failed"
    fi

    ## --- ghid which + ghid clear ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        gh() { return 0; }   ## stub: avoid real auth status calls
        _gh_id_use_quiet 'work' || exit 1
        [[ \"\$(ghid which)\" == 'work' ]] || exit 1
        ghid clear > /dev/null
        [[ -z \"\$GH_CONFIG_DIR\" ]] || exit 1
        [[ -z \"\$GH_ACTIVE_IDENTITY\" ]] || exit 1
        [[ -z \"\$(ghid which)\" ]] || exit 1
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid which prints binding; ghid clear unbinds"
    else
        fail_test "ghid which/clear failed"
    fi

    ## --- .gh-id marker discovery (walks up) + chpwd autodetect (existing id) ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        mkdir -p \"\$GH_ID_HOME/myid\"   ## identity must already exist to auto-bind
        root=\"\$(mktemp -d)\"
        mkdir -p \"\$root/repo/sub/deep\"
        echo 'myid' > \"\$root/repo/.gh-id\"
        cd \"\$root/repo/sub/deep\"
        [[ \"\$(_gh_id_find_marker)\" == 'myid' ]] || exit 1
        gh() { return 0; }
        _gh_id_chpwd_hook > /dev/null
        [[ \"\$GH_ACTIVE_IDENTITY\" == 'myid' ]] || exit 1
        [[ \"\$GH_CONFIG_DIR\" == \"\$GH_ID_HOME/myid\" ]] || exit 1
        rm -rf \"\$root\" \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test ".gh-id marker discovery + chpwd autodetect bind identity"
    else
        fail_test ".gh-id marker/autodetect failed"
    fi

    ## --- autodetect refuses to MATERIALIZE an unknown identity from a repo file ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        mkdir -p \"\$GH_ID_HOME\"
        root=\"\$(mktemp -d)\"
        echo 'attacker-supplied' > \"\$root/.gh-id\"
        cd \"\$root\"
        unset GH_CONFIG_DIR GH_ACTIVE_IDENTITY 2>/dev/null
        _gh_id_chpwd_hook > /dev/null 2>&1
        ## Must NOT bind, and must NOT create the identity dir
        [[ -z \"\${GH_ACTIVE_IDENTITY:-}\" ]] || exit 1
        [[ ! -d \"\$GH_ID_HOME/attacker-supplied\" ]] || exit 1
        rm -rf \"\$root\" \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "autodetect refuses to create an unknown identity from a repo .gh-id"
    else
        fail_test "autodetect materialized an unknown identity (security regression)"
    fi

    ## --- .gh-id ignores comments/blank lines ---
    if zsh -c "
        source \"$source_toolkit_file\"
        root=\"\$(mktemp -d)\"
        printf '# a comment\n\n   realid\n' > \"\$root/.gh-id\"
        cd \"\$root\"
        [[ \"\$(_gh_id_find_marker)\" == 'realid' ]] || exit 1
        rm -rf \"\$root\"
        exit 0
    "; then
        pass_test ".gh-id marker skips comments and blank lines"
    else
        fail_test ".gh-id comment/blank handling failed"
    fi

    ## --- account parsing from a config dir (mocked gh auth status) ---
    if zsh -c "
        source \"$source_toolkit_file\"
        gh() {
            ## Emulate: account name encoded by the config dir we were given
            local acct=\"acct-for-\${GH_CONFIG_DIR:t}\"
            echo \"github.com\"
            echo \"  ✓ Logged in to github.com account \$acct (keyring)\"
            echo \"  - Active account: true\"
        }
        d=\"\$(mktemp -d)/personal\"; mkdir -p \"\$d\"
        out=\$(_gh_id_account_in_dir \"\$d\")
        [[ \"\$out\" == 'acct-for-personal' ]] || exit 1
        rm -rf \"\${d:h}\"
        exit 0
    " 2>/dev/null; then
        pass_test "_gh_id_account_in_dir parses active account from config dir"
    else
        fail_test "_gh_id_account_in_dir parsing failed"
    fi

    ## --- import seeds identity from a global token (mocked gh) ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        typeset -g _LOGIN_CALLED=0
        gh() {
            case \"\$1 \$2\" in
                'auth token') echo 'FAKE-TEST-TOKEN-not-real'; return 0 ;;
                'auth login') _LOGIN_CALLED=1; cat > /dev/null; return 0 ;;
                'auth status')
                    echo '  ✓ Logged in to github.com account imported-acct (keyring)'
                    echo '  - Active account: true' ;;
            esac
        }
        ghid import seeded > /dev/null 2>&1 || exit 1
        [[ \"\$_LOGIN_CALLED\" == '1' ]] || exit 1
        [[ \"\$GH_ACTIVE_IDENTITY\" == 'seeded' ]] || exit 1
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid import seeds identity from global token (no browser)"
    else
        fail_test "ghid import flow failed"
    fi

    ## --- import rejects when no token available ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        gh() { return 1; }   ## no token
        ghid import nope > /dev/null 2>&1 && exit 1
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid import fails cleanly when no global token exists"
    else
        fail_test "ghid import no-token error path failed"
    fi

    ## --- nounset safety: ghid must not blow up under set -u (scripts/CI) ---
    if zsh -c "
        set -u
        source \"$source_toolkit_file\"
        unset GH_CONFIG_DIR 2>/dev/null
        gh() { return 0; }
        ghid show  > /dev/null || exit 1
        ghid which > /dev/null || exit 1
        _gh_id_current_name > /dev/null || exit 1
        _gh_id_prompt_info  > /dev/null || exit 1
        ## Arg-taking subcommands must reach their usage check, not crash (finding 4)
        ghid use    > /dev/null 2>&1; [[ \$? -eq 1 ]] || exit 1
        ghid login  > /dev/null 2>&1; [[ \$? -eq 1 ]] || exit 1
        ghid import > /dev/null 2>&1; [[ \$? -eq 1 ]] || exit 1
        exit 0
    " 2>/dev/null; then
        pass_test "ghid is nounset-safe incl. no-arg use/login/import (set -u)"
    else
        fail_test "ghid breaks under set -u (unset var or missing positional)"
    fi

    ## --- import reads the GLOBAL token, not the currently-bound one (finding 3) ---
    ## If the shell is already bound to identity A, 'ghid import B' must seed B
    ## from the GLOBAL gh token — never copy A's token. We assert the token read
    ## happened with GH_CONFIG_DIR unset (global), not A's dir.
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        seen_cfg_file=\"\$(mktemp)\"
        gh() {
            case \"\$1 \$2\" in
                'auth token')
                    ## Record what GH_CONFIG_DIR was visible when the token was read
                    echo \"cfg=[\${GH_CONFIG_DIR:-UNSET}]\" >> \"\$seen_cfg_file\"
                    echo 'FAKE-GLOBAL-TOKEN-not-real'; return 0 ;;
                'auth login') cat > /dev/null; return 0 ;;
                'auth status')
                    echo '  ✓ Logged in to github.com account global-acct (keyring)'
                    echo '  - Active account: true' ;;
            esac
        }
        _gh_id_use_quiet alpha || exit 1          ## shell is now BOUND to alpha
        bound_dir=\"\$GH_CONFIG_DIR\"
        ghid import beta > /dev/null 2>&1 || exit 1
        ## The token read must NOT have seen alpha's config dir
        grep -q \"\$bound_dir\" \"\$seen_cfg_file\" && exit 1
        grep -q 'cfg=\[UNSET\]' \"\$seen_cfg_file\" || exit 1
        rm -f \"\$seen_cfg_file\"; rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    " 2>/dev/null; then
        pass_test "ghid import reads GLOBAL token even when shell is already bound (no bleed)"
    else
        fail_test "ghid import bled the bound identity's token into the new identity"
    fi

    ## --- Option C: per-shell git push routing toggle ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        gh() { return 0; }
        ## routing requires a binding
        ghid push on > /dev/null 2>&1 && exit 1
        _gh_id_use_quiet work || exit 1
        ## ON sets the git env to route github.com through the gh helper
        ghid push on > /dev/null || exit 1
        [[ \"\$GH_ID_PUSH_ROUTE\" == '1' ]] || exit 1
        [[ \"\$GIT_CONFIG_COUNT\" == '2' ]] || exit 1
        [[ \"\$GIT_CONFIG_KEY_1\" == 'credential.https://github.com.helper' ]] || exit 1
        [[ \"\$GIT_CONFIG_VALUE_1\" == '!gh auth git-credential' ]] || exit 1
        [[ \"\$GIT_CONFIG_VALUE_0\" == '' ]] || exit 1
        ## routing is identity-independent: switching keeps the env, follows new id
        _gh_id_use_quiet personal || exit 1
        [[ \"\$GIT_CONFIG_VALUE_1\" == '!gh auth git-credential' ]] || exit 1
        ## OFF clears it
        ghid push off > /dev/null
        [[ -z \"\${GH_ID_PUSH_ROUTE:-}\" ]] || exit 1
        [[ -z \"\${GIT_CONFIG_COUNT:-}\" ]] || exit 1
        ## clear also tears routing down
        ghid push on > /dev/null; ghid clear > /dev/null
        [[ -z \"\${GIT_CONFIG_COUNT:-}\" ]] || exit 1
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid push on/off routes git env per-shell; switch keeps it; clear tears down"
    else
        fail_test "ghid push routing toggle failed"
    fi

    ## --- push routing must NOT clobber a foreign GIT_CONFIG_* block ---
    if zsh -c "
        source \"$source_toolkit_file\"
        export GH_ID_HOME=\"\$(mktemp -d)/ids\"
        gh() { return 0; }
        _gh_id_use_quiet work || exit 1
        export GIT_CONFIG_COUNT=5            ## pretend another tool owns this
        ghid push on > /dev/null 2>&1 && exit 1   ## must refuse
        [[ \"\$GIT_CONFIG_COUNT\" == '5' ]] || exit 1   ## untouched
        rm -rf \"\${GH_ID_HOME:h}\"
        exit 0
    "; then
        pass_test "ghid push refuses to override a foreign GIT_CONFIG_COUNT"
    else
        fail_test "ghid push clobbered a foreign GIT_CONFIG_COUNT (regression)"
    fi

    ## --- ghid push is nounset-safe (status with no args under set -u) ---
    if zsh -c "
        set -u
        source \"$source_toolkit_file\"
        unset GH_CONFIG_DIR GH_ID_PUSH_ROUTE GIT_CONFIG_COUNT 2>/dev/null
        gh() { return 0; }
        ghid push        > /dev/null 2>&1 || exit 1   ## status default
        ghid push status > /dev/null 2>&1 || exit 1
        exit 0
    " 2>/dev/null; then
        pass_test "ghid push status is nounset-safe"
    else
        fail_test "ghid push status crashes under set -u"
    fi

    ## --- THE CORE GUARANTEE: identity resolves purely from the config dir ---
    ## No shared global state. The account is a function of GH_CONFIG_DIR alone,
    ## so querying dir A after dir B still yields A's account (no bleed/clobber).
    ## This is exactly what makes two concurrent shells independent.
    if zsh -c "
        source \"$source_toolkit_file\"
        ## Mock gh so the resolved account is derived from the queried dir.
        gh() {
            echo \"  ✓ Logged in to github.com account user-\${GH_CONFIG_DIR:t} (keyring)\"
            echo \"  - Active account: true\"
        }
        base=\"\$(mktemp -d)\"
        mkdir -p \"\$base/personal\" \"\$base/work\"
        a=\$(_gh_id_account_in_dir \"\$base/personal\")
        b=\$(_gh_id_account_in_dir \"\$base/work\")
        a_again=\$(_gh_id_account_in_dir \"\$base/personal\")
        [[ \"\$a\" == 'user-personal' ]] || exit 1
        [[ \"\$b\" == 'user-work' ]] || exit 1
        [[ \"\$a\" != \"\$b\" ]] || exit 1
        [[ \"\$a_again\" == 'user-personal' ]] || exit 1   ## querying B did not change A
        rm -rf \"\$base\"
        exit 0
    " 2>/dev/null; then
        pass_test "ISOLATION: account resolves purely from config dir — no shared-state clobber"
    else
        fail_test "ISOLATION guarantee failed — state bled between config dirs"
    fi
}
