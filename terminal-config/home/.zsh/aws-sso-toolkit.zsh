# ============================================================================
# AWS SSO TOOLKIT - Enhanced with fzf
# Makes AWS SSO login easy - no more forgetting commands or profile names!
# ============================================================================

# List all AWS SSO profiles from ~/.aws/config
_aws_sso_profiles() {
  if [[ ! -f ~/.aws/config ]]; then
    echo ""
    return
  fi
  
  # Extract profile names that have sso_start_url (these are SSO profiles)
  awk '/\[profile / {profile=$2; gsub(/\]/, "", profile)} 
       /sso_start_url/ && profile {print profile; profile=""}' ~/.aws/config
}

# Interactive AWS SSO login with fzf profile selection
awslogin() {
  echo "🔐 AWS SSO Login Helper"
  echo ""
  
  # Get list of SSO profiles
  local profiles=($(_aws_sso_profiles))
  
  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "❌ No AWS SSO profiles found in ~/.aws/config"
    echo ""
    echo "💡 To set up SSO, run:"
    echo "   aws configure sso"
    echo ""
    echo "📚 Or type 'awshelp' for full documentation"
    return 1
  fi
  
  echo "Select AWS SSO profile:"
  echo ""
  
  # Use fzf to select profile
  local selected_profile=$(printf '%s\n' "${profiles[@]}" | fzf --height=40% --prompt="AWS Profile> " --preview="aws configure list --profile {}")
  
  if [[ -z "$selected_profile" ]]; then
    echo "❌ No profile selected"
    return 1
  fi
  
  echo ""
  echo "🔑 Logging in to AWS SSO with profile: $selected_profile"
  echo ""
  
  # Perform SSO login
  aws sso login --profile "$selected_profile"
  
  if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Successfully logged in!"
    echo ""
    echo "💡 To use this profile:"
    echo "   export AWS_PROFILE=$selected_profile"
    echo "   aws sts get-caller-identity"
    echo ""
    echo "🎯 Or use 'awsuse $selected_profile' to set it now"
  else
    echo ""
    echo "❌ Login failed"
  fi
}

# Login to ALL SSO profiles at once
awsloginall() {
  echo "🔐 AWS SSO - Login to ALL profiles"
  echo ""
  
  local profiles=($(_aws_sso_profiles))
  
  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "❌ No AWS SSO profiles found"
    return 1
  fi
  
  echo "Found ${#profiles[@]} SSO profile(s):"
  printf '  • %s\n' "${profiles[@]}"
  echo ""
  
  read "confirm?Login to all profiles? (y/n): "
  
  if [[ $confirm != "y" ]]; then
    echo "❌ Cancelled"
    return 0
  fi
  
  echo ""
  
  local success=0
  local failed=0
  
  for profile in "${profiles[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔑 Logging in to: $profile"
    echo ""
    
    aws sso login --profile "$profile"
    
    if [[ $? -eq 0 ]]; then
      echo "✅ $profile: Success"
      ((success++))
    else
      echo "❌ $profile: Failed"
      ((failed++))
    fi
    
    echo ""
  done
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Summary:"
  echo "   ✅ Success: $success"
  echo "   ❌ Failed: $failed"
}

