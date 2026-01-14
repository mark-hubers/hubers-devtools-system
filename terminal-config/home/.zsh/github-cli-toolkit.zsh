# ============================================================================
# GITHUB CLI (gh) TOOLKIT - Enhanced with fzf
# Makes GitHub workflows fast and easy from the terminal!
# ============================================================================

# Check if gh is installed
_gh_check() {
  if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo ""
    echo "Install:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  brew install gh"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
      echo "  See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    fi
    echo ""
    echo "After installing, run: gh auth login"
    return 1
  fi
  
  # Check if authenticated
  if ! gh auth status &>/dev/null; then
    echo "⚠️  Not authenticated with GitHub"
    echo ""
    echo "Run: gh auth login"
    echo "Or: ghlogin"
    return 1
  fi
  
  return 0
}

# ====================================
# AUTHENTICATION & SETUP
# ====================================

# ====================================
# ACCOUNT MANAGEMENT (Improved UX)
# ====================================

# List all GitHub accounts in gh CLI
ghlist() {
  echo "📋 GitHub Accounts in gh CLI"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local accounts=$(gh auth status 2>&1)

  if echo "$accounts" | grep -q "Logged in"; then
    echo "$accounts" | grep -E "(Logged in|Active account|Token scopes|Git operations)" | while read line; do
      echo "  $line"
    done
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Commands: ghadd (add new) | ghswitch (change) | ghremove (delete)"
  else
    echo "  No accounts configured yet."
    echo ""
    echo "  Run 'ghadd' to add your first account."
  fi
}

# Add a new GitHub account (guided)
ghadd() {
  echo "➕ Add GitHub Account"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Show existing accounts first
  local existing=$(gh auth status 2>&1 | grep "Logged in" | sed 's/.*account //' | sed 's/ .*//')
  if [[ -n "$existing" ]]; then
    echo "📌 Already configured:"
    echo "$existing" | while read acct; do
      echo "   • $acct"
    done
    echo ""
  fi

  echo "What type of account are you adding?"
  echo ""
  echo "  1) Personal GitHub (github.com) - Web browser login"
  echo "  2) Personal GitHub (github.com) - Paste token (easier for multi-account)"
  echo "  3) Work - GitHub Enterprise Cloud (SSO/SAML) - github.com with company SSO"
  echo "  4) Work - GitHub Enterprise Server (self-hosted) - your-company.github.com"
  echo ""
  echo "💡 Most work accounts use option 3 (Enterprise Cloud)"
  echo "   Option 4 is only if your company runs their own GitHub server"
  echo ""

  read "choice?Select (1-4): "
  echo ""

  case $choice in
    1)
      echo "🌐 Personal GitHub - Web Browser"
      echo ""
      echo "⚠️  IMPORTANT: Check which account you're logged into in your browser!"
      echo "   The account shown in browser is what gets added."
      echo ""
      read "confirm?Ready to open browser? (y/n): "
      if [[ $confirm == "y" ]]; then
        gh auth login --hostname github.com --git-protocol https --web
      fi
      ;;
    2)
      echo "🔑 Personal GitHub - Token"
      echo ""
      echo "Steps to get a token:"
      echo "  1. Go to: https://github.com/settings/tokens/new"
      echo "  2. Make sure you're logged in as the RIGHT account (check top-right)"
      echo "  3. Note: 'gh-cli-<username>'"
      echo "  4. Select scopes: repo, read:org, gist"
      echo "  5. Generate and copy the token"
      echo ""
      read "ready?Press Enter when you have the token..."
      gh auth login --hostname github.com --git-protocol https --with-token
      ;;
    3)
      echo "🏢 Work/Enterprise GitHub (SSO)"
      echo ""
      echo "This will:"
      echo "  1. Open your browser"
      echo "  2. Redirect to your company's SSO login (Active Directory, Okta, etc.)"
      echo "  3. You'll enter your work credentials + 2FA code"
      echo "  4. Token gets saved automatically"
      echo ""
      read "org?Enter your GitHub organization name (or press Enter to skip): "
      echo ""
      read "confirm?Ready to open browser for SSO? (y/n): "
      if [[ $confirm == "y" ]]; then
        gh auth login --hostname github.com --git-protocol https --web
        if [[ -n "$org" ]]; then
          echo ""
          echo "💡 After login, you may need to authorize SSO for org: $org"
          echo "   Run: gh auth refresh -h github.com -s read:org"
        fi
      fi
      ;;
    4)
      echo "🖥️  GitHub Enterprise Server (self-hosted)"
      echo ""
      read "hostname?Enter your GHE hostname (e.g., github.mycompany.com): "
      if [[ -n "$hostname" ]]; then
        echo ""
        gh auth login --hostname "$hostname" --git-protocol https --web
      fi
      ;;
    *)
      echo "❌ Invalid choice"
      return 1
      ;;
  esac

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Current accounts:"
  ghlist
}

