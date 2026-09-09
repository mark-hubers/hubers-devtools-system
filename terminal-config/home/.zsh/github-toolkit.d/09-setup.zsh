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
      _gh_chmod_600 ~/.github_config
      
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
  echo "  • ghorgaudit    - Run organization audit (PowerShell script)"
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
        _gh_chmod_600 ~/.github_token
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

# Run GitHub organization audit script (PowerShell). Not the same as: ghaudit log (local action log in 03-profiles).
ghorgaudit() {
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

