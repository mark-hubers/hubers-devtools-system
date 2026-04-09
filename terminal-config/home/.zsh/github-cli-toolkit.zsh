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
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local status_output=$(gh auth status 2>&1)

  if ! echo "$status_output" | grep -q "Logged in"; then
    echo "  No accounts configured yet."
    echo ""
    echo "  Run 'ghadd' to add your first account."
    return
  fi

  # Extract account info using awk for reliable parsing
  echo "$status_output" | awk '
    /Logged in to github.com account/ {
      if (account != "") {
        print account "|" active "|" scopes
      }
      account = $7
      gsub(/\(.*/, "", account)
      active = "false"
      scopes = ""
    }
    /Active account: true/ { active = "true" }
    /Token scopes:/ {
      scopes = $0
      gsub(/.*Token scopes: /, "", scopes)
      gsub(/'\''/, "", scopes)
    }
    END {
      if (account != "") {
        print account "|" active "|" scopes
      }
    }
  ' | while IFS='|' read -r account active scopes; do
    _ghlist_print_account "$account" "$active" "$scopes"
  done

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Commands: ghadd (add new) | ghswitch (change) | ghremove (delete)"
}

# Helper to print a single account with labels
_ghlist_print_account() {
  local account="$1" is_active="$2" scopes="$3"
  local type_label="" active_marker="" default_org="" account_label=""

  # Determine type label based on scopes
  if [[ "$scopes" == *"admin:org"* ]] || [[ "$scopes" == *"admin:enterprise"* ]]; then
    type_label="🔑 ADMIN"
  elif [[ "$scopes" == *"repo"* ]]; then
    type_label="👤 standard"
  else
    type_label="📖 read-only"
  fi

  # Active marker
  if [[ "$is_active" == "true" ]]; then
    active_marker="  ✅ ACTIVE"
  fi

  # Check for default org and account label
  default_org="${GH_ACCOUNT_DEFAULT_ORG[$account]}"
  account_label="${GH_ACCOUNT_LABEL[$account]}"

  echo "┌─────────────────────────────────────────────────────"
  echo "│ $account$active_marker"
  [[ -n "$account_label" ]] && echo "│ 📧 $account_label"
  echo "│ Type: $type_label"
  [[ -n "$default_org" ]] && echo "│ Default org: $default_org"
  echo "│ Scopes: ${scopes:0:60}$([ ${#scopes} -gt 60 ] && echo '...')"
  echo "└─────────────────────────────────────────────────────"
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
  echo "  2) Personal GitHub (github.com) - Paste token"
  echo "  3) Work - GitHub Enterprise Cloud (SSO/SAML) - browser login with company SSO"
  echo "  4) Work - GitHub Enterprise Server (self-hosted) - your-company.github.com"
  echo "  5) Work - Load token from 1Password (op:// reference)"
  echo "  6) Work - Paste existing token (admin token, PAT, etc.)"
  echo ""
  echo "💡 Option 3 = Browser SSO, Option 5/6 = Use existing admin token"
  echo ""

  read "choice?Select (1-6): "
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
    5)
      echo "🔐 Work - Load token from 1Password"
      echo ""
      # Check if op is available
      if ! command -v op &>/dev/null; then
        echo "❌ 1Password CLI (op) not found. Install it first."
        return 1
      fi
      # Check if signed in
      if ! op whoami &>/dev/null; then
        echo "⚠️  Not signed into 1Password. Run: eval \$(op signin)"
        return 1
      fi
      # Check for multiple accounts
      local op_accounts op_account_flag=""
      op_accounts=$(op account list --format json 2>/dev/null | jq -r '.[].url' 2>/dev/null)
      if [[ $(echo "$op_accounts" | wc -l) -gt 1 ]]; then
        echo "📋 Multiple 1Password accounts found:"
        op account list 2>/dev/null | tail -n +2
        echo ""
        read "opacct?Enter account URL (e.g., my.1password.com): "
        if [[ -n "$opacct" ]]; then
          op_account_flag="--account $opacct"
        fi
        echo ""
      fi
      echo "Enter the 1Password reference for your token."
      echo "Format: op://Vault/Item/Field"
      echo ""
      echo "Example: op://Private/github-work/admin-token"
      echo ""
      read "opref?1Password reference: "
      if [[ -n "$opref" ]]; then
        echo ""
        echo "Fetching token from 1Password..."
        local token
        token=$(op read "$opref" $op_account_flag 2>&1)
        if [[ $? -ne 0 ]] || [[ "$token" == *"[ERROR]"* ]]; then
          echo "⚠️  Failed to read token. Error:"
          echo "$token"
          return 1
        fi
        echo "$token" | gh auth login --hostname github.com --git-protocol https --with-token
        if [[ $? -eq 0 ]]; then
          echo "✅ Token loaded from 1Password!"
        fi
      fi
      ;;
    6)
      echo "🔑 Work - Paste existing token"
      echo ""
      echo "This is for admin tokens, PATs, or any existing token."
      echo ""
      echo "Paste your token and press Enter:"
      echo "(Token will be hidden)"
      echo ""
      read -s "token?Token: "
      echo ""
      if [[ -n "$token" ]]; then
        echo "$token" | gh auth login --hostname github.com --git-protocol https --with-token
        if [[ $? -eq 0 ]]; then
          echo "✅ Token added!"
        fi
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