# Test GitHub account connectivity
ghtest() {
  echo "🧪 GitHub Account Test"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Get current account
  local current=$(gh auth status 2>&1 | grep "Logged in" | head -1 | sed 's/.*account //' | sed 's/ .*//')

  if [[ -z "$current" ]]; then
    echo "❌ No account logged in"
    echo "   Run 'ghadd' to add an account"
    return 1
  fi

  echo "Testing account: $current"
  echo ""

  # Test 1: API access
  echo -n "  API access:        "
  if gh api user --jq '.login' &>/dev/null; then
    local login=$(gh api user --jq '.login' 2>/dev/null)
    echo "✅ $login"
  else
    echo "❌ Failed"
    return 1
  fi

  # Test 2: Get user info
  echo -n "  User info:         "
  local name=$(gh api user --jq '.name // "not set"' 2>/dev/null)
  local email=$(gh api user --jq '.email // "private"' 2>/dev/null)
  echo "✅ $name <$email>"

  # Test 3: List repos (just count)
  echo -n "  Repo access:       "
  local repo_output=$(gh repo list --limit 5 --json name 2>&1)
  if echo "$repo_output" | grep -q '"name"'; then
    echo "✅ Can list repos"
  else
    echo "⚠️  No repos or no access"
  fi

  # Test 4: Check token scopes (only for active account)
  echo -n "  Token scopes:      "
  local scopes=$(gh auth status 2>&1 | awk '/Active account: true/{found=1} found && /Token scopes/{print; exit}' | sed "s/.*Token scopes: //" | tr -d "'")
  if [[ -n "$scopes" ]]; then
    echo "✅ $scopes"
  else
    echo "⚠️  Could not determine scopes"
  fi

  # Test 5: Check for SSO (org access)
  echo -n "  SSO/Org access:    "
  local orgs=$(gh api user/orgs --jq '.[].login' 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
  if [[ -n "$orgs" ]]; then
    echo "✅ $orgs"
  else
    echo "ℹ️  No orgs (or SSO not authorized)"
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Account '$current' is working!"
  echo ""
  echo "💡 To test a different account:"
  echo "   ghswitch          # Switch to another account"
  echo "   ghtest            # Test again"
}

# Remove a GitHub account
ghremove() {
  echo "🗑️  Remove GitHub Account"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Show current accounts
  ghlist
  echo ""

  read "user?Enter username to remove (or 'cancel'): "

  if [[ "$user" == "cancel" || -z "$user" ]]; then
    echo "Cancelled."
    return 0
  fi

  echo ""
  read "confirm?Remove account '$user'? (y/n): "

  if [[ $confirm == "y" ]]; then
    gh auth logout --user "$user"
    echo ""
    echo "✅ Removed: $user"
  else
    echo "Cancelled."
  fi
}

# Quick GitHub auth (legacy - use ghadd instead)
ghlogin() {
  echo "💡 Tip: Use 'ghadd' for guided account setup"
  echo ""
  echo "🔐 GitHub CLI Authentication"
  echo ""
  gh auth login
}

# Check auth status
ghstatus() {
  echo "🔍 GitHub CLI Status"
  echo ""
  gh auth status
}

# Switch between GitHub accounts (if you have multiple)
ghswitch() {
  echo "🔄 GitHub Account Switcher"
  echo ""

  local count=$(gh auth status 2>&1 | grep -c "Logged in")

  if [[ $count -lt 2 ]]; then
    echo "Only one account configured. Use 'ghadd' to add more."
    echo ""
    ghlist
    return 0
  fi

  gh auth switch
}

# ====================================
# MULTI-ACCOUNT AUTO-SWITCHING
# ====================================
# Automatically switches gh account based on repo owner or directory

# Configuration: Map GitHub usernames to account names in gh
# Add your accounts here (owner -> gh account name)
typeset -gA GH_ACCOUNT_MAP
GH_ACCOUNT_MAP=(
  "mark-hubers"    "mark-hubers"      # Personal primary
  "markhubers"     "markhubers"       # Personal secondary
  # "work-org"     "work-sso"         # Work SSO (add when ready)
)

# Directory-based overrides (optional)
# Map directory patterns to accounts
typeset -gA GH_DIR_ACCOUNT_MAP
GH_DIR_ACCOUNT_MAP=(
  # "$HOME/work/*"     "work-sso"     # All repos in ~/work/ use work account
  # "$HOME/personal/*" "mark-hubers"  # All repos in ~/personal/ use personal
)

# Get current gh account (the active one)
_gh_current_account() {
  # Find the account where "Active account: true" appears after "Logged in"
  gh auth status 2>&1 | awk '
    /Logged in to github.com account/ { acct = $7; gsub(/\(.*/, "", acct) }
    /Active account: true/ { print acct; exit }
  '
}

# Get repo owner from current directory
_gh_repo_owner() {
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null) || return 1

  # Extract owner from various URL formats
  # git@github.com:owner/repo.git
  # https://github.com/owner/repo.git
  # git@github-alias:owner/repo.git
  echo "$remote_url" | sed -E 's#^(git@[^:]+:|https://[^/]+/)([^/]+)/.*#\2#'
}

# Get required account for current directory
_gh_required_account() {
  local current_dir="$PWD"
  local owner

  # First check directory-based overrides
  for pattern account in ${(kv)GH_DIR_ACCOUNT_MAP}; do
    if [[ "$current_dir" == ${~pattern} ]]; then
      echo "$account"
      return 0
    fi
  done

  # Then check repo owner
  owner=$(_gh_repo_owner) || return 1

  # Look up account for this owner
  if [[ -n "${GH_ACCOUNT_MAP[$owner]}" ]]; then
    echo "${GH_ACCOUNT_MAP[$owner]}"
    return 0
  fi

  # Owner not in map
  return 1
}

# Auto-switch to correct account for current repo
ghauto() {
  local current_account required_account owner

  current_account=$(_gh_current_account)
  required_account=$(_gh_required_account)
  owner=$(_gh_repo_owner)

  if [[ -z "$required_account" ]]; then
    if [[ -n "$owner" ]]; then
      echo "⚠️  Owner '$owner' not in GH_ACCOUNT_MAP"
      echo "   Add to ~/.zsh/github-cli-toolkit.zsh or use 'ghswitch'"
    else
      echo "📁 Not in a git repo with GitHub remote"
    fi
    return 1
  fi

  if [[ "$current_account" == "$required_account" ]]; then
    echo "✅ Already using correct account: $current_account"
    return 0
  fi

  echo "🔄 Switching: $current_account -> $required_account"
  if gh auth switch --user "$required_account" 2>/dev/null; then
    echo "✅ Now using: $required_account"
  else
    echo "❌ Failed to switch. Is '$required_account' logged in?"
    echo "   Run: gh auth login"
  fi
}

# Show which account should be used here
ghwho() {
  local current_account required_account owner

  current_account=$(_gh_current_account)
  required_account=$(_gh_required_account)
  owner=$(_gh_repo_owner)

  echo "📍 GitHub Account Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Current account:  $current_account"
  echo "Repo owner:       ${owner:-"(not a GitHub repo)"}"
  echo "Required account: ${required_account:-"(unknown)"}"

  if [[ -n "$required_account" && "$current_account" != "$required_account" ]]; then
    echo ""
    echo "⚠️  Account mismatch! Run 'ghauto' to switch"
  elif [[ -n "$required_account" ]]; then
    echo ""
    echo "✅ Correct account active"
  fi
}

# List all configured accounts
ghaccounts() {
  echo "📋 GitHub Accounts"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Logged in:"
  gh auth status 2>&1 | grep -E "(Logged in|Active account)"
  echo ""
  echo "Account mappings:"
  for owner account in ${(kv)GH_ACCOUNT_MAP}; do
    printf "  %-20s -> %s\n" "$owner" "$account"
  done
  echo ""
  echo "Commands:"
  echo "  ghauto     - Auto-switch to correct account for this repo"
  echo "  ghwho      - Show current vs required account"
  echo "  ghswitch   - Manual account switch"
  echo "  gh auth login - Add new account"
}

# Hook to auto-switch on directory change (optional - can slow down cd)
# Uncomment to enable automatic switching when you cd into a repo
# _gh_auto_switch_hook() {
#   [[ -d .git ]] && ghauto 2>/dev/null
# }
# add-zsh-hook chpwd _gh_auto_switch_hook

# ====================================
# REPOSITORY OPERATIONS
# ====================================

# Clone repo with fzf selection from your repos
ghclone() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    # Direct clone
    echo "📥 Cloning: $1"
    gh repo clone "$1"
  else
    # Interactive selection
    echo "📋 Select repository to clone:"
    echo ""
    
    local repo=$(gh repo list --limit 100 | fzf --height=40% --prompt="Clone> " --preview='gh repo view {1}' | awk '{print $1}')
    
    if [[ -n "$repo" ]]; then
      echo ""
      echo "📥 Cloning: $repo"
      gh repo clone "$repo"
    else
      echo "❌ No repository selected"
    fi
  fi
}