# Check which profiles have valid (non-expired) sessions
awsstatus() {
  echo "📊 AWS SSO Session Status"
  echo ""
  
  local profiles=($(_aws_sso_profiles))
  
  if [[ ${#profiles[@]} -eq 0 ]]; then
    echo "❌ No AWS SSO profiles found"
    return 1
  fi
  
  echo "Checking ${#profiles[@]} profile(s)..."
  echo ""
  
  for profile in "${profiles[@]}"; do
    # Try to get caller identity (will fail if session expired)
    if aws sts get-caller-identity --profile "$profile" &>/dev/null; then
      local account=$(aws sts get-caller-identity --profile "$profile" --query Account --output text 2>/dev/null)
      local user=$(aws sts get-caller-identity --profile "$profile" --query Arn --output text 2>/dev/null | cut -d'/' -f2)
      printf "✅ %-20s Active   (Account: %s, User: %s)\n" "$profile" "$account" "$user"
    else
      printf "❌ %-20s Expired\n" "$profile"
    fi
  done
  
  echo ""
  echo "💡 To refresh expired sessions, run: awslogin"
}

# Set AWS_PROFILE environment variable with fzf selection
awsuse() {
  if [[ -n "$1" ]]; then
    # Direct profile name provided
    export AWS_PROFILE="$1"
    echo "✅ AWS_PROFILE set to: $1"
    echo ""
    echo "💡 Current identity:"
    aws sts get-caller-identity 2>/dev/null || echo "   (Session may be expired - run 'awslogin')"
  else
    # Interactive selection with fzf
    local profiles=($(_aws_sso_profiles))
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
      echo "❌ No AWS SSO profiles found"
      return 1
    fi
    
    echo "Select AWS profile to use:"
    echo ""
    
    local selected=$(printf '%s\n' "${profiles[@]}" | fzf --height=40% --prompt="AWS Profile> ")
    
    if [[ -n "$selected" ]]; then
      export AWS_PROFILE="$selected"
      echo ""
      echo "✅ AWS_PROFILE set to: $selected"
      echo ""
      echo "💡 Current identity:"
      aws sts get-caller-identity 2>/dev/null || echo "   (Session may be expired - run 'awslogin')"
    fi
  fi
}

# Unset AWS_PROFILE
awsclear() {
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "🗑️  Clearing AWS_PROFILE (was: $AWS_PROFILE)"
    unset AWS_PROFILE
  else
    echo "ℹ️  AWS_PROFILE is not set"
  fi
}

# Show current AWS profile and identity
awswhoami() {
  echo "🔍 Current AWS Configuration"
  echo ""
  
  if [[ -n "$AWS_PROFILE" ]]; then
    echo "Profile: $AWS_PROFILE"
  else
    echo "Profile: (default)"
  fi
  
  echo ""
  echo "Identity:"
  
  if aws sts get-caller-identity 2>/dev/null; then
    echo ""
    echo "✅ Session is active"
  else
    echo "❌ No active session (run 'awslogin')"
  fi
}

# List all AWS profiles (SSO and non-SSO)
awsprofiles() {
  echo "📋 AWS Profiles in ~/.aws/config"
  echo ""
  
  if [[ ! -f ~/.aws/config ]]; then
    echo "❌ No ~/.aws/config file found"
    return 1
  fi
  
  echo "SSO Profiles:"
  local sso_profiles=($(_aws_sso_profiles))
  if [[ ${#sso_profiles[@]} -gt 0 ]]; then
    printf '  ✅ %s\n' "${sso_profiles[@]}"
  else
    echo "  (none)"
  fi
  
  echo ""
  echo "All Profiles:"
  awk '/\[profile / {profile=$2; gsub(/\]/, "", profile); print "  • " profile}' ~/.aws/config
  
  echo ""
  echo "💡 Use 'awslogin' to login to SSO profiles"
  echo "💡 Use 'awsuse' to switch active profile"
}

# Open AWS SSO config file in editor
awsconfig() {
  if [[ ! -f ~/.aws/config ]]; then
    echo "❌ No ~/.aws/config file found"
    echo ""
    echo "💡 Create it with: aws configure sso"
    return 1
  fi
  
  ${EDITOR:-vim} ~/.aws/config
}

# Setup new SSO profile (wrapper around aws configure sso)
awssetup() {
  echo "🔧 AWS SSO Profile Setup"
  echo ""
  echo "This will guide you through setting up a new SSO profile."
  echo ""
  
  read "?Press Enter to continue (or Ctrl+C to cancel)..."
  
  echo ""
  aws configure sso
  
  if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ SSO profile configured!"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Run 'awslogin' to authenticate"
    echo "   2. Run 'awsuse' to set the profile"
    echo "   3. Start using AWS CLI!"
  fi
}

# Comprehensive help for AWS SSO
awshelp() {
  cat << 'EOF'
🔐 AWS SSO TOOLKIT - Quick Reference
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AUTHENTICATION COMMANDS:
  awslogin          - Login to AWS SSO (fzf picks profile)
  awsloginall       - Login to ALL SSO profiles at once
  awsstatus         - Check which profiles have active sessions

PROFILE MANAGEMENT:
  awsuse            - Set AWS_PROFILE (fzf picks profile)
  awsuse <profile>  - Set specific profile
  awsclear          - Unset AWS_PROFILE
  awswhoami         - Show current profile and identity
  awsprofiles       - List all configured profiles

SETUP & CONFIG:
  awssetup          - Setup new SSO profile (interactive)
  awsconfig         - Edit ~/.aws/config file

HELP:
  awshelp           - Show this help

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

QUICK START:

  1. Setup (one-time):
     awssetup

  2. Login:
     awslogin
     [fzf menu appears, select profile]

  3. Set active profile:
     awsuse
     [fzf menu appears, select profile]

  4. Use AWS CLI:
     aws s3 ls
     aws ec2 describe-instances

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TYPICAL WORKFLOW:

  # Morning routine - login to all profiles
  awsloginall

  # Switch between profiles as needed
  awsuse prod
  aws s3 ls

  awsuse dev
  aws ec2 describe-instances

  # Check what profile you're using
  awswhoami

  # Check session status
  awsstatus

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TROUBLESHOOTING:

Problem: "Unable to locate credentials"
Fix:     awslogin

Problem: "Session expired"
Fix:     awslogin

Problem: "Which profile am I using?"
Fix:     awswhoami

Problem: "Forgot profile names"
Fix:     awsprofiles

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IMPORTANT FILES:

  ~/.aws/config         - Profile configuration (edit with: awsconfig)
  ~/.aws/sso/cache/     - Cached credentials (auto-managed)
  ~/.aws/credentials    - NOT used for SSO

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For complete documentation, see: AWS-SSO-SETUP-GUIDE.md

EOF
}

# ====================================
# ALIASES
# ====================================

alias awsl='awslogin'           # Quick login
alias awsla='awsloginall'       # Login all
alias awss='awsstatus'          # Status check
alias awsw='awswhoami'          # Who am I
alias awsp='awsprofiles'        # List profiles