# Default org per account (for work/enterprise accounts)
# When using ghrepos, ghclone, etc., use this org by default
# Add your mappings in ~/.zshrc_local (private)
typeset -gA GH_ACCOUNT_DEFAULT_ORG
GH_ACCOUNT_DEFAULT_ORG=(
  # "work-account"  "default-org"   # Example: work account defaults to this org
)

# Account descriptions (email, label, etc. for display)
# Makes ghlist output clearer - add in ~/.zshrc_local (private)
typeset -gA GH_ACCOUNT_LABEL
GH_ACCOUNT_LABEL=(
  # "account-name"  "email@example.com (personal)"
  # "work-account"  "work@company.com (work admin)"
)

# Shorthand aliases for accounts (for gh-as command)
# Add in ~/.zshrc_local: GH_ACCOUNT_ALIAS+=("work" "My-Work-Account")
typeset -gA GH_ACCOUNT_ALIAS
# Only set defaults if not already defined (preserves ~/.zshrc_local values)
(( ${#GH_ACCOUNT_ALIAS} == 0 )) && GH_ACCOUNT_ALIAS=(
  # "work"      "Work-Account-Name"
  # "personal"  "Personal-Account-Name"
)

# ====================================
# SCRIPT HELPERS
# ====================================

# Run gh command as a specific account (for scripts/automation)
# Usage: gh-as work gh repo list org-name
#        gh-as personal gh api user
#        gh-as your-work-account gh repo create ...
gh-as() {
  local account_ref="$1"
  shift

  if [[ -z "$account_ref" ]] || [[ $# -eq 0 ]]; then
    echo "Usage: gh-as <account|alias> <gh command...>"
    echo ""
    echo "Examples:"
    echo "  gh-as work gh repo list your-org"
    echo "  gh-as personal gh api user"
    echo ""
    echo "Aliases (set in ~/.zshrc_local):"
    for alias acct in ${(kv)GH_ACCOUNT_ALIAS}; do
      echo "  $alias -> $acct"
    done
    return 1
  fi

  # Resolve alias to account name
  local account="${GH_ACCOUNT_ALIAS[$account_ref]:-$account_ref}"

  # Get current account to restore later
  local original_account=$(_gh_current_account)

  # Switch, run command, switch back
  gh auth switch --user "$account" &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "Error: Could not switch to account '$account'"
    return 1
  fi

  # Run the command
  "$@"
  local exit_code=$?

  # Switch back to original
  if [[ -n "$original_account" && "$original_account" != "$account" ]]; then
    gh auth switch --user "$original_account" &>/dev/null
  fi

  return $exit_code
}

# Get the default org for an account
_gh_default_org() {
  local account="${1:-$(_gh_current_account)}"
  echo "${GH_ACCOUNT_DEFAULT_ORG[$account]}"
}

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
  local current_account required_account owner default_org

  current_account=$(_gh_current_account)
  required_account=$(_gh_required_account)
  owner=$(_gh_repo_owner)
  default_org=$(_gh_default_org "$current_account")

  echo "📍 GitHub Account Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Current account:  $current_account"
  [[ -n "$default_org" ]] && echo "Default org:      $default_org"
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

VARIABLES (Org/Repo):
  ghvar list [target]               - List variables
  ghvar get <name> [target]         - Show variable details
  ghvar set <name> <val> [target]   - Create or update variable
  ghvar delete <name> [target]      - Delete variable

SECRETS (Org/Repo):
  ghsecret list [target]            - List secrets (names only)
  ghsecret set <name> [target]      - Create or update secret (prompts for value)
  ghsecret delete <name> [target]   - Delete secret (with confirmation)

TEAMS:
  ghteam list <org>                 - List teams with member/repo counts
  ghteam show <org> <team>          - Team details + members + repos
  ghteam add-member <org> <t> <u>   - Add user to team
  ghteam remove-member <org> <t> <u>- Remove user from team
  ghteam set-repo <org> <t> <r> <p> - Set team repo permission
  ghteam fix <org> <t> [--parent..] - Fix team parent/description

  (target: org-name = org scope, owner/repo = repo, omit = current repo)

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
alias ghv='ghvar'            # Quick variables

# ====================================
# ORG/REPO VARIABLE MANAGEMENT
# ====================================
# Wraps GitHub Actions Variables API for org and repo scope.
# Org operations use admin token from ~/.gh-admin-token.

# Run gh with admin token (for org-level operations)
_gh_admin() {
   local token_file="$HOME/.gh-admin-token"
   if [[ ! -f "$token_file" ]]; then
      echo "✗ Admin token not found: $token_file"
      echo ""
      echo "Create it:"
      echo "  1. Generate a classic PAT with admin:org scope"
      echo "  2. echo 'ghp_YourTokenHere' > ~/.gh-admin-token"
      echo "  3. chmod 600 ~/.gh-admin-token"
      return 1
   fi
   local perms
   perms=$(stat -f '%Lp' "$token_file" 2>/dev/null)
   if [[ "$perms" != "600" ]]; then
      echo "⚠ Fixing permissions on $token_file ($perms → 600)"
      chmod 600 "$token_file"
   fi
   GH_TOKEN=$(<"$token_file") gh "$@"
}

# Parse target into scope + API path
# Sets: _GH_SCOPE (org|repo), _GH_API_PATH, _GH_TARGET_LABEL
_gh_parse_target() {
   local target="$1"

   ## Strip whitespace
   target="${target## }"
   target="${target%% }"

   if [[ -z "$target" ]]; then
      ## Auto-detect from git remote
      local remote_url
      remote_url=$(git remote get-url origin 2>/dev/null)
      if [[ -z "$remote_url" ]]; then
         echo "✗ No target specified and not in a git repo with a remote"
         echo "Usage: ghvar <cmd> [name] [value] [org | owner/repo]"
         return 1
      fi
      local owner_repo
      owner_repo=$(echo "$remote_url" | sed -E 's#^(git@[^:]+:|https://[^/]+/)##; s/\.git$//')
      if [[ -z "$owner_repo" || "$owner_repo" != */* ]]; then
         echo "✗ Could not parse owner/repo from remote: $remote_url"
         return 1
      fi
      _GH_SCOPE="repo"
      _GH_API_PATH="/repos/$owner_repo/actions/variables"
      _GH_TARGET_LABEL="$owner_repo"
      return 0
   fi

   ## Validate: reject too many slashes
   local slash_count="${target//[^\/]/}"
   if [[ ${#slash_count} -gt 1 ]]; then
      echo "✗ Invalid target: '$target' (expected 'org' or 'owner/repo')"
      return 1
   fi

   if [[ "$target" == */* ]]; then
      ## Repo scope
      _GH_SCOPE="repo"
      _GH_API_PATH="/repos/$target/actions/variables"
      _GH_TARGET_LABEL="$target"
   else
      ## Org scope
      _GH_SCOPE="org"
      _GH_API_PATH="/orgs/$target/actions/variables"
      _GH_TARGET_LABEL="$target"
   fi
   return 0
}

# Run gh or _gh_admin based on current scope
_gh_scoped() {
   if [[ "$_GH_SCOPE" == "org" ]]; then
      _gh_admin "$@"
   else
      gh "$@"
   fi
}

# Main ghvar command
ghvar() {
   _gh_check || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)
         _ghvar_list "$@"
         ;;
      get)
         _ghvar_get "$@"
         ;;
      set)
         _ghvar_set "$@"
         ;;
      delete)
         _ghvar_delete "$@"
         ;;
      *)
         echo "📋 ghvar — GitHub Actions Variable Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghvar <command> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list   [target]                          List variables"
         echo "  get    <name> [target]                   Show variable details"
         echo "  set    <name> <value> [target] [flags]   Create or update variable"
         echo "  delete <name> [target]                   Delete variable"
         echo ""
         echo "Target (positional — auto-detected if omitted):"
         echo "  alvaria-bu          Org scope (uses admin token)"
         echo "  alvaria-bu/my-repo  Repo scope"
         echo "  (omitted)           Current repo from git remote"
         echo ""
         echo "Flags (set only):"
         echo "  --visibility all|private|selected   Org variable visibility"
         echo "  --repos repo1,repo2                 Repos for selected visibility"
         echo ""
         echo "Options:"
         echo "  --json              Machine-readable output"
         echo ""
         echo "Examples:"
         echo "  ghvar list alvaria-bu"
         echo "  ghvar get AWS_REGION alvaria-bu"
         echo "  ghvar set DEPLOY_ENV staging alvaria-bu --visibility all"
         echo "  ghvar set MY_VAR value123"
         echo "  ghvar delete OLD_VAR alvaria-bu"
         echo "  ghvar list --json | jq '.[] | .name'"
         return 1
         ;;
   esac
}