# View repo details (current or specified)
ghrepo() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh repo view "$1"
  else
    gh repo view
  fi
}

# Open repo in browser
ghopen() {
  _gh_check || return 1
  
  gh browse
}

# List your repositories with fzf
ghrepos() {
  _gh_check || return 1
  
  echo "📚 Your Repositories"
  echo ""
  
  local repo=$(gh repo list --limit 100 | fzf --height=40% --prompt="Repository> " --preview='gh repo view {1}')
  
  if [[ -n "$repo" ]]; then
    local repo_name=$(echo "$repo" | awk '{print $1}')
    echo ""
    echo "📦 Repository: $repo_name"
    echo ""
    
    read "action?[v]iew | [o]pen | [c]lone | [q]uit: "
    
    case $action in
      v) gh repo view "$repo_name" ;;
      o) gh browse -R "$repo_name" ;;
      c) gh repo clone "$repo_name" ;;
      *) ;;
    esac
  fi
}

# Create new repo (interactive)
ghcreate() {
  _gh_check || return 1
  
  echo "🆕 Create New Repository"
  echo ""
  gh repo create
}

# Fork a repository
ghfork() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh repo fork "$1" --clone
  else
    gh repo fork --clone
  fi
}

# ====================================
# PULL REQUESTS
# ====================================

