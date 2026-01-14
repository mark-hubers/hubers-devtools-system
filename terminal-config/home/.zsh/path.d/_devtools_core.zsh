#!/bin/zsh
# ============================================================================
# Core PATH Configuration
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# For custom PATH additions, create your own file without _devtools_ prefix
# ============================================================================

# VSCode CLI (if installed)
if [ -d "/Applications/Visual Studio Code.app" ]; then
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

# User's personal bin directory
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# Claude Code CLI (installed via: curl -fsSL https://claude.ai/install.sh | sh)
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Auto-detect Hubers Dev Tools framework location
for possible_location in \
  "$HOME/my-tools/hubers-devtools-system" \
  "$HOME/hubers-devtools-system" \
  "$HOME/Projects/hubers-devtools-system" \
  "$HOME/repos/hubers-devtools-system" \
  "$HOME/mac-dev-setup" \
  "$HOME/Projects/mac-dev-setup"; do

  if [ -f "$possible_location/bin/devsetup" ]; then
    export PATH="$possible_location/bin:$PATH"
    export HUBERS_DEVTOOLS_HOME="$possible_location"
    break
  fi
done

# Krew (kubectl plugin manager)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Work scripts
if [ -d "$HOME/git/as/SCRM_CIDR/scripts_and_sharelib/bin" ]; then
  export PATH="$HOME/git/as/SCRM_CIDR/scripts_and_sharelib/bin:$PATH"
fi

# Homebrew curl (prefer over system curl)
if [ -d "/opt/homebrew/opt/curl/bin" ]; then
  export PATH="/opt/homebrew/opt/curl/bin:$PATH"
fi