# --- ghvar list ---
_ghvar_list() {
   local target="" json_mode=0
   ## Parse args
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      target="$arg" ;;
      esac
   done

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list variables for $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result" | jq '.variables // []'
      return 0
   fi

   local scope_label
   [[ "$_GH_SCOPE" == "org" ]] && scope_label="Org" || scope_label="Repo"

   echo "📋 $scope_label Variables: $_GH_TARGET_LABEL"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

   local count
   count=$(echo "$result" | jq '.variables | length')

   if [[ "$count" == "0" ]]; then
      echo "  (none)"
   elif [[ "$_GH_SCOPE" == "org" ]]; then
      printf "  %-28s %-30s %s\n" "NAME" "VALUE" "VISIBILITY"
      echo "  ─────────────────────────── ────────────────────────────── ──────────"
      echo "$result" | jq -r '.variables[] | "  \(.name)\t\(.value)\t\(.visibility)"' | \
         while IFS=$'\t' read -r name val vis; do
            printf "  %-28s %-30s %s\n" "$name" "$val" "$vis"
         done
   else
      printf "  %-28s %s\n" "NAME" "VALUE"
      echo "  ─────────────────────────── ──────────────────────────────"
      echo "$result" | jq -r '.variables[] | "  \(.name)\t\(.value)"' | \
         while IFS=$'\t' read -r name val; do
            printf "  %-28s %s\n" "$name" "$val"
         done
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count variable(s)"
}