# Interactive PR dashboard
ghprs() {
  _gh_check || return 1
  
  echo "🔀 Pull Requests"
  echo ""
  
  local pr=$(gh pr list | fzf --height=40% --prompt="PR> " --preview='gh pr view {1}')
  
  if [[ -n "$pr" ]]; then
    local pr_number=$(echo "$pr" | awk '{print $1}')
    echo ""
    echo "📋 PR #$pr_number"
    echo ""
    
    read "action?[v]iew | [c]heckout | [d]iff | [m]erge | [o]pen | [q]uit: "
    
    case $action in
      v) gh pr view "$pr_number" ;;
      c) gh pr checkout "$pr_number" ;;
      d) gh pr diff "$pr_number" ;;
      m) gh pr merge "$pr_number" ;;
      o) gh pr view "$pr_number" --web ;;
      *) ;;
    esac
  fi
}

# Create PR from current branch
ghpr() {
  _gh_check || return 1
  
  echo "🔀 Create Pull Request"
  echo ""
  gh pr create
}

# Check PR status for current branch
ghprstatus() {
  _gh_check || return 1
  
  echo "📊 PR Status"
  echo ""
  gh pr status
}

# Review PR
ghreview() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh pr review "$1"
  else
    # Select PR to review
    local pr=$(gh pr list | fzf --height=40% --prompt="Review PR> " --preview='gh pr view {1}' | awk '{print $1}')
    
    if [[ -n "$pr" ]]; then
      gh pr review "$pr"
    fi
  fi
}

# Checkout PR by number
ghprco() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh pr checkout "$1"
  else
    local pr=$(gh pr list | fzf --height=40% --prompt="Checkout PR> " | awk '{print $1}')
    
    if [[ -n "$pr" ]]; then
      gh pr checkout "$pr"
    fi
  fi
}

# ====================================
# ISSUES
# ====================================

# Interactive issue browser
ghissues() {
  _gh_check || return 1
  
  echo "🐛 Issues"
  echo ""
  
  local issue=$(gh issue list | fzf --height=40% --prompt="Issue> " --preview='gh issue view {1}')
  
  if [[ -n "$issue" ]]; then
    local issue_number=$(echo "$issue" | awk '{print $1}')
    echo ""
    echo "🐛 Issue #$issue_number"
    echo ""
    
    read "action?[v]iew | [c]omment | [e]dit | [o]pen | [d]evelop | [q]uit: "
    
    case $action in
      v) gh issue view "$issue_number" ;;
      c) gh issue comment "$issue_number" ;;
      e) gh issue edit "$issue_number" ;;
      o) gh issue view "$issue_number" --web ;;
      d) gh issue develop "$issue_number" --checkout ;;
      *) ;;
    esac
  fi
}

# Create new issue
ghissue() {
  _gh_check || return 1
  
  echo "🐛 Create New Issue"
  echo ""
  gh issue create
}

# Develop (create branch) from issue
ghdev() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh issue develop "$1" --checkout
  else
    local issue=$(gh issue list | fzf --height=40% --prompt="Develop Issue> " | awk '{print $1}')
    
    if [[ -n "$issue" ]]; then
      gh issue develop "$issue" --checkout
    fi
  fi
}

# ====================================
# BRANCHES
# ====================================

# Interactive branch switcher (fuzzy find)
ghbranch() {
  _gh_check || return 1
  
  # Get all branches
  local branch=$(git branch -a | sed 's/^[* ]*//' | sed 's#remotes/origin/##' | sort -u | fzf --height=40% --prompt="Branch> " --preview='git log --oneline --graph --color=always {}' | xargs)
  
  if [[ -n "$branch" ]]; then
    git checkout "$branch"
  fi
}

# Create new branch
ghnewbranch() {
  if [[ -z "$1" ]]; then
    echo "Usage: ghnewbranch <branch-name>"
    return 1
  fi
  
  git checkout -b "$1"
  echo "✅ Created and switched to branch: $1"
}

# ====================================
# WORKFLOWS (GitHub Actions)
# ====================================

