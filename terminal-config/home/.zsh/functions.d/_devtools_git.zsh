#!/bin/zsh
# ============================================================================
# Git Helper Functions
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom functions, create your own file without _devtools_ prefix
# ============================================================================

# Clear conflicting aliases from oh-my-zsh git plugin
unalias gbd gbD gclean gcob gfb gwip gunwip gcom gpush gdiff 2>/dev/null

# ============================================================================
# Shared Helper: Detect default branch (main or master)
# ============================================================================
# Usage: local branch=$(_git_default_branch)
# Returns: "main" or "master" or empty string if neither found
# Note: First checks origin/HEAD (authoritative), then falls back to detection
# Warning: If BOTH exist without clear HEAD, warns user

_git_default_branch() {
    # First, check what the server says is default (most reliable)
    local head_ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null)
    if [[ -n "$head_ref" ]]; then
        # Extract branch name from refs/remotes/origin/main or refs/remotes/origin/master
        local from_head="${head_ref##*/}"
        if [[ "$from_head" == "main" || "$from_head" == "master" ]]; then
            echo "$from_head"
            return 0
        fi
    fi

    # Fallback: check what exists
    local has_main=0 has_master=0
    git rev-parse --verify origin/main &>/dev/null && has_main=1
    git rev-parse --verify origin/master &>/dev/null && has_master=1

    # Both exist but no clear HEAD - unusual state, warn user
    if [[ $has_main -eq 1 && $has_master -eq 1 ]]; then
        echo "⚠️  WARNING: Both origin/main AND origin/master exist!" >&2
        echo "   Could not determine default from origin/HEAD." >&2
        echo "   Using 'main'. Run: git remote set-head origin --auto" >&2
        echo ""  >&2
        echo "main"
        return 0
    fi

    # Normal cases
    if [[ $has_main -eq 1 ]]; then
        echo "main"
    elif [[ $has_master -eq 1 ]]; then
        echo "master"
    fi
    # Returns empty if neither found
}

# gcob - Git checkout new branch
# Usage: gcob <branch-name>
gcob() {
    if [[ -z "$1" ]]; then
        echo "Usage: gcob <branch-name>"
        return 1
    fi
    git checkout -b "$1"
}

# gbd - Git branch delete (with confirmation)
# Usage: gbd <branch-name>
gbd() {
    if [[ -z "$1" ]]; then
        echo "Usage: gbd <branch-name>"
        return 1
    fi
    echo "Delete branch '$1'? (y/n)"
    read -q && git branch -d "$1"
    echo ""
}

# gbD - Git branch force delete (with confirmation)
# Usage: gbD <branch-name>
gbD() {
    if [[ -z "$1" ]]; then
        echo "Usage: gbD <branch-name>"
        return 1
    fi
    echo "FORCE delete branch '$1'? (y/n)"
    read -q && git branch -D "$1"
    echo ""
}

# gfb - Git fetch and checkout branch (from remote)
# Usage: gfb <branch-name>
gfb() {
    if [[ -z "$1" ]]; then
        echo "Usage: gfb <branch-name>"
        return 1
    fi
    git fetch origin "$1" && git checkout "$1"
}

# gclean - Clean merged branches (except main/master/develop)
# Usage: gclean [--dry-run]
gclean() {
    local dry_run=""
    [[ "$1" == "--dry-run" ]] && dry_run="echo Would delete:"

    git branch --merged | grep -vE '^\*|main|master|develop' | while read branch; do
        if [[ -n "$dry_run" ]]; then
            echo "Would delete: $branch"
        else
            git branch -d "$branch"
        fi
    done
}

# gwip - Git work in progress commit
# Usage: gwip [message]
gwip() {
    git add -A
    git commit -m "WIP: ${1:-work in progress}"
}

# gunwip - Undo last WIP commit (keeps changes staged)
# Usage: gunwip
gunwip() {
    local last_msg=$(git log -1 --pretty=%s)
    if [[ "$last_msg" == WIP:* ]]; then
        git reset --soft HEAD~1
        echo "Undid WIP commit, changes are staged"
    else
        echo "Last commit is not a WIP commit: $last_msg"
        return 1
    fi
}

# gcom - Quick git add all and commit
gcom() {
    git add -A && git commit -m "$*"
}

# gpush - Quick git add, commit, and push
gpush() {
    git add -A && git commit -m "$*" && git push
}

# gdiff - Git diff with delta
gdiff() {
    git diff "$@" | delta
}

# ============================================================================
# Sync Branch - Update feature branch with latest main/master
# ============================================================================
# Usage: gsync [--merge|--rebase] [--step]
# Default: rebase, auto mode (shows steps but doesn't ask)