# --- ghvar get ---
_ghvar_get() {
   local name="" target="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$arg"
            else
               target="$arg"
            fi
            ;;
      esac
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghvar get <name> [target] [--json]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "get variable '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result"
      return 0
   fi

   echo "📋 Variable: $name"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  Name:       $(echo "$result" | jq -r '.name')"
   echo "  Value:      $(echo "$result" | jq -r '.value')"
   if [[ "$_GH_SCOPE" == "org" ]]; then
      echo "  Visibility: $(echo "$result" | jq -r '.visibility')"
   fi
   echo "  Created:    $(echo "$result" | jq -r '.created_at')"
   echo "  Updated:    $(echo "$result" | jq -r '.updated_at')"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# --- ghvar set ---
_ghvar_set() {
   local name="" value="" target="" visibility="" repos="" json_mode=0
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --json) json_mode=1; shift ;;
         --visibility) visibility="$2"; shift 2 ;;
         --repos) repos="$2"; shift 2 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$1"
            elif [[ -z "$value" ]]; then
               value="$1"
            else
               target="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$name" || -z "$value" ]]; then
      echo "Usage: ghvar set <name> <value> [target] [--visibility all|private|selected] [--repos r1,r2]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   ## Build JSON body
   local body="{\"name\":\"$name\",\"value\":\"$value\"}"

   if [[ "$_GH_SCOPE" == "org" ]]; then
      if [[ -n "$visibility" ]]; then
         body="{\"name\":\"$name\",\"value\":\"$value\",\"visibility\":\"$visibility\"}"
         if [[ "$visibility" == "selected" && -n "$repos" ]]; then
            ## Resolve repo names to IDs
            local repo_ids="[]"
            local org="$_GH_TARGET_LABEL"
            local ids=()
            for repo_name in ${(s:,:)repos}; do
               local rid
               rid=$(_gh_admin api "/repos/$org/$repo_name" --jq '.id' 2>/dev/null)
               if [[ -n "$rid" ]]; then
                  ids+=("$rid")
               else
                  echo "⚠ Could not resolve repo: $org/$repo_name"
               fi
            done
            if [[ ${#ids[@]} -gt 0 ]]; then
               repo_ids="[$(IFS=,; echo "${ids[*]}")]"
            fi
            body="{\"name\":\"$name\",\"value\":\"$value\",\"visibility\":\"$visibility\",\"selected_repository_ids\":$repo_ids}"
         fi
      fi
   fi

   ## Try update (PATCH) first
   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" --method PATCH --input - <<< "$body" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      ## Check if 404 (variable doesn't exist yet)
      if echo "$result" | grep -qi '404\|not found'; then
         ## Create (POST) — need visibility for org scope
         if [[ "$_GH_SCOPE" == "org" && -z "$visibility" ]]; then
            echo "✗ Org variable requires --visibility (all, private, or selected)"
            return 1
         fi
         result=$(_gh_scoped api "$_GH_API_PATH" --method POST --input - <<< "$body" 2>&1)
         rc=$?
         if [[ $rc -ne 0 ]]; then
            _gh_handle_error "$result" "create variable '$name' on $_GH_TARGET_LABEL"
            return 1
         fi
         if [[ $json_mode -eq 1 ]]; then
            echo '{"action":"created","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
         else
            echo "✓ Created $name on $_GH_TARGET_LABEL"
         fi
      else
         _gh_handle_error "$result" "update variable '$name' on $_GH_TARGET_LABEL"
         return 1
      fi
   else
      if [[ $json_mode -eq 1 ]]; then
         echo '{"action":"updated","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
      else
         echo "✓ Updated $name on $_GH_TARGET_LABEL"
      fi
   fi
}

# --- ghvar delete ---
_ghvar_delete() {
   local name="" target="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$arg"
            else
               target="$arg"
            fi
            ;;
      esac
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghvar delete <name> [target] [--json]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "$_GH_API_PATH/$name" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "delete variable '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo '{"action":"deleted","name":"'"$name"'","target":"'"$_GH_TARGET_LABEL"'"}'
   else
      echo "✓ Deleted $name from $_GH_TARGET_LABEL"
   fi
}

# --- Shared error handler (used by ghvar, ghsecret, ghteam) ---
_gh_handle_error() {
   local result="$1" context="$2"
   if echo "$result" | grep -qi '401\|bad credentials'; then
      echo "✗ Authentication failed — token expired or invalid"
   elif echo "$result" | grep -qi 'rate limit'; then
      echo "✗ Rate limited — wait a few minutes and retry"
   elif echo "$result" | grep -qi '403\|forbidden'; then
      echo "✗ Permission denied — admin token may lack required scope"
      echo "  Needed: classic PAT with admin:org"
   elif echo "$result" | grep -qi '404\|not found'; then
      echo "✗ Not found — check target name and your access"
   elif echo "$result" | grep -qi '422\|validation failed'; then
      echo "✗ Validation error"
      local msg
      msg=$(echo "$result" | jq -r '.message // empty' 2>/dev/null)
      [[ -n "$msg" ]] && echo "  API: $msg"
      local errors
      errors=$(echo "$result" | jq -r '.errors[]?.message // empty' 2>/dev/null)
      [[ -n "$errors" ]] && echo "  Detail: $errors"
   else
      echo "✗ Failed to $context"
      local msg
      msg=$(echo "$result" | jq -r '.message // empty' 2>/dev/null)
      [[ -n "$msg" ]] && echo "  API: $msg"
   fi
}

# ====================================
# ORG/REPO SECRET MANAGEMENT
# ====================================
# Wraps GitHub Actions Secrets API. Values are NEVER returned by the API.
# Uses `gh secret set` for creates (handles libsodium encryption).

ghsecret() {
   _gh_check || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)   _ghsecret_list "$@" ;;
      set)    _ghsecret_set "$@" ;;
      delete) _ghsecret_delete "$@" ;;
      *)
         echo "🔒 ghsecret — GitHub Actions Secret Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghsecret <command> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list   [target]                          List secrets (names only)"
         echo "  set    <name> [target] [--visibility ..]  Create or update secret"
         echo "  delete <name> [target]                   Delete secret"
         echo ""
         echo "Target: org-name = org scope, owner/repo = repo, omit = current repo"
         echo ""
         echo "Examples:"
         echo "  ghsecret list alvaria-bu"
         echo "  ghsecret set DEPLOY_KEY alvaria-bu --visibility all"
         echo "  ghsecret delete OLD_SECRET alvaria-bu"
         echo ""
         echo "Note: GitHub never returns secret values — only names are visible."
         return 1
         ;;
   esac
}