# List workflow runs
ghruns() {
  _gh_check || return 1
  
  echo "🔄 Workflow Runs"
  echo ""
  
  local run=$(gh run list --limit 20 | fzf --height=40% --prompt="Run> " --preview='gh run view {1}')
  
  if [[ -n "$run" ]]; then
    local run_id=$(echo "$run" | awk '{print $7}')
    echo ""
    echo "🔄 Run: $run_id"
    echo ""
    
    read "action?[v]iew | [l]ogs | [w]atch | [o]pen | [q]uit: "
    
    case $action in
      v) gh run view "$run_id" ;;
      l) gh run view "$run_id" --log ;;
      w) gh run watch "$run_id" ;;
      o) gh run view "$run_id" --web ;;
      *) ;;
    esac
  fi
}

# Watch current workflow run
ghwatch() {
  _gh_check || return 1
  
  echo "👁️  Watching workflow run..."
  gh run watch
}

# View workflow logs
ghlogs() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh run view "$1" --log
  else
    local run=$(gh run list --limit 20 | fzf --height=40% --prompt="View Logs> " | awk '{print $7}')
    
    if [[ -n "$run" ]]; then
      gh run view "$run" --log
    fi
  fi
}

# ====================================
# GISTS
# ====================================

# List your gists
ghgists() {
  _gh_check || return 1
  
  echo "📝 Your Gists"
  echo ""
  
  local gist=$(gh gist list --limit 50 | fzf --height=40% --prompt="Gist> " --preview='gh gist view {1}')
  
  if [[ -n "$gist" ]]; then
    local gist_id=$(echo "$gist" | awk '{print $1}')
    echo ""
    
    read "action?[v]iew | [e]dit | [o]pen | [d]elete | [q]uit: "
    
    case $action in
      v) gh gist view "$gist_id" ;;
      e) gh gist edit "$gist_id" ;;
      o) gh gist view "$gist_id" --web ;;
      d) gh gist delete "$gist_id" ;;
      *) ;;
    esac
  fi
}

# Create gist from file or stdin
ghgist() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh gist create "$@"
  else
    echo "Usage: ghgist <file> [--public|--private]"
    echo "   Or: echo 'content' | ghgist -"
  fi
}

# ====================================
# ORGANIZATION
# ====================================

# List organization repos
ghorg() {
  _gh_check || return 1
  
  if [[ -z "$1" ]]; then
    echo "Usage: ghorg <org-name>"
    return 1
  fi
  
  echo "🏢 Organization: $1"
  echo ""
  
  local repo=$(gh repo list "$1" --limit 100 | fzf --height=40% --prompt="Org Repo> " --preview="gh repo view $1/{1}")
  
  if [[ -n "$repo" ]]; then
    local repo_name=$(echo "$repo" | awk '{print $1}')
    echo ""
    
    read "action?[v]iew | [c]lone | [o]pen | [q]uit: "
    
    case $action in
      v) gh repo view "$1/$repo_name" ;;
      c) gh repo clone "$1/$repo_name" ;;
      o) gh browse -R "$1/$repo_name" ;;
      *) ;;
    esac
  fi
}

# ====================================
# API & ADVANCED
# ====================================

# Quick API access
ghapi() {
  _gh_check || return 1
  
  if [[ -z "$1" ]]; then
    echo "Usage: ghapi <endpoint> [options]"
    echo ""
    echo "Examples:"
    echo "  ghapi user"
    echo "  ghapi repos/owner/repo"
    echo "  ghapi orgs/myorg/repos"
    return 1
  fi
  
  gh api "$@"
}

# Search repositories
ghsearch() {
  _gh_check || return 1
  
  if [[ -z "$1" ]]; then
    echo "Usage: ghsearch <query>"
    echo "Example: ghsearch 'language:python stars:>1000'"
    return 1
  fi
  
  gh search repos "$@"
}

# ====================================
# RELEASES
# ====================================

# List releases
ghreleases() {
  _gh_check || return 1
  
  echo "🏷️  Releases"
  echo ""
  
  gh release list
}

# Create release
ghrelease() {
  _gh_check || return 1
  
  echo "🏷️  Create Release"
  echo ""
  gh release create
}

# Download release asset
ghdownload() {
  _gh_check || return 1
  
  if [[ -n "$1" ]]; then
    gh release download "$1"
  else
    gh release download
  fi
}

# ====================================
# NOTIFICATIONS
# ====================================

# Check notifications
ghnotify() {
  _gh_check || return 1
  
  echo "🔔 Notifications"
  echo ""
  gh api notifications --jq '.[] | "\(.repository.full_name): \(.subject.title)"'
}

# ====================================
# QUICK SHORTCUTS
# ====================================

# Show current repo info
ghinfo() {
  _gh_check || return 1
  
  echo "📊 Repository Information"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  gh repo view
}

# Quick commit and push with PR creation
ghpush() {
  if [[ -z "$1" ]]; then
    echo "Usage: ghpush <commit-message>"
    return 1
  fi
  
  git add .
  git commit -m "$1"
  git push
  
  read "create_pr?Create PR? (y/n): "
  
  if [[ $create_pr == "y" ]]; then
    gh pr create
  fi
}

# ====================================
# EXTENSIONS
# ====================================

