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

# Develop (create branch) from issue (named ghissuedev — ghdev is profile de-escalate)
ghissuedev() {
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

PROFILES & ESCALATION:
  ghprofile help    - Profile guide (config file, ghadmin/ghdev, audit)
  ghprofile list    - Show all profiles
  ghprofile use <n> - Switch to a profile
  ghprofile show    - Show active profile details
  ghprofile create  - Interactive profile creation
  ghadmin           - Escalate to admin mode (session)
  ghadmin <cmd>     - One-shot admin command (like sudo)
  ghdev             - De-escalate to dev mode
  ghaudit log       - View local admin action log (~/.gh-toolkit-audit.log)

SETUP & CONFIGURATION (Work SSO Support!):
  ghsetup           - Interactive GitHub setup (for work SSO)
  ghconfig          - Show current GitHub configuration
  ghtoken           - Interactive token management
  ghtoken-check     - Verify token works
  ghdoctor          - Check dependencies + auth health
  ghd               - Alias for ghdoctor

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

IDENTITY ISOLATION (different login per session — no clobbering):
  ghid use <name>   - Bind THIS shell to an isolated gh identity
  ghid login <name> - Bind + browser-login a new identity
  ghid import <n> [a] - Seed identity from a global gh token (no browser)
  ghid show         - Show this shell's identity (default)
  ghid list         - List identities + their accounts
  ghid clear        - Unbind (back to global ~/.config/gh)
  ghid push on|off  - Route git push through the bound identity (this shell)
  ghid auto on|off  - Auto-bind from a .gh-id file on cd

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
  ghorgaudit        - Run org audit PowerShell script (if installed)
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
  ghissuedev        - Create branch from issue

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
    ghissuedev        # Create branch from issue
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
alias ghd='ghdoctor'         # Toolkit doctor