# --- ghsecret list ---
_ghsecret_list() {
   local target="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      target="$arg" ;;
      esac
   done

   _gh_parse_target "$target" || return 1

   local result
   result=$(_gh_scoped api "${_GH_API_PATH%/variables}/secrets" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list secrets for $_GH_TARGET_LABEL"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result" | jq '.secrets // []'
      return 0
   fi

   local scope_label
   [[ "$_GH_SCOPE" == "org" ]] && scope_label="Org" || scope_label="Repo"

   echo "🔒 $scope_label Secrets: $_GH_TARGET_LABEL"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

   local count
   count=$(echo "$result" | jq '.secrets | length')

   if [[ "$count" == "0" ]]; then
      echo "  (none)"
   elif [[ "$_GH_SCOPE" == "org" ]]; then
      printf "  %-28s %-14s %s\n" "NAME" "VISIBILITY" "UPDATED"
      echo "  ─────────────────────────── ────────────── ────────────────────"
      echo "$result" | jq -r '.secrets[] | "\(.name)\t\(.visibility)\t\(.updated_at)"' | \
         while IFS=$'\t' read -r name vis updated; do
            printf "  %-28s %-14s %s\n" "$name" "$vis" "${updated%T*}"
         done
   else
      printf "  %-28s %s\n" "NAME" "UPDATED"
      echo "  ─────────────────────────── ────────────────────"
      echo "$result" | jq -r '.secrets[] | "\(.name)\t\(.updated_at)"' | \
         while IFS=$'\t' read -r name updated; do
            printf "  %-28s %s\n" "$name" "${updated%T*}"
         done
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count secret(s)  (values never shown)"
}

# --- ghsecret set ---
_ghsecret_set() {
   local name="" target="" visibility="" repos=""
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --visibility) visibility="$2"; shift 2 ;;
         --repos) repos="$2"; shift 2 ;;
         *)
            if [[ -z "$name" ]]; then
               name="$1"
            else
               target="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghsecret set <name> [target] [--visibility all|private|selected]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   ## Read secret value silently
   local secret_value
   echo -n "Enter value for secret '$name': "
   read -s secret_value
   echo ""

   if [[ -z "$secret_value" ]]; then
      echo "✗ Empty value — aborting"
      return 1
   fi

   ## Build gh secret set command args
   local -a cmd_args=("secret" "set" "$name")
   if [[ "$_GH_SCOPE" == "org" ]]; then
      cmd_args+=("--org" "$_GH_TARGET_LABEL")
      if [[ -n "$visibility" ]]; then
         cmd_args+=("--visibility" "$visibility")
      else
         echo "✗ Org secret requires --visibility (all, private, or selected)"
         return 1
      fi
   elif [[ "$_GH_SCOPE" == "repo" ]]; then
      cmd_args+=("--repo" "$_GH_TARGET_LABEL")
   fi

   ## Pipe value to gh secret set (handles encryption)
   local result
   result=$(echo "$secret_value" | _gh_scoped "${cmd_args[@]}" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "set secret '$name' on $_GH_TARGET_LABEL"
      return 1
   fi

   echo "✓ Set secret $name on $_GH_TARGET_LABEL"
}