# Browse and install extensions
ghext() {
  _gh_check || return 1
  
  echo "🧩 GitHub CLI Extensions"
  echo ""
  gh extension browse
}

# List installed extensions
ghextlist() {
  _gh_check || return 1
  
  echo "🧩 Installed Extensions"
  echo ""
  gh extension list
}

# Install extension
ghextinstall() {
  _gh_check || return 1
  
  if [[ -z "$1" ]]; then
    echo "Usage: ghextinstall <extension-name>"
    echo ""
    echo "Popular extensions:"
    echo "  gh extension install dlvhdr/gh-dash      # PR/Issue dashboard"
    echo "  gh extension install github/gh-copilot   # GitHub Copilot"
    echo "  gh extension install mislav/gh-branch    # Branch switcher"
    return 1
  fi
  
  gh extension install "$@"
}

# ====================================
# HELP
# ====================================

ghhelp() {
  cat << 'EOF'
🐙 GITHUB CLI TOOLKIT - Quick Reference
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETUP & CONFIGURATION (Work SSO Support!):
  ghsetup           - Interactive GitHub setup (for work SSO)
  ghconfig          - Show current GitHub configuration
  ghtoken           - Interactive token management
  ghtoken-check     - Verify token works

ACCOUNT MANAGEMENT:
  ghlist            - List all configured accounts
  ghadd             - Add new account (guided - personal/token/SSO/enterprise)
  ghtest            - Test current account connectivity
  ghremove          - Remove an account
  ghswitch          - Switch between accounts (fzf)
  ghauto            - Auto-switch based on current repo owner
  ghwho             - Show current vs required account for this repo
  ghaccounts        - List accounts + owner mappings
  ghstatus          - Check authentication status

ORGANIZATION (Work):
  ghaudit           - Run organization audit script
  ghorg <name>      - Browse org repositories

REPOSITORIES:
  ghclone           - Clone repo (fzf picks from your repos)
  ghrepos           - Browse your repositories (fzf)
  ghrepo            - View current/specified repo
  ghopen            - Open repo in browser
  ghcreate          - Create new repository
  ghfork            - Fork repository
  ghinfo            - Show current repo info

PULL REQUESTS:
  ghprs             - Browse PRs (fzf with preview)
  ghpr              - Create PR from current branch
  ghprstatus        - Check PR status
  ghprco            - Checkout PR (fzf selection)
  ghreview          - Review PR

ISSUES:
  ghissues          - Browse issues (fzf with preview)
  ghissue           - Create new issue
  ghdev             - Create branch from issue

BRANCHES:
  ghbranch          - Switch branches (fzf fuzzy find)
  ghnewbranch       - Create new branch

WORKFLOWS:
  ghruns            - Browse workflow runs (fzf)
  ghwatch           - Watch current workflow run
  ghlogs            - View workflow logs

GISTS:
  ghgists           - Browse your gists (fzf)
  ghgist            - Create gist from file

ORGANIZATION:
  ghorg <name>      - Browse org repositories

RELEASES:
  ghreleases        - List releases
  ghrelease         - Create release
  ghdownload        - Download release assets

UTILITIES:
  ghapi <endpoint>  - Direct API access
  ghsearch <query>  - Search repositories
  ghnotify          - Check notifications
  ghpush <msg>      - Commit, push, and optionally create PR

EXTENSIONS:
  ghext             - Browse available extensions
  ghextlist         - List installed extensions
  ghextinstall      - Install extension

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

QUICK WORKFLOWS:

  Morning routine:
    ghprstatus        # Check your PRs
    ghissues          # Review issues
    ghnotify          # Check notifications

  Create feature:
    ghissue           # Create issue
    ghdev             # Create branch from issue
    # ... do work ...
    ghpush "feat: add feature"  # Commit, push, create PR

  Review PRs:
    ghprs             # Browse PRs
    # Select PR, then: [c]heckout, [v]iew, [d]iff

  Quick fixes:
    ghbranch          # Switch to branch
    # ... make changes ...
    ghpush "fix: bug"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDED EXTENSIONS:

  gh extension install dlvhdr/gh-dash
  gh extension install mislav/gh-branch
  gh extension install github/gh-copilot

Type 'ghext' to browse all available extensions!

EOF
}

# ====================================
# ALIASES
# ====================================

alias ghs='ghstatus'         # Quick status
alias ghc='ghclone'          # Quick clone
alias gho='ghopen'           # Quick open
alias ghp='ghpr'             # Quick PR
alias ghi='ghissue'          # Quick issue
alias ghb='ghbranch'         # Quick branch
alias ghr='ghrepo'           # Quick repo view
alias ghw='ghwatch'          # Quick watch
alias ghg='ghgists'          # Quick gists

# ====================================
# ENHANCED: TOKEN SUPPORT & GHE SETUP
# ====================================

