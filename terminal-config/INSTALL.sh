#!/bin/bash
# Ultimate Terminal Setup - Installer (Powerlevel10k Edition)
# 
# This installs the terminal configuration (zshrc, toolkits, docs)
# It does NOT install tools - use bootstrap.sh for full setup or devsetup for tools
#
# SAFE TO RUN MULTIPLE TIMES

echo "🚀 Ultimate Terminal Setup - Powerlevel10k Edition"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Detect framework location (where this script is running from)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"

# Verify we're in the right place
if [[ ! -f "$FRAMEWORK_DIR/bin/devsetup" ]]; then
    echo "⚠️  Warning: Can't find devsetup at $FRAMEWORK_DIR/bin/"
    echo "   Make sure you're running from the terminal-config directory"
fi

echo "Framework location: $FRAMEWORK_DIR"
echo ""

# Backup existing files
if [ -f ~/.zshrc ]; then
  backup_file=~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
  echo "📦 Backing up ~/.zshrc to $backup_file"
  cp ~/.zshrc "$backup_file"
fi

# Remove old starship config that might conflict
if [ -f ~/.config/starship.toml ]; then
  echo "📦 Backing up old ~/.config/starship.toml"
  mv ~/.config/starship.toml ~/.config/starship.toml.old
fi

# Create directories
mkdir -p ~/.zsh/previews
mkdir -p ~/.zsh/extensions.d   # External projects install here (functionality + favorites)
mkdir -p ~/.cache

echo "📥 Installing files..."
cp home/.zshrc ~/
cp home/.zsh/*.zsh ~/.zsh/
cp home/.zsh/_kubectl_static ~/.zsh/
cp home/.zsh/previews/*.zsh ~/.zsh/previews/

# Copy documentation (remove old first to avoid nesting)
echo "📚 Installing documentation..."
rm -rf ~/.zsh/docs
cp -r docs ~/.zsh/docs
echo "   Documentation installed to: ~/.zsh/docs/"

# Keep starship.toml in case user wants to switch later
if [ -f home/.zsh/starship.toml ]; then
  cp home/.zsh/starship.toml ~/.zsh/
fi

# ============================================================================
# Create personal customizations file if it doesn't exist
# ============================================================================
echo "🎨 Checking for personal customizations file..."
if [ ! -f ~/.zshrc_hubers ]; then
  echo "   Creating ~/.zshrc_hubers (your personal customizations)"
  cp home/.zshrc_hubers.template ~/.zshrc_hubers
  echo "   ✅ Created ~/.zshrc_hubers with helpful template"
  echo "   📝 This file will NEVER be overwritten by the installer"
  echo "   📝 Add your custom aliases, functions, and configs there!"
else
  echo "   ✅ ~/.zshrc_hubers exists (preserving your customizations)"
  echo "   📝 Your personal customizations are safe and untouched!"
fi

echo ""
echo "✅ Core files installed!"
echo ""

# ============================================================================
# devsetup is now auto-detected by .zshrc!
# ============================================================================
echo "🔧 Checking devsetup command..."

if [ -f "$FRAMEWORK_DIR/bin/devsetup" ]; then
    echo "   ✅ devsetup found at $FRAMEWORK_DIR/bin/"
    echo "   💡 Your .zshrc will auto-detect this location"
else
    echo "   ⚠️  devsetup not found at $FRAMEWORK_DIR/bin/"
    echo "   Run bootstrap.sh first if you haven't"
fi

echo ""

# ============================================================================
# Check for Powerlevel10k
# ============================================================================
echo "🔍 Checking for Powerlevel10k..."
if [ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ] || \
   [ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ] || \
   [ -f ~/powerlevel10k/powerlevel10k.zsh-theme ] || \
   [ -f ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme ]; then
  echo "✅ Powerlevel10k found!"
else
  echo "⚠️  Powerlevel10k NOT found!"
  echo ""
  echo "Install now? (recommended)"
  echo ""
  
  if command -v brew &>/dev/null; then
    echo "Option 1: Install via Homebrew (recommended)"
    echo "  brew install powerlevel10k"
    echo ""
    read -p "Install via Homebrew now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      brew install powerlevel10k
      echo "✅ Powerlevel10k installed via Homebrew!"
    fi
  else
    echo "Option 2: Install manually"
    echo "  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k"
    echo ""
    read -p "Install manually now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
      echo "✅ Powerlevel10k installed manually!"
    fi
  fi
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ Installation Complete!"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "  1. Reload your shell:"
echo "     source ~/.zshrc"
echo ""
echo "  2. Configure Powerlevel10k (first time):"
echo "     p10k configure"
echo "     → Say YES to transient prompt!"
echo ""
echo "  3. Check your tools:"
echo "     devsetup check"
echo ""
echo "  4. Customize your startup display:"
echo "     favedit"
echo ""
echo "  5. Add your personal customizations:"
echo "     vim ~/.zshrc_hubers"
echo "     (This file is NEVER overwritten by reinstalls)"
echo ""
echo "📚 Documentation: ~/.zsh/docs/"
echo "🔧 Tool config:   $FRAMEWORK_DIR/config/tools.yaml"
echo "⚙️  Personal:     ~/.zshrc_hubers (your custom aliases/functions)"
echo ""
echo "🎉 Enjoy your legendary terminal!"
echo ""
