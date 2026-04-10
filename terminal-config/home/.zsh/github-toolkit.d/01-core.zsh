# ============================================================================
# GitHub CLI Toolkit — Core (dependency checks, doctor)
# ============================================================================

## chmod 600 using absolute path — survives minimal PATH in subshells (e.g. ghadmin one-shot)
_gh_chmod_600() {
   local f="$1"
   if [[ -x /bin/chmod ]]; then
      /bin/chmod 600 "$f"
   else
      command chmod 600 "$f"
   fi
}

_gh_require_command() {
   local cmd="$1"
   local install_hint="${2:-Install and retry.}"
   if ! command -v "$cmd" &>/dev/null; then
      echo "✗ Missing dependency: $cmd"
      echo "   $install_hint"
      return 1
   fi
   return 0
}

_gh_check() {
   local require_auth=1
   [[ "$1" == "--no-auth" ]] && require_auth=0

   if ! command -v gh &>/dev/null; then
      echo "✗ GitHub CLI (gh) is not installed"
      echo ""
      echo "Install:"
      if [[ "$OSTYPE" == "darwin"* ]]; then
         echo "  brew install gh"
      elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "win32"* ]]; then
         echo "  winget install GitHub.cli"
         echo "  or: choco install gh"
      elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
         echo "  See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
      else
         echo "  See: https://cli.github.com/"
      fi
      echo ""
      echo "After installing, run: gh auth login"
      return 1
   fi

   if [[ $require_auth -eq 1 ]] && ! gh auth status &>/dev/null; then
      echo "⚠ Not authenticated with GitHub"
      echo ""
      echo "Run: gh auth login"
      echo "Or: ghlogin"
      return 1
   fi

   return 0
}

_gh_require_jq() {
   _gh_require_command jq "Install jq (required for ghvar/ghsecret/ghteam output parsing)." || return 1
}

ghdoctor() {
   _gh_check --no-auth || return 1
   _gh_title "📋 GitHub CLI Toolkit Doctor"
   echo ""

   local failed=0
   local platform="unknown"
   if [[ "$OSTYPE" == "darwin"* ]]; then
      platform="macOS"
   elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      platform="Linux"
   elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "win32"* ]]; then
      platform="Windows shell"
   fi
   echo "Platform: $platform ($OSTYPE)"
   echo ""

   _gh_require_command gh "Install from https://cli.github.com/" || failed=1
   _gh_require_command jq "macOS: brew install jq | Linux: apt/yum install jq" || failed=1

   if ! _gh_require_command fzf "Install fzf for interactive pickers."; then
      echo "⚠ fzf-dependent commands will not work (ghswitch, ghclone, ghrepos)."
   fi

   if ! _gh_require_command op "Install 1Password CLI only if you use ghadd option 5."; then
      echo "⚠ Optional: op is only needed for 1Password token loading."
   fi

   if gh auth status &>/dev/null; then
      echo "✓ gh auth status: authenticated"
   else
      echo "⚠ gh auth status: not authenticated (run: gh auth login)"
   fi

   ## Check profile system
   if [[ -n "$GH_ACTIVE_PROFILE" ]]; then
      echo "✓ Active profile: $GH_ACTIVE_PROFILE (mode=$GH_PROFILE_MODE)"
   else
      echo "⚠ No active profile (run: ghprofile create or ghprofile help)"
   fi

   ## Check admin token
   if [[ -f "$HOME/.gh-admin-token" ]]; then
      local perms
      perms=$(stat -f '%Lp' "$HOME/.gh-admin-token" 2>/dev/null || stat -c '%a' "$HOME/.gh-admin-token" 2>/dev/null)
      if [[ "$perms" == "600" ]]; then
         echo "✓ Admin token: ~/.gh-admin-token (perms OK)"
      else
         echo "⚠ Admin token: ~/.gh-admin-token (perms=$perms, should be 600)"
      fi
   fi

   echo ""
   _gh_rule
   if [[ $failed -eq 0 ]]; then
      echo "✓ Doctor check complete"
      return 0
   fi
   echo "✗ Doctor found blocking issues"
   return 1
}