# Interactive GitHub Enterprise setup
ghsetup() {
  echo "🔧 GitHub Configuration Setup"
  echo ""
  echo "Let's configure your GitHub settings!"
  echo ""
  
  # GitHub type
  echo "GitHub Type:"
  echo "  1. GitHub.com (with SSO) - Default"
  echo "  2. GitHub Enterprise Server (self-hosted)"
  echo ""
  read "gh_type?Choice (1-2) [1]: "
  gh_type=${gh_type:-1}
  
  if [[ "$gh_type" == "2" ]]; then
    read "gh_host?Enter your GHE hostname (e.g. github.company.com): "
    if [[ -z "$gh_host" ]]; then
      echo "❌ Hostname required for GHE"
      return 1
    fi
  else
    gh_host="github.com"
  fi
  
  # Organization
  read "gh_org?Organization name [your-org]: "
  gh_org=${gh_org:-your-org}
  
  # User email
  read "gh_email?Your GitHub email [you@company.com]: "
  gh_email=${gh_email:-you@company.com}
  
  # Token
  echo ""
  read "gh_token?Enter your GitHub token (ghp_...): "
  
  if [[ -z "$gh_token" ]]; then
    echo "❌ Token required"
    return 1
  fi
  
  # Test token
  echo ""
  echo "🧪 Testing configuration..."
  
  if [[ "$gh_host" != "github.com" ]]; then
    export GH_HOST="$gh_host"
    export GITHUB_HOST="$gh_host"
  fi
  export GITHUB_TOKEN="$gh_token"
  
  if gh api user &>/dev/null; then
    local username=$(gh api user --jq '.login')
    echo "✅ Configuration valid! Username: $username"
  else
    echo "❌ Configuration test failed"
    return 1
  fi
  
  # Save configuration
  echo ""
  echo "Where to save configuration?"
  echo "  1. Current session only (temporary)"
  echo "  2. Add to ~/.zshrc (persistent)"
  echo "  3. Save to ~/.github_config file (recommended)"
  echo ""
  read "save_choice?Choice (1-3) [3]: "
  save_choice=${save_choice:-3}
  
  case $save_choice in
    2)
      echo "" >> ~/.zshrc
      echo "# GitHub Configuration (added by ghsetup)" >> ~/.zshrc
      [[ "$gh_host" != "github.com" ]] && echo "export GH_HOST='$gh_host'" >> ~/.zshrc
      [[ "$gh_host" != "github.com" ]] && echo "export GITHUB_HOST='$gh_host'" >> ~/.zshrc
      echo "export GITHUB_TOKEN='$gh_token'" >> ~/.zshrc
      echo "export GITHUB_ORG='$gh_org'" >> ~/.zshrc
      [[ -n "$gh_email" ]] && echo "export GITHUB_USER='$gh_email'" >> ~/.zshrc
      echo "✅ Configuration added to ~/.zshrc"
      ;;
    3)
      cat > ~/.github_config << EOF
# GitHub Configuration
export GH_HOST='$gh_host'
export GITHUB_HOST='$gh_host'
export GITHUB_TOKEN='$gh_token'
export GITHUB_ORG='$gh_org'
export GITHUB_USER='$gh_email'
EOF
      chmod 600 ~/.github_config
      
      if ! grep -q "~/.github_config" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Load GitHub configuration" >> ~/.zshrc
        echo 'if [ -f ~/.github_config ]; then' >> ~/.zshrc
        echo '  source ~/.github_config' >> ~/.zshrc
        echo 'fi' >> ~/.zshrc
      fi
      echo "✅ Configuration saved to ~/.github_config"
      ;;
    *)
      echo "✅ Configuration set for current session"
      ;;
  esac
  
  echo ""
  echo "🎉 Setup complete!"
  echo ""
  echo "Available commands:"
  echo "  • ghconfig      - View current configuration"
  echo "  • ghaudit       - Run organization audit"
  echo "  • ghprs         - Browse pull requests"
  echo "  • ghissues      - Browse issues"
  echo "  • ghorg         - Browse organization repos"
  echo ""
}