# --- ghsecret delete ---
_ghsecret_delete() {
   local name="" target=""
   for arg in "$@"; do
      if [[ -z "$name" ]]; then
         name="$arg"
      else
         target="$arg"
      fi
   done

   if [[ -z "$name" ]]; then
      echo "Usage: ghsecret delete <name> [target]"
      return 1
   fi

   _gh_parse_target "$target" || return 1

   ## Confirm
   echo -n "Delete secret '$name' from $_GH_TARGET_LABEL? (y/n): "
   read -k 1 confirm
   echo ""
   if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "  Cancelled"
      return 0
   fi

   local result
   result=$(_gh_scoped api "${_GH_API_PATH%/variables}/secrets/$name" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "delete secret '$name' from $_GH_TARGET_LABEL"
      return 1
   fi

   echo "✓ Deleted secret $name from $_GH_TARGET_LABEL"
}

# ====================================
# TEAM MANAGEMENT
# ====================================
# Wraps GitHub Teams API for org-level team operations.

ghteam() {
   _gh_check || return 1

   local subcmd="$1"
   shift 2>/dev/null

   case "$subcmd" in
      list)          _ghteam_list "$@" ;;
      show)          _ghteam_show "$@" ;;
      add-member)    _ghteam_add_member "$@" ;;
      remove-member) _ghteam_remove_member "$@" ;;
      set-repo)      _ghteam_set_repo "$@" ;;
      fix)           _ghteam_fix "$@" ;;
      *)
         echo "👥 ghteam — GitHub Team Management"
         echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
         echo ""
         echo "Usage: ghteam <command> <org> [arguments]"
         echo ""
         echo "Commands:"
         echo "  list          <org>                            List teams"
         echo "  show          <org> <team>                     Team details + members + repos"
         echo "  add-member    <org> <team> <user> [--role ..]  Add/update member"
         echo "  remove-member <org> <team> <user>              Remove member"
         echo "  set-repo      <org> <team> <repo> <permission> Set repo access"
         echo "  fix           <org> <team> [--parent ..] [--description ..]"
         echo ""
         echo "Permissions: pull, triage, push, maintain, admin"
         echo ""
         echo "Examples:"
         echo "  ghteam list alvaria-bu"
         echo "  ghteam show alvaria-bu platform"
         echo "  ghteam add-member alvaria-bu scrm mark-hubers"
         echo "  ghteam set-repo alvaria-bu platform my-repo push"
         echo "  ghteam fix alvaria-bu scrm --parent users --description 'SCRM team'"
         return 1
         ;;
   esac
}