gsync() {
    local method="rebase"
    local step_mode=0
    local stashed=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --merge|-m)  method="merge"; shift ;;
            --rebase|-r) method="rebase"; shift ;;
            --step|-s)   step_mode=1; shift ;;
            --help|-h)
                cat << 'EOF'
gsync - Sync feature branch with latest main/master

Usage: gsync [options]

Options:
  --rebase, -r   Rebase onto main/master (default, cleaner history)
  --merge, -m    Merge main/master into branch (safer if already pushed)
  --step, -s     Step-by-step mode (ask before each action)
  --help, -h     Show this help

What it does:
  1. Checks for uncommitted changes (offers to stash)
  2. Detects if repo uses main or master
  3. Fetches latest from origin
  4. Shows what commits you're behind
  5. Rebases or merges your branch onto updated main/master

After syncing, push with:
  git push                      # if merge, or first push
  git push --force-with-lease   # if rebase (rewrites history)
EOF
                return 0
                ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
    done

    # Helper: prompt to continue in step mode
    _gsync_continue() {
        if [[ $step_mode -eq 1 ]]; then
            echo ""
            read -q "REPLY?   Continue? (y/n) "
            echo ""
            [[ "$REPLY" != "y" ]] && { echo "❌ Cancelled"; return 1; }
        fi
        return 0
    }

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 GSYNC - Sync Branch with Main/Master"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # ─────────────────────────────────────────────────────────────
    # STEP 1: Verify we're in a git repo
    # ─────────────────────────────────────────────────────────────
    echo "STEP 1: Check git repository"
    echo "  WHY:  Need to be in a git repo to do anything"
    echo "  CMD:  git rev-parse --git-dir"

    if ! git rev-parse --git-dir &>/dev/null; then
        echo "  ❌ FAIL: Not in a git repository"
        return 1
    fi
    echo "  ✓ OK: In a git repository"
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 2: Get current branch
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 2: Get current branch name"
    echo "  WHY:  Need to know which branch we're syncing"
    echo "  CMD:  git branch --show-current"

    local current_branch=$(git branch --show-current)
    if [[ -z "$current_branch" ]]; then
        echo "  ❌ FAIL: Not on a branch (detached HEAD state)"
        return 1
    fi
    echo "  ✓ OK: On branch '$current_branch'"
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 3: Detect default branch (main or master)
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 3: Detect default branch"
    echo "  WHY:  Repos use either 'main' or 'master' - need to find which"
    echo "  CMD:  _git_default_branch (checks origin/main, origin/master)"

    local default_branch=$(_git_default_branch)
    if [[ -z "$default_branch" ]]; then
        echo "  ❌ FAIL: Cannot find origin/main or origin/master"
        return 1
    fi
    echo "  ✓ OK: Default branch is '$default_branch'"
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 4: Check if we're already on default branch
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 4: Check if on default branch"
    echo "  WHY:  If already on $default_branch, just pull instead of sync"

    if [[ "$current_branch" == "$default_branch" ]]; then
        echo "  → Already on $default_branch - switching to simple pull"
        echo ""
        echo "STEP 4b: Pull latest $default_branch"
        echo "  CMD:  git pull origin $default_branch"
        _gsync_continue || return 1
        git pull origin "$default_branch"
        return $?
    fi
    echo "  ✓ OK: On feature branch, proceeding with sync"
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 5: Check for uncommitted changes
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 5: Check for uncommitted changes"
    echo "  WHY:  Can't rebase/merge with dirty working directory"
    echo "  CMD:  git diff-index --quiet HEAD"

    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "  ⚠️  WARNING: You have uncommitted changes"
        echo ""
        echo "  Options:"
        echo "    1. Stash them (gsync will restore after)"
        echo "    2. Cancel and commit them yourself"
        echo ""
        read -q "REPLY?  Stash changes and continue? (y/n) "
        echo ""
        if [[ "$REPLY" == "y" ]]; then
            echo "  CMD:  git stash push -m 'gsync auto-stash'"
            git stash push -m "gsync auto-stash"
            stashed=1
            echo "  ✓ Changes stashed"
        else
            echo "  ❌ Cancelled - commit or stash your changes first"
            return 1
        fi
    else
        echo "  ✓ OK: Working directory is clean"
    fi
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 6: Fetch latest from origin
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 6: Fetch latest from origin"
    echo "  WHY:  Get the newest commits from server without merging yet"
    echo "  CMD:  git fetch origin $default_branch"
    _gsync_continue || return 1

    if ! git fetch origin "$default_branch"; then
        echo "  ❌ FAIL: Fetch failed (network issue?)"
        [[ $stashed -eq 1 ]] && git stash pop
        return 1
    fi
    echo "  ✓ OK: Fetched latest origin/$default_branch"

    # ─────────────────────────────────────────────────────────────
    # STEP 7: Check how far behind we are
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 7: Check how far behind"
    echo "  WHY:  See if there's anything to sync"
    echo "  CMD:  git rev-list --count HEAD..origin/$default_branch"

    local behind=$(git rev-list --count HEAD..origin/$default_branch 2>/dev/null || echo "0")
    local ahead=$(git rev-list --count origin/$default_branch..HEAD 2>/dev/null || echo "0")

    echo "  → Your branch '$current_branch':"
    echo "      $behind commit(s) BEHIND origin/$default_branch (need to pull in)"
    echo "      $ahead commit(s) AHEAD of origin/$default_branch (your work)"

    if [[ "$behind" == "0" ]]; then
        echo ""
        echo "  ✓ Already up to date - nothing to sync!"
        [[ $stashed -eq 1 ]] && { echo "  Restoring stash..."; git stash pop; }
        return 0
    fi

    echo ""
    echo "  These commits will be added to your branch:"
    git log --oneline HEAD..origin/$default_branch | head -10
    [[ $behind -gt 10 ]] && echo "  ... and $((behind - 10)) more"
    _gsync_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 8: Do the sync (rebase or merge)
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 8: Sync using $method"

    if [[ "$method" == "rebase" ]]; then
        echo "  WHY:  Rebase replays your commits on top of latest $default_branch"
        echo "        Result: clean, linear history (as if you just started)"
        echo "  CMD:  git rebase origin/$default_branch"
        _gsync_continue || return 1

        if git rebase origin/$default_branch; then
            echo ""
            echo "  ✓ Rebase complete!"
        else
            echo ""
            echo "  ❌ CONFLICT: Rebase hit merge conflicts"
            echo ""
            echo "  To resolve:"
            echo "    1. Edit the conflicted files"
            echo "    2. git add <fixed-files>"
            echo "    3. git rebase --continue"
            echo ""
            echo "  To abort: git rebase --abort"
            [[ $stashed -eq 1 ]] && echo "  (stashed changes waiting - 'git stash pop' after resolving)"
            return 1
        fi
    else
        echo "  WHY:  Merge creates a merge commit combining both histories"
        echo "        Result: preserves exact history, but messier graph"
        echo "  CMD:  git merge origin/$default_branch"
        _gsync_continue || return 1

        if git merge origin/$default_branch -m "Merge $default_branch into $current_branch"; then
            echo ""
            echo "  ✓ Merge complete!"
        else
            echo ""
            echo "  ❌ CONFLICT: Merge hit conflicts"
            echo ""
            echo "  To resolve:"
            echo "    1. Edit the conflicted files"
            echo "    2. git add <fixed-files>"
            echo "    3. git commit"
            echo ""
            echo "  To abort: git merge --abort"
            [[ $stashed -eq 1 ]] && echo "  (stashed changes waiting - 'git stash pop' after resolving)"
            return 1
        fi
    fi

    # ─────────────────────────────────────────────────────────────
    # STEP 9: Restore stash if needed
    # ─────────────────────────────────────────────────────────────
    if [[ $stashed -eq 1 ]]; then
        echo ""
        echo "STEP 9: Restore stashed changes"
        echo "  CMD:  git stash pop"
        git stash pop
        echo "  ✓ Stashed changes restored"
    fi

    # ─────────────────────────────────────────────────────────────
    # DONE - Show next steps
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ SYNC COMPLETE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Your branch '$current_branch' now has latest from '$default_branch'"
    echo ""
    echo "NEXT STEPS:"
    if [[ "$method" == "rebase" ]]; then
        echo "  First push:      git push -u origin $current_branch"
        echo "  Already pushed:  git push --force-with-lease"
        echo "                   (force needed because rebase rewrote history)"
    else
        echo "  Push:  git push"
    fi
    echo ""
    echo "  Start new branch: gnew <branch-name>"
}