# Show current GitHub configuration
ghconfig() {
  echo "🔍 GitHub Configuration"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  local gh_host="${GH_HOST:-${GITHUB_HOST:-github.com}}"
  echo "Host:         $gh_host"
  
  if [[ -n "$GITHUB_ORG" ]]; then
    echo "Organization: $GITHUB_ORG"
  else
    echo "Organization: (not set)"
  fi
  
  if [[ -n "$GITHUB_USER" ]]; then
    echo "User:         $GITHUB_USER"
  else
    echo "User:         (not set)"
  fi
  
  echo ""
  if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "Token:        ✅ Set"
    if gh api user &>/dev/null; then
      local username=$(gh api user --jq '.login')
      echo "Authenticated: ✅ Valid ($username)"
    else
      echo "Authenticated: ❌ Invalid"
    fi
  else
    echo "Token:        ❌ Not set"
  fi
  
  echo ""
  if command -v gh &>/dev/null; then
    echo "gh CLI:       ✅ Installed"
  else
    echo "gh CLI:       ❌ Not installed"
  fi
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Interactive token setup
ghtoken() {
  echo "🔐 GitHub Token Setup"
  echo ""
  echo "This is useful for:"
  echo "  • Work GitHub with Microsoft SSO"
  echo "  • GitHub Enterprise"
  echo "  • When gh auth login doesn't work"
  echo ""
  
  read "token?Enter your GitHub token (ghp_...): "
  
  if [[ -z "$token" ]]; then
    echo "❌ No token provided"
    return 1
  fi
  
  # Test the token
  echo ""
  echo "🧪 Testing token..."
  if GITHUB_TOKEN="$token" gh api user &>/dev/null; then
    local username=$(GITHUB_TOKEN="$token" gh api user --jq '.login')
    echo "✅ Token works! Username: $username"
    echo ""
    
    echo "Where to store the token?"
    echo "  1. Current session only (temporary)"
    echo "  2. Add to ~/.zshrc (persistent)"
    echo "  3. Save to ~/.github_token file (secure)"
    echo ""
    read "choice?Choice (1-3): "
    
    case $choice in
      2)
        echo "" >> ~/.zshrc
        echo "# GitHub Token (added by ghtoken)" >> ~/.zshrc
        echo "export GITHUB_TOKEN='$token'" >> ~/.zshrc
        export GITHUB_TOKEN="$token"
        echo "✅ Token added to ~/.zshrc"
        ;;
      3)
        echo "$token" > ~/.github_token
        chmod 600 ~/.github_token
        if ! grep -q "GITHUB_TOKEN.*github_token" ~/.zshrc; then
          echo "" >> ~/.zshrc
          echo "# GitHub Token (load from file)" >> ~/.zshrc
          echo 'if [ -f ~/.github_token ]; then' >> ~/.zshrc
          echo '  export GITHUB_TOKEN=$(cat ~/.github_token)' >> ~/.zshrc
          echo 'fi' >> ~/.zshrc
        fi
        export GITHUB_TOKEN="$token"
        echo "✅ Token saved to ~/.github_token"
        ;;
      *)
        export GITHUB_TOKEN="$token"
        echo "✅ Token set for current session"
        ;;
    esac
  else
    echo "❌ Token test failed"
    return 1
  fi
}

# Check if token is valid
ghtoken-check() {
  echo "🔍 GitHub Token Check"
  echo ""
  
  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "❌ GITHUB_TOKEN not set"
    echo ""
    echo "Set it with: ghtoken"
    return 1
  fi
  
  echo "✅ GITHUB_TOKEN is set"
  echo ""
  echo "Testing token..."
  
  if gh api user &>/dev/null; then
    local username=$(gh api user --jq '.login')
    local name=$(gh api user --jq '.name')
    echo "✅ Token is valid!"
    echo ""
    echo "Username: $username"
    echo "Name: $name"
    
    # Check rate limit
    local limit=$(gh api rate_limit --jq '.rate.limit')
    local remaining=$(gh api rate_limit --jq '.rate.remaining')
    echo ""
    echo "API Rate Limit: $remaining/$limit remaining"
  else
    echo "❌ Token is invalid or expired"
    echo ""
    echo "Create new token:"
    echo "  https://github.com/settings/tokens"
    echo ""
    echo "Then set it:"
    echo "  ghtoken"
    return 1
  fi
}

# Run GitHub organization audit script
ghaudit() {
  _gh_check || return 1
  
  # Look for audit script
  local script_locations=(
    "$HOME/scripts/scrm_github-org-audit.ps1"
    "$HOME/.github/scripts/scrm_github-org-audit.ps1"
    "./scrm_github-org-audit.ps1"
  )
  
  local script_path=""
  for location in "${script_locations[@]}"; do
    if [[ -f "$location" ]]; then
      script_path="$location"
      break
    fi
  done
  
  if [[ -z "$script_path" ]]; then
    echo "❌ Audit script not found"
    echo ""
    echo "Searched locations:"
    for location in "${script_locations[@]}"; do
      echo "  • $location"
    done
    echo ""
    echo "💡 Place scrm_github-org-audit.ps1 in one of these locations"
    return 1
  fi
  
  # Check if PowerShell is installed
  if ! command -v pwsh &>/dev/null; then
    echo "❌ PowerShell not installed"
    echo ""
    echo "Install: brew install powershell"
    return 1
  fi
  
  # Run the audit
  echo "🔍 Running GitHub Organization Audit"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Script:       $script_path"
  echo "Organization: ${GITHUB_ORG:-your-org}"
  echo "Token:        ${GITHUB_TOKEN:+✅ Set}"
  echo ""
  
  if [[ -n "$GITHUB_ORG" ]]; then
    pwsh "$script_path" -OrgName "$GITHUB_ORG" "$@"
  else
    pwsh "$script_path" "$@"
  fi
}