# --- ghteam list ---
_ghteam_list() {
   local org="" json_mode=0
   for arg in "$@"; do
      case "$arg" in
         --json) json_mode=1 ;;
         *)      org="$arg" ;;
      esac
   done

   if [[ -z "$org" ]]; then
      echo "Usage: ghteam list <org> [--json]"
      return 1
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams" --paginate 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "list teams for $org"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      echo "$result"
      return 0
   fi

   echo "👥 Teams: $org"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   printf "  %-20s %-10s %-16s %-6s %-6s %s\n" "SLUG" "PRIVACY" "PARENT" "MEMB" "REPOS" "DESCRIPTION"
   echo "  ──────────────────── ────────── ──────────────── ────── ────── ─────────────────────"

   echo "$result" | jq -r '.[] | "\(.slug)\t\(.privacy)\t\(.parent.slug // "-")\t\(.members_count // "-")\t\(.repos_count // "-")\t\(.description // "")"' | \
      while IFS=$'\t' read -r slug privacy parent memb repos desc; do
         printf "  %-20s %-10s %-16s %-6s %-6s %s\n" "$slug" "$privacy" "$parent" "$memb" "$repos" "${desc:0:30}"
      done

   local count
   count=$(echo "$result" | jq 'length')
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  $count team(s)"
}

# --- ghteam show ---
_ghteam_show() {
   local org="" team="" json_mode=0 show_members=1 show_repos=1
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --json)       json_mode=1; shift ;;
         --no-members) show_members=0; shift ;;
         --no-repos)   show_repos=0; shift ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            else
               team="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" ]]; then
      echo "Usage: ghteam show <org> <team> [--json] [--no-members] [--no-repos]"
      return 1
   fi

   ## Team details
   local team_result
   team_result=$(_gh_admin api "/orgs/$org/teams/$team" 2>&1)
   if [[ $? -ne 0 ]]; then
      _gh_handle_error "$team_result" "get team '$team' from $org"
      return 1
   fi

   if [[ $json_mode -eq 1 ]]; then
      local output="$team_result"
      if [[ $show_members -eq 1 ]]; then
         local members
         members=$(_gh_admin api "/orgs/$org/teams/$team/members" --paginate 2>&1)
         output=$(echo "$output" | jq --argjson m "$(echo "$members" | jq '[.[] | {login, role: "member"}]')" '. + {members: $m}')
      fi
      if [[ $show_repos -eq 1 ]]; then
         local repos
         repos=$(_gh_admin api "/orgs/$org/teams/$team/repos" --paginate 2>&1)
         output=$(echo "$output" | jq --argjson r "$(echo "$repos" | jq '[.[] | {name, permission: .role_name}]')" '. + {repos: $r}')
      fi
      echo "$output"
      return 0
   fi

   echo "👥 Team: $(echo "$team_result" | jq -r '.name') ($org/$team)"
   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
   echo "  Privacy:     $(echo "$team_result" | jq -r '.privacy')"
   echo "  Parent:      $(echo "$team_result" | jq -r '.parent.slug // "(none)"')"
   echo "  Description: $(echo "$team_result" | jq -r '.description // "(none)"')"
   echo "  Members:     $(echo "$team_result" | jq -r '.members_count // "?"')"
   echo "  Repos:       $(echo "$team_result" | jq -r '.repos_count // "?"')"

   if [[ $show_members -eq 1 ]]; then
      echo ""
      echo "  MEMBERS:"
      local members
      members=$(_gh_admin api "/orgs/$org/teams/$team/members" --paginate 2>&1)
      if [[ $? -eq 0 ]]; then
         local mem_count
         mem_count=$(echo "$members" | jq 'length')
         if [[ "$mem_count" == "0" ]]; then
            echo "    (none)"
         else
            echo "$members" | jq -r '.[] | "    \(.login)"'
         fi
      fi
   fi

   if [[ $show_repos -eq 1 ]]; then
      echo ""
      echo "  REPOS:"
      local repos
      repos=$(_gh_admin api "/orgs/$org/teams/$team/repos" --paginate 2>&1)
      if [[ $? -eq 0 ]]; then
         local repo_count
         repo_count=$(echo "$repos" | jq 'length')
         if [[ "$repo_count" == "0" ]]; then
            echo "    (none)"
         else
            printf "    %-35s %s\n" "REPO" "PERMISSION"
            echo "    ─────────────────────────────────── ──────────"
            echo "$repos" | jq -r '.[] | "    \(.name)\t\(.role_name // "read")"' | \
               while IFS=$'\t' read -r rname rperm; do
                  printf "    %-35s %s\n" "$rname" "$rperm"
               done
         fi
      fi
   fi

   echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# --- ghteam add-member ---