# ============================================================================
# New Branch - Start fresh branch from latest main/master
# ============================================================================
# Usage: gnew <branch-name> [--from-current]

gnew() {
    local step_mode=0
    local from_current=0
    local new_branch=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --step|-s)        step_mode=1; shift ;;
            --from-current)   from_current=1; shift ;;
            --help|-h)
                cat << 'EOF'
gnew - Start a new branch from latest main/master

Usage: gnew <branch-name> [options]

Options:
  --step, -s       Step-by-step mode (ask before each action)
  --from-current   Branch from current branch instead of main/master
  --help, -h       Show this help

What it does:
  1. Checks if you have unpushed commits (warns you)
  2. Fetches latest main/master from origin
  3. Creates new branch from origin/main (or origin/master)
  4. You're ready to work!

Common workflow:
  gnew feature-bar           # Start new work from latest main
  gnew hotfix --from-current # Branch from where you are now
EOF
                return 0
                ;;
            -*)
                echo "Unknown option: $1"
                return 1
                ;;
            *)
                new_branch="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$new_branch" ]]; then
        echo "Usage: gnew <branch-name>"
        echo "       gnew --help for more options"
        return 1
    fi

    # Helper: prompt to continue in step mode
    _gnew_continue() {
        if [[ $step_mode -eq 1 ]]; then
            echo ""
            read -q "REPLY?   Continue? (y/n) "
            echo ""
            [[ "$REPLY" != "y" ]] && { echo "❌ Cancelled"; return 1; }
        fi
        return 0
    }

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🌱 GNEW - Start New Branch"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # ─────────────────────────────────────────────────────────────
    # STEP 1: Verify we're in a git repo
    # ─────────────────────────────────────────────────────────────
    echo "STEP 1: Check git repository"
    echo "  CMD:  git rev-parse --git-dir"

    if ! git rev-parse --git-dir &>/dev/null; then
        echo "  ❌ FAIL: Not in a git repository"
        return 1
    fi
    echo "  ✓ OK: In a git repository"
    _gnew_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 2: Check current branch status
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 2: Check current branch status"
    echo "  WHY:  Make sure you didn't forget to push current work"

    local current_branch=$(git branch --show-current)
    echo "  → Currently on: $current_branch"

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo ""
        echo "  ⚠️  WARNING: You have uncommitted changes!"
        echo "     These will come with you to the new branch."
        echo ""
        read -q "REPLY?  Continue anyway? (y/n) "
        echo ""
        [[ "$REPLY" != "y" ]] && { echo "❌ Cancelled"; return 1; }
    fi

    # Check for unpushed commits
    local unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$unpushed" -gt 0 ]]; then
        echo ""
        echo "  ⚠️  WARNING: You have $unpushed unpushed commit(s) on '$current_branch'"
        git log --oneline @{u}..HEAD 2>/dev/null | head -5
        echo ""
        echo "  If you switch branches, these commits stay on '$current_branch'"
        read -q "REPLY?  Continue anyway? (y/n) "
        echo ""
        [[ "$REPLY" != "y" ]] && { echo "❌ Cancelled"; return 1; }
    else
        echo "  ✓ OK: No unpushed commits"
    fi
    _gnew_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 3: Check if new branch already exists
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 3: Check if branch '$new_branch' already exists"
    echo "  CMD:  git rev-parse --verify $new_branch"

    if git rev-parse --verify "$new_branch" &>/dev/null; then
        echo "  ⚠️  Branch '$new_branch' already exists locally"
        echo ""
        echo "  Options:"
        echo "    1. Switch to it: gco $new_branch"
        echo "    2. Delete it:    gbd $new_branch"
        echo "    3. Pick a different name"
        return 1
    fi
    if git rev-parse --verify "origin/$new_branch" &>/dev/null; then
        echo "  ⚠️  Branch '$new_branch' exists on remote"
        echo "  → To check it out: gfb $new_branch"
        return 1
    fi
    echo "  ✓ OK: Branch name '$new_branch' is available"
    _gnew_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 4: Determine base branch
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 4: Determine base branch"

    local base_branch=""
    if [[ $from_current -eq 1 ]]; then
        base_branch="$current_branch"
        echo "  → Using current branch: $base_branch (--from-current)"
    else
        echo "  WHY:  Starting from latest main/master gives you a clean base"
        echo "  CMD:  _git_default_branch (checks origin/main, origin/master)"

        local default=$(_git_default_branch)
        if [[ -z "$default" ]]; then
            echo "  ❌ FAIL: Cannot find origin/main or origin/master"
            return 1
        fi
        base_branch="origin/$default"
        echo "  ✓ OK: Will branch from $base_branch"
    fi
    _gnew_continue || return 1

    # ─────────────────────────────────────────────────────────────
    # STEP 5: Fetch latest (if using remote branch)
    # ─────────────────────────────────────────────────────────────
    if [[ "$base_branch" == origin/* ]]; then
        echo ""
        echo "STEP 5: Fetch latest from origin"
        echo "  WHY:  Make sure we have the newest commits before branching"
        echo "  CMD:  git fetch origin ${base_branch#origin/}"
        _gnew_continue || return 1

        if ! git fetch origin "${base_branch#origin/}"; then
            echo "  ❌ FAIL: Fetch failed"
            return 1
        fi
        echo "  ✓ OK: Fetched latest"
    fi

    # ─────────────────────────────────────────────────────────────
    # STEP 6: Create the new branch
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "STEP 6: Create and switch to new branch"
    echo "  CMD:  git checkout -b $new_branch $base_branch"
    _gnew_continue || return 1

    if ! git checkout -b "$new_branch" "$base_branch"; then
        echo "  ❌ FAIL: Could not create branch"
        return 1
    fi

    # ─────────────────────────────────────────────────────────────
    # DONE
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ BRANCH CREATED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Now on: $new_branch (based on $base_branch)"
    echo ""
    echo "NEXT STEPS:"
    echo "  1. Make your changes"
    echo "  2. git add . && git commit -m 'your message'"
    echo "  3. git push -u origin $new_branch"
    echo "  4. Create PR on GitHub"
    echo ""
    echo "OTHER COMMANDS:"
    echo "  gsync           # sync with latest main (before PR)"
    echo "  gbrecent        # see your recent branches"
}

# ============================================================================
# Git Audit - Comprehensive git health check
# ============================================================================
# Usage: gaudit [--fix]
# Checks for common git issues and offers to fix them

gaudit() {
    local auto_fix=0
    local issues_found=0
    local issues_fixed=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix|-f)   auto_fix=1; shift ;;
            --help|-h)
                cat << 'EOF'
gaudit - Git repository health check and cleanup

Usage: gaudit [options]

Options:
  --fix, -f    Automatically fix safe issues (with confirmation)
  --help, -h   Show this help

Checks performed:
  1. main/master confusion - both branches exist?
  2. Uncommitted changes - dirty working directory?
  3. Unpushed commits - local commits not on remote?
  4. Stale local branches - tracking deleted remote branches?
  5. Current branch behind - needs sync with default?
  6. Detached HEAD - not on a branch?

Each issue shows:
  - What's wrong
  - Why it matters
  - How to fix it (manual command or auto-fix option)
EOF
                return 0
                ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
    done

    # Check we're in a git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "❌ Not in a git repository"
        return 1
    fi

    local current_branch=$(git branch --show-current)
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local remote_url=$(git remote get-url origin 2>/dev/null)

    # Detect remote type
    local remote_type="unknown"
    local pr_command=""
    if [[ "$remote_url" == *"github.com"* ]]; then
        remote_type="GitHub"
        pr_command="gh pr create"
    elif [[ "$remote_url" == *"bitbucket"* ]]; then
        remote_type="Bitbucket"
        # Extract web URL from SSH URL for Bitbucket
        local bb_web_url=$(echo "$remote_url" | sed 's|ssh://git@\([^:]*\):\([0-9]*\)/\(.*\)\.git|https://\1/projects/\3|' | sed 's|/\([^/]*\)$|/repos/\1/pull-requests?create|')
        pr_command="Open: $bb_web_url"
    elif [[ "$remote_url" == *"gitlab"* ]]; then
        remote_type="GitLab"
        pr_command="git push -o merge_request.create"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 GIT AUDIT - Repository Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  Repo:     $repo_name"
    echo "  Branch:   ${current_branch:-DETACHED HEAD}"
    echo "  Remote:   $remote_type"
    echo "  URL:      $remote_url"

    # For GitHub, show which account
    if [[ "$remote_type" == "GitHub" ]]; then
        local gh_user=$(gh api user --jq '.login' 2>/dev/null)
        if [[ -n "$gh_user" ]]; then
            echo "  Account:  $gh_user"
        fi
    fi

    echo ""
    echo "  Create PR: $pr_command"
    echo ""

    # Fetch latest (needed for accurate checks)
    echo "Fetching latest from origin..."
    git fetch --prune origin &>/dev/null
    echo ""

    # Get default branch
    local default_branch=$(_git_default_branch)

    # ─────────────────────────────────────────────────────────────
    # CHECK 1: Detached HEAD
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 1: Detached HEAD state"
    if [[ -z "$current_branch" ]]; then
        ((issues_found++))
        echo "  ❌ ISSUE: You're in detached HEAD state"
        echo "  WHY:     You checked out a commit directly, not a branch"
        echo "           Changes here can be lost if you switch away"
        echo ""
        echo "  TO FIX:  Create a branch to save your position:"
        echo "           git checkout -b my-work"
        echo "           Or return to a branch:"
        echo "           gco $default_branch"
        echo ""
    else
        echo "  ✓ OK: On branch '$current_branch'"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # CHECK 2: Uncommitted changes
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 2: Uncommitted changes"
    local staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    local unstaged=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$staged" -gt 0 || "$unstaged" -gt 0 || "$untracked" -gt 0 ]]; then
        ((issues_found++))
        echo "  ⚠️  WARNING: You have uncommitted changes"
        echo "     Staged:    $staged file(s)"
        echo "     Unstaged:  $unstaged file(s)"
        echo "     Untracked: $untracked file(s)"
        echo ""
        echo "  WHY:     Uncommitted work can be lost or block operations"
        echo ""
        echo "  OPTIONS:"
        echo "     Commit:  git add . && git commit -m 'message'"
        echo "     Stash:   git stash -m 'description'"
        echo "     Review:  git status"
        echo ""
    else
        echo "  ✓ OK: Working directory is clean"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # CHECK 3: Unpushed commits
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 3: Unpushed commits"
    if [[ -n "$current_branch" ]]; then
        local unpushed=$(git log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')
        local has_upstream=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)

        if [[ -z "$has_upstream" ]]; then
            ((issues_found++))
            echo "  ⚠️  WARNING: Branch has no upstream (never pushed)"
            echo "  WHY:     Your work exists only locally - could be lost"
            echo ""
            echo "  TO FIX:  Push to create remote branch:"
            echo "           git push -u origin $current_branch"
            echo ""
        elif [[ "$unpushed" -gt 0 ]]; then
            ((issues_found++))
            echo "  ⚠️  WARNING: $unpushed unpushed commit(s)"
            git log --oneline @{u}..HEAD 2>/dev/null | head -5 | sed 's/^/     /'
            [[ "$unpushed" -gt 5 ]] && echo "     ... and $((unpushed - 5)) more"
            echo ""
            echo "  WHY:     Your work exists only locally - could be lost"
            echo ""
            echo "  TO FIX:  git push"
            echo ""
        else
            echo "  ✓ OK: All commits pushed"
        fi
    else
        echo "  ⏭️  SKIP: Not on a branch (detached HEAD)"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # CHECK 4: main/master confusion
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 4: main/master branch confusion"
    local other_branch=""
    [[ "$default_branch" == "main" ]] && other_branch="master"
    [[ "$default_branch" == "master" ]] && other_branch="main"

    local local_other=0 remote_other=0
    git rev-parse --verify "$other_branch" &>/dev/null && local_other=1
    git rev-parse --verify "origin/$other_branch" &>/dev/null && remote_other=1

    if [[ $local_other -eq 1 || $remote_other -eq 1 ]]; then
        ((issues_found++))
        echo "  ⚠️  WARNING: Both '$default_branch' AND '$other_branch' exist"
        echo ""
        printf "     %-10s  LOCAL   REMOTE\n" "BRANCH"
        printf "     %-10s  %-6s  %-6s  ← DEFAULT\n" "$default_branch" "✓" \
            "$([[ -n $(git rev-parse --verify origin/$default_branch 2>/dev/null) ]] && echo '✓' || echo '✗')"
        printf "     %-10s  %-6s  %-6s\n" "$other_branch" \
            "$([[ $local_other -eq 1 ]] && echo '✓' || echo '✗')" \
            "$([[ $remote_other -eq 1 ]] && echo '✓' || echo '✗')"
        echo ""
        echo "  WHY:     Confusing - which is the real default?"
        echo "           Server says: $default_branch"
        echo ""

        # Check if safe to delete
        if [[ $local_other -eq 1 ]]; then
            local ref_default="origin/$default_branch"
            local ref_other="$other_branch"
            [[ $remote_other -eq 1 ]] && ref_other="origin/$other_branch"

            local ahead=$(git rev-list --count $ref_default..$ref_other 2>/dev/null || echo "0")
            local behind=$(git rev-list --count $ref_other..$ref_default 2>/dev/null || echo "0")

            if [[ "$ahead" == "0" ]]; then
                echo "  📊 SAFE TO DELETE: '$other_branch' has no unique commits"
                echo "     It's just an old copy, $behind commits behind"
                echo ""
                echo "  TO FIX:"
                echo "     Delete local:  git branch -D $other_branch"
                [[ $remote_other -eq 1 ]] && echo "     Delete remote: git push origin --delete $other_branch"
                echo ""

                if [[ $auto_fix -eq 1 && "$current_branch" != "$other_branch" ]]; then
                    read -q "REPLY?  Delete local '$other_branch' now? (y/n) "
                    echo ""
                    if [[ "$REPLY" == "y" ]]; then
                        git branch -D "$other_branch" 2>/dev/null && echo "     ✓ Deleted" && ((issues_fixed++))
                    fi
                fi
            else
                echo "  ⚠️  REVIEW FIRST: '$other_branch' has $ahead unique commit(s)"
                echo "     These commits are NOT in '$default_branch':"
                git log --oneline $ref_default..$ref_other 2>/dev/null | head -3 | sed 's/^/        /'
                [[ "$ahead" -gt 3 ]] && echo "        ... and $((ahead - 3)) more"
                echo ""
                echo "  TO FIX:  Review commits, then delete if not needed:"
                echo "           git branch -D $other_branch"
            fi
        fi
    else
        echo "  ✓ OK: Only '$default_branch' exists (no confusion)"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # CHECK 5: Current branch behind default
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 5: Branch sync status"
    if [[ -n "$current_branch" && "$current_branch" != "$default_branch" ]]; then
        local behind_default=$(git rev-list --count HEAD..origin/$default_branch 2>/dev/null || echo "0")

        if [[ "$behind_default" -gt 0 ]]; then
            ((issues_found++))
            echo "  ⚠️  WARNING: '$current_branch' is $behind_default commits behind '$default_branch'"
            echo ""
            echo "  WHY:     Your branch doesn't have latest changes from $default_branch"
            echo "           May cause merge conflicts later"
            echo ""
            echo "  TO FIX:  gsync (rebases your branch onto latest $default_branch)"
            echo ""

            if [[ $auto_fix -eq 1 ]]; then
                echo -n "  Sync now with gsync? (y/N) "
                read -q "REPLY?"
                echo ""
                if [[ "$REPLY" == "y" ]]; then
                    echo ""
                    gsync
                    ((issues_fixed++))
                fi
            fi
        else
            echo "  ✓ OK: Branch is up to date with '$default_branch'"
        fi
    elif [[ "$current_branch" == "$default_branch" ]]; then
        local behind_origin=$(git rev-list --count HEAD..origin/$default_branch 2>/dev/null || echo "0")
        if [[ "$behind_origin" -gt 0 ]]; then
            ((issues_found++))
            echo "  ⚠️  WARNING: Local '$default_branch' is $behind_origin commits behind origin"
            echo ""
            echo "  TO FIX:  git pull"
            echo ""

            if [[ $auto_fix -eq 1 ]]; then
                echo -n "  Pull now? (y/N) "
                read -q "REPLY?"
                echo ""
                if [[ "$REPLY" == "y" ]]; then
                    echo ""
                    git pull
                    ((issues_fixed++))
                fi
            fi
        else
            echo "  ✓ OK: '$default_branch' is up to date"
        fi
    else
        echo "  ⏭️  SKIP: Not on a branch"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # CHECK 6: Stale local branches (tracking deleted remotes)
    # ─────────────────────────────────────────────────────────────
    echo "CHECK 6: Stale local branches"
    local stale_branches=()
    while IFS= read -r branch; do
        [[ -z "$branch" ]] && continue
        local tracking=$(git config --get "branch.$branch.remote" 2>/dev/null)
        local merge=$(git config --get "branch.$branch.merge" 2>/dev/null)
        if [[ -n "$tracking" && -n "$merge" ]]; then
            local remote_ref="refs/remotes/$tracking/${merge#refs/heads/}"
            if ! git rev-parse --verify "$remote_ref" &>/dev/null; then
                stale_branches+=("$branch")
            fi
        fi
    done < <(git branch --format='%(refname:short)')

    if [[ ${#stale_branches[@]} -gt 0 ]]; then
        ((issues_found++))
        echo "  ⚠️  WARNING: ${#stale_branches[@]} local branch(es) track deleted remotes:"
        for b in "${stale_branches[@]}"; do
            echo "     - $b"
        done
        echo ""
        echo "  WHY:     Remote branches were deleted (PR merged?) but local copies remain"
        echo ""

        if [[ $auto_fix -eq 1 ]]; then
            echo "  Delete stale branches? (y/N for each, 'a' for all, 's' to skip all)"
            echo ""
            local delete_all=0
            for b in "${stale_branches[@]}"; do
                if [[ "$b" == "$current_branch" ]]; then
                    echo "     ⏭️  $b - SKIPPED (current branch)"
                    continue
                fi

                if [[ $delete_all -eq 1 ]]; then
                    git branch -d "$b" 2>/dev/null && echo "     ✓ $b - DELETED" && ((issues_fixed++)) || \
                    git branch -D "$b" 2>/dev/null && echo "     ✓ $b - FORCE DELETED" && ((issues_fixed++))
                    continue
                fi

                echo -n "     Delete '$b'? (y/N/a=all/s=skip rest) "
                read -k 1 REPLY
                echo ""
                case "$REPLY" in
                    y|Y)
                        git branch -d "$b" 2>/dev/null && echo "        ✓ Deleted" && ((issues_fixed++)) || {
                            echo -n "        Not fully merged. Force delete? (y/N) "
                            read -q "FORCE?"
                            echo ""
                            [[ "$FORCE" == "y" ]] && git branch -D "$b" && echo "        ✓ Force deleted" && ((issues_fixed++))
                        }
                        ;;
                    a|A)
                        delete_all=1
                        git branch -d "$b" 2>/dev/null && echo "        ✓ Deleted" && ((issues_fixed++)) || \
                        git branch -D "$b" 2>/dev/null && echo "        ✓ Force deleted" && ((issues_fixed++))
                        ;;
                    s|S)
                        echo "        Skipping remaining branches"
                        break
                        ;;
                    *)
                        echo "        Skipped"
                        ;;
                esac
            done
        else
            echo "  TO FIX:  Delete stale branches:"
            for b in "${stale_branches[@]}"; do
                echo "           git branch -d $b"
            done
            echo ""
            echo "  OR:      gclean  (deletes all merged branches)"
            echo "  OR:      gaudit --fix  (interactive cleanup)"
        fi
        echo ""
    else
        echo "  ✓ OK: No stale branches"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────────
    # SUMMARY
    # ─────────────────────────────────────────────────────────────
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ $issues_found -eq 0 ]]; then
        echo "✅ ALL CLEAR - No issues found!"
    else
        echo "📊 SUMMARY: $issues_found issue(s) found"
        [[ $issues_fixed -gt 0 ]] && echo "            $issues_fixed issue(s) fixed"
        echo ""
        echo "💡 Run 'gaudit --fix' to interactively fix issues"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Keep gbaudit as alias for backwards compatibility
alias gbaudit='gaudit'

# ============================================================================
# Recent Branches - Show branches by recent activity
# ============================================================================
# Usage: gbrecent [count]

gbrecent() {
    local count="${1:-10}"

    if ! git rev-parse --git-dir &>/dev/null; then
        echo "❌ Not in a git repository"
        return 1
    fi

    echo "🕐 Recent branches (by last commit):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show branches sorted by committer date
    git branch --sort=-committerdate --format='%(refname:short)' | head -$count | while read branch; do
        local date=$(git log -1 --format='%cr' "$branch" 2>/dev/null)
        local subject=$(git log -1 --format='%s' "$branch" 2>/dev/null | cut -c1-50)
        printf "  %-25s %s\n" "$branch" "$date"
        printf "  %-25s %s\n" "" "└─ $subject"
    done

    echo ""
    echo "💡 Switch: gco <branch> | Delete merged: gclean"
}

# gbhistory - Show branches by checkout history (what you actually worked on)
# Usage: gbhistory [count]
gbhistory() {
    local count="${1:-10}"

    if ! git rev-parse --git-dir &>/dev/null; then
        echo "❌ Not in a git repository"
        return 1
    fi

    echo "📜 Branch checkout history (most recent first):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Parse reflog for checkout events, dedupe, show recent
    git reflog --format='%gs' | \
        grep '^checkout:' | \
        sed 's/checkout: moving from .* to //' | \
        awk '!seen[$0]++' | \
        head -$count | \
        while read branch; do
            # Check if branch still exists
            if git rev-parse --verify "$branch" &>/dev/null; then
                local date=$(git log -1 --format='%cr' "$branch" 2>/dev/null)
                printf "  %-25s %s\n" "$branch" "(last commit: $date)"
            else
                printf "  %-25s %s\n" "$branch" "(deleted or remote)"
            fi
        done

    echo ""
    echo "💡 This shows branches you actually checked out, in order"
}

# ============================================================================
# Self-test function (used by devsetup test)
# ============================================================================
_test_devtools_git() {
    local passed=0 failed=0

    # Test that functions are defined
    for func in gcob gbd gbD gfb gclean gwip gunwip gsync gnew gaudit gbrecent gbhistory; do
        if typeset -f "$func" > /dev/null 2>&1; then
            ((passed++))
        else
            echo "FAIL: $func not defined"
            ((failed++))
        fi
    done

    # Test git is available
    if command -v git > /dev/null 2>&1; then
        ((passed++))
    else
        echo "FAIL: git not installed"
        ((failed++))
    fi

    echo "Git functions: $passed passed, $failed failed"
    return $failed
}
