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

# Quick GitHub auth with clipboard support
ghlogin() {
  echo "🔐 GitHub CLI Authentication"
  echo ""
  gh auth login --clipboard
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
  gh auth switch
}

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

AUTHENTICATION (Traditional):
  ghlogin           - Login to GitHub (with clipboard support)
  ghstatus          - Check authentication status
  ghswitch          - Switch GitHub accounts

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