_ghteam_add_member() {
   local org="" team="" user="" role="member"
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --role) role="$2"; shift 2 ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            elif [[ -z "$team" ]]; then
               team="$1"
            else
               user="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" || -z "$user" ]]; then
      echo "Usage: ghteam add-member <org> <team> <user> [--role member|maintainer]"
      return 1
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/memberships/$user" \
      --method PUT --field "role=$role" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "add '$user' to $org/$team"
      return 1
   fi

   local state
   state=$(echo "$result" | jq -r '.state // "unknown"')
   echo "✓ $user → $org/$team (role=$role, state=$state)"
}

# --- ghteam remove-member ---
_ghteam_remove_member() {
   local org="$1" team="$2" user="$3"

   if [[ -z "$org" || -z "$team" || -z "$user" ]]; then
      echo "Usage: ghteam remove-member <org> <team> <user>"
      return 1
   fi

   echo -n "Remove '$user' from $org/$team? (y/n): "
   read -k 1 confirm
   echo ""
   if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "  Cancelled"
      return 0
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/memberships/$user" --method DELETE 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "remove '$user' from $org/$team"
      return 1
   fi

   echo "✓ Removed $user from $org/$team"
}

# --- ghteam set-repo ---
_ghteam_set_repo() {
   local org="$1" team="$2" repo="$3" permission="$4"

   if [[ -z "$org" || -z "$team" || -z "$repo" || -z "$permission" ]]; then
      echo "Usage: ghteam set-repo <org> <team> <repo> <permission>"
      echo "  Permissions: pull, triage, push, maintain, admin"
      return 1
   fi

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team/repos/$org/$repo" \
      --method PUT --field "permission=$permission" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "set $permission on $org/$repo for $org/$team"
      return 1
   fi

   echo "✓ $org/$team → $repo ($permission)"
}

# --- ghteam fix ---
_ghteam_fix() {
   local org="" team="" parent="" description=""
   while [[ $# -gt 0 ]]; do
      case "$1" in
         --parent)      parent="$2"; shift 2 ;;
         --description) description="$2"; shift 2 ;;
         *)
            if [[ -z "$org" ]]; then
               org="$1"
            else
               team="$1"
            fi
            shift
            ;;
      esac
   done

   if [[ -z "$org" || -z "$team" ]]; then
      echo "Usage: ghteam fix <org> <team> [--parent <parent-slug>] [--description \"text\"]"
      return 1
   fi

   if [[ -z "$parent" && -z "$description" ]]; then
      echo "✗ Specify at least --parent or --description"
      return 1
   fi

   ## Build JSON body
   local body="{"
   local need_comma=0
   if [[ -n "$description" ]]; then
      body+="\"description\":\"$description\""
      need_comma=1
   fi
   if [[ -n "$parent" ]]; then
      ## Resolve parent team slug to ID
      local parent_id
      parent_id=$(_gh_admin api "/orgs/$org/teams/$parent" --jq '.id' 2>/dev/null)
      if [[ -z "$parent_id" ]]; then
         echo "✗ Could not find parent team: $parent"
         return 1
      fi
      [[ $need_comma -eq 1 ]] && body+=","
      body+="\"parent_team_id\":$parent_id"
   fi
   body+="}"

   local result
   result=$(_gh_admin api "/orgs/$org/teams/$team" --method PATCH --input - <<< "$body" 2>&1)
   local rc=$?

   if [[ $rc -ne 0 ]]; then
      _gh_handle_error "$result" "update team $org/$team"
      return 1
   fi

   echo "✓ Updated $org/$team"
   [[ -n "$parent" ]] && echo "  Parent: $parent"
   [[ -n "$description" ]] && echo "  Description: $description"
}

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

