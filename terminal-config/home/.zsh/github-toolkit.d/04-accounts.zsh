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
  emulate -L zsh
  setopt localtraps

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
  local switched=0
  local exit_code=0

  _ghas_restore_account() {
    if [[ $switched -eq 1 && -n "$original_account" && "$original_account" != "$account" ]]; then
      gh auth switch --user "$original_account" &>/dev/null
    fi
  }
  trap '_ghas_restore_account' EXIT INT TERM HUP

  # Switch, run command, switch back
  gh auth switch --user "$account" &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "Error: Could not switch to account '$account'"
    trap - EXIT INT TERM HUP
    return 1
  fi
  switched=1

  # Run the command
  "$@"
  exit_code=$?

  _ghas_restore_account
  trap - EXIT INT TERM HUP

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

