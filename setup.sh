#!/bin/bash
# ============================================================================
# Dev Setup - Main Setup Script (macOS & Linux)
# ============================================================================
# The one script to set up your dev environment. Run it fresh or to fix things.
#
# Usage:
#   ./setup.sh
#
# What this does:
#   1. Detects your OS (macOS or Linux)
#   2. Installs Homebrew (if needed)
#   3. Installs ZSH and makes it default shell
#   4. Installs Oh-My-Zsh with plugins
#   5. Installs Powerlevel10k
#   6. Installs core CLI tools
#   7. Sets up framework and devsetup command
#   8. Installs terminal configuration
#   9. Discovers and offers to set up plugins (work-tunnel, etc.)
#
# Optional (not run automatically):
#   - Git multi-account setup: git-things/hubers_git_setup.sh
#     See docs/GIT-MULTI-ACCOUNT.md for manual setup guide
#
# SAFE TO RUN MULTIPLE TIMES - checks before doing anything
# ============================================================================

set -e

# ============================================================================
# Configuration
# ============================================================================

# Get script directory (where setup.sh is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Smart install location:
# - If we're in a git repo, use that location (don't copy)
# - Otherwise, copy to ~/hubers-devtools
if [[ -d "$SCRIPT_DIR/.git" ]] || git -C "$SCRIPT_DIR" rev-parse --git-dir &>/dev/null 2>&1; then
    # We're in a git repo - use this location
    INSTALL_DIR="$SCRIPT_DIR"
    IS_GIT_REPO=true
else
    # Not in git repo - will copy to ~/hubers-devtools
    INSTALL_DIR="$HOME/hubers-devtools"
    IS_GIT_REPO=false
fi

# Colors (works in bash too)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if [[ $(uname -m) == "arm64" ]]; then
            BREW_PREFIX="/opt/homebrew"
        else
            BREW_PREFIX="/usr/local"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"
        # Detect distro
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO="$ID"
        fi
    else
        echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
        exit 1
    fi
}

# Get script directory (where setup.sh is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}🚀 Dev Environment Bootstrap${NC}                               ${BOLD}${CYAN}║${NC}"
    if [[ "$OS" == "macos" ]]; then
        echo -e "${BOLD}${CYAN}║${NC}     Setting up your Mac for development                      ${BOLD}${CYAN}║${NC}"
    else
        echo -e "${BOLD}${CYAN}║${NC}     Setting up your Linux box for development                ${BOLD}${CYAN}║${NC}"
    fi
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━ Step $1: $2 ━━━${NC}"
    echo ""
}

success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
action() { echo -e "${YELLOW}👉 ACTION NEEDED: $1${NC}"; }

# Track manual actions needed
MANUAL_ACTIONS=()

add_manual_action() {
    MANUAL_ACTIONS+=("$1")
}

# Helper to add line to file if not already present
add_line_to_file() {
    local line="$1"
    local file="$2"
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        return 0  # Added
    fi
    return 1  # Already exists
}

# ============================================================================
# Main Setup
# ============================================================================

detect_os
print_header

echo -e "Detected: ${BOLD}$OS${NC}"
[[ -n "${DISTRO:-}" ]] && echo -e "Distro: ${BOLD}$DISTRO${NC}"
echo -e "Install location: ${BOLD}$INSTALL_DIR${NC}"
echo ""

# ============================================================================
# SMART DETECTION - Check if already installed
# ============================================================================

# Check for existing installation
ALREADY_INSTALLED=false
REASONS=()

if command -v brew &> /dev/null; then
    REASONS+=("✅ Homebrew is installed")
    ALREADY_INSTALLED=true
fi

if [ -d ~/.oh-my-zsh ]; then
    REASONS+=("✅ Oh-My-Zsh is installed")
    ALREADY_INSTALLED=true
fi

if command -v devsetup &> /dev/null; then
    REASONS+=("✅ devsetup command is available")
    ALREADY_INSTALLED=true
fi

if [ -f ~/.zshrc ] && grep -q "Ultimate Developer .zshrc" ~/.zshrc 2>/dev/null; then
    REASONS+=("✅ Terminal configuration is installed")
    ALREADY_INSTALLED=true
fi

# If already installed, offer to just update
if [ "$ALREADY_INSTALLED" = true ]; then
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${BOLD}   ⚠️  WAIT! It looks like you're already set up!${NC}"
    echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "I detected:"
    for reason in "${REASONS[@]}"; do
        echo "  $reason"
    done
    echo ""
    echo -e "${CYAN}${BOLD}setup.sh${NC} handles ${BOLD}BOTH${NC} fresh installs AND updates"
    echo -e "It's smart enough to skip what's already done."
    echo ""
    read -p "Continue with setup? (Y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    echo ""
    echo -e "${CYAN}Running setup (will skip what's already done)...${NC}"
    echo ""
fi

# ============================================================================
# Step 1: Homebrew
# ============================================================================
print_step 1 "Homebrew Package Manager"

if command -v brew &> /dev/null; then
    success "Homebrew is already installed"
    brew --version | head -1
else
    if [[ "$OS" == "linux" ]]; then
        info "Installing build dependencies for Homebrew..."
        if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
            sudo apt-get update
            sudo apt-get install -y build-essential procps curl file git
        elif [[ "$DISTRO" == "fedora" || "$DISTRO" == "rhel" || "$DISTRO" == "centos" ]]; then
            sudo dnf groupinstall -y 'Development Tools'
            sudo dnf install -y procps-ng curl file git
        fi
    fi
    
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "${BREW_PREFIX}/bin/brew" ]]; then
        eval "$(${BREW_PREFIX}/bin/brew shellenv)"
    fi
    
    success "Homebrew installed"
fi

# Make sure brew is in PATH for rest of script
if [[ -f "${BREW_PREFIX}/bin/brew" ]]; then
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# ============================================================================
# Step 2: ZSH
# ============================================================================
print_step 2 "ZSH Shell"

if command -v zsh &> /dev/null; then
    success "ZSH is already installed"
    zsh --version
else
    echo "Installing ZSH..."
    brew install zsh
    success "ZSH installed"
fi

# Check if zsh is the default shell
CURRENT_SHELL=$(basename "$SHELL")
ZSH_PATH=$(which zsh)

if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    warning "Your default shell is $CURRENT_SHELL, not zsh"
    echo ""
    
    # Add zsh to /etc/shells if needed
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    
    echo "Changing default shell to zsh..."
    if chsh -s "$ZSH_PATH"; then
        success "Default shell changed to zsh"
        add_manual_action "Log out and log back in for shell change to take effect"
    else
        warning "Could not change shell automatically"
        add_manual_action "Run: chsh -s $ZSH_PATH"
    fi
else
    success "ZSH is already your default shell"
fi

# ============================================================================
# Step 3: Git (needed for oh-my-zsh)
# ============================================================================
print_step 3 "Git"

if command -v git &> /dev/null; then
    success "Git is already installed"
else
    echo "Installing Git..."
    brew install git
    success "Git installed"
fi

# ============================================================================
# Step 4: Oh-My-Zsh
# ============================================================================
print_step 4 "Oh-My-Zsh Framework"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh-My-Zsh is already installed"
else
    echo "Installing Oh-My-Zsh..."
    # Use RUNZSH=no to prevent it from switching to zsh mid-script
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh-My-Zsh installed"
fi

# Install ZSH plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "Installing ZSH plugins..."

plugins_to_install=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab"
)

for plugin_info in "${plugins_to_install[@]}"; do
    plugin_name="${plugin_info%%|*}"
    plugin_url="${plugin_info#*|}"
    plugin_dir="${ZSH_CUSTOM}/plugins/${plugin_name}"
    
    if [[ ! -d "$plugin_dir" ]]; then
        echo "  Installing $plugin_name..."
        git clone --depth=1 "$plugin_url" "$plugin_dir" 2>/dev/null
    else
        echo "  $plugin_name already installed"
    fi
done

success "ZSH plugins installed"

# ============================================================================
# Step 5: Powerlevel10k
# ============================================================================
print_step 5 "Powerlevel10k Prompt"

P10K_INSTALLED=false

# Check various install locations
if [[ -f "${BREW_PREFIX}/share/powerlevel10k/powerlevel10k.zsh-theme" ]] || \
   [[ -f "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]] || \
   [[ -f "${ZSH_CUSTOM}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    P10K_INSTALLED=true
fi

if $P10K_INSTALLED; then
    success "Powerlevel10k is already installed"
else
    echo "Installing Powerlevel10k..."
    if [[ "$OS" == "macos" ]]; then
        brew install powerlevel10k
    else
        # On Linux, clone directly (brew install can be slow)
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
    fi
    success "Powerlevel10k installed"
    add_manual_action "Run 'p10k configure' to set up your prompt (say YES to transient prompt!)"
fi

# ============================================================================
# Step 6: Core CLI Tools
# ============================================================================
print_step 6 "Core CLI Tools"

core_tools=(
    "fzf"
    "eza"
    "bat"
    "ripgrep"
    "fd"
    "zoxide"
    "git-delta"
    "jq"
    "yq"
    "gum"
    "glow"
)

echo "Installing essential CLI tools..."
for tool in "${core_tools[@]}"; do
    if brew list "$tool" &>/dev/null; then
        echo "  ✓ $tool"
    else
        echo "  Installing $tool..."
        brew install "$tool" 2>/dev/null || warning "Failed to install $tool"
    fi
done

# Run fzf install script
if [[ -f "${BREW_PREFIX}/opt/fzf/install" ]]; then
    echo "Configuring fzf..."
    "${BREW_PREFIX}/opt/fzf/install" --all --no-bash --no-fish 2>/dev/null || true
fi

success "Core CLI tools installed"

# ============================================================================
# Step 7: Nerd Fonts
# ============================================================================
print_step 7 "Nerd Fonts (for terminal icons)"

if [[ "$OS" == "macos" ]]; then
    if ls ~/Library/Fonts/*Meslo* &>/dev/null || ls /Library/Fonts/*Meslo* &>/dev/null; then
        success "Meslo Nerd Font already installed"
    else
        echo "Installing Meslo Nerd Font..."
        brew install --cask font-meslo-lg-nerd-font 2>/dev/null || warning "Could not install font via cask"
        success "Font installed"
        add_manual_action "Set your terminal font to 'MesloLGS NF' (iTerm2: Preferences → Profiles → Text → Font)"
    fi
else
    # Linux font installation
    FONT_DIR="$HOME/.local/share/fonts"
    if ls "$FONT_DIR"/*Meslo* &>/dev/null 2>&1; then
        success "Meslo Nerd Font already installed"
    else
        echo "Installing Meslo Nerd Font..."
        mkdir -p "$FONT_DIR"
        cd /tmp
        curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"
        unzip -o Meslo.zip -d "$FONT_DIR" 2>/dev/null || true
        rm -f Meslo.zip
        fc-cache -fv 2>/dev/null || true
        success "Font installed"
        add_manual_action "Set your terminal font to 'MesloLGS NF' in your terminal preferences"
    fi
fi

# ============================================================================
# Step 8: Install Framework
# ============================================================================
print_step 8 "Setting Up Framework at $INSTALL_DIR"

if $IS_GIT_REPO; then
    # We're in a git repo - just use this location
    success "Running from Git repo - using $INSTALL_DIR"
    chmod +x "$INSTALL_DIR/bin/devsetup" 2>/dev/null || true
    chmod +x "$INSTALL_DIR/setup.sh" 2>/dev/null || true
    chmod +x "$INSTALL_DIR/terminal-config/INSTALL.sh" 2>/dev/null || true
else
    # Not in git repo - copy to ~/hubers-devtools
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "Framework directory already exists, updating..."
        # Update files but preserve user's tools.yaml if modified
        if [[ -f "$INSTALL_DIR/config/tools.yaml" ]]; then
            cp "$INSTALL_DIR/config/tools.yaml" "$INSTALL_DIR/config/tools.yaml.backup"
            info "Backed up existing tools.yaml"
        fi
    fi

    # Create directory and copy files
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/bin/devsetup"
    chmod +x "$INSTALL_DIR/setup.sh"
    chmod +x "$INSTALL_DIR/terminal-config/INSTALL.sh" 2>/dev/null || true

    success "Framework installed to $INSTALL_DIR"
fi

# ============================================================================
# Step 9: Configure Shell
# ============================================================================
print_step 9 "Configuring Shell"

# Create .zshrc if it doesn't exist
touch "$HOME/.zshrc"

# Add Homebrew to .zshrc if not there
if ! grep -q "brew shellenv" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Homebrew" >> "$HOME/.zshrc"
    echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> "$HOME/.zshrc"
    success "Added Homebrew to .zshrc"
else
    echo "  Homebrew already in .zshrc"
fi

# devsetup PATH is now auto-detected by the new .zshrc!
# The terminal-config/INSTALL.sh will set up a .zshrc that auto-detects the framework location
info "devsetup will be auto-detected by your .zshrc after terminal config is installed"

# Add zoxide init if not there
if ! grep -q "zoxide init" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Zoxide (smart cd)" >> "$HOME/.zshrc"
    echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
    success "Added zoxide to .zshrc"
else
    echo "  zoxide already in .zshrc"
fi

success "Shell configured"

# ============================================================================
# Step 10: Terminal Config (optional)
# ============================================================================
print_step 10 "Terminal Configuration"

if [[ -d "$INSTALL_DIR/terminal-config" ]]; then
    echo "Found terminal configuration package."
    echo "This includes your custom .zshrc with 70+ functions, toolkits, and docs."
    echo ""
    read -p "Install terminal configuration? (y/n) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$INSTALL_DIR/terminal-config"
        ./INSTALL.sh
    else
        info "Skipped. You can install later with: cd $INSTALL_DIR/terminal-config && ./INSTALL.sh"
    fi
else
    info "No terminal-config directory found."
fi

# ============================================================================
# Step 11: Plugin Discovery (work-tunnel, etc.)
# ============================================================================
print_step 11 "Plugin Discovery"

# Find the my-tools directory (parent of this script's location)
MY_TOOLS_DIR="$(dirname "$INSTALL_DIR")"

# Look for plugins (directories with .devtools-plugin marker)
PLUGINS_FOUND=()
for dir in "$MY_TOOLS_DIR"/*/; do
    # Skip devtools-system itself
    [[ "$(basename "$dir")" == "hubers-devtools-system" ]] && continue

    # Check for plugin marker
    if [[ -f "${dir}.devtools-plugin" ]]; then
        PLUGINS_FOUND+=("$dir")
    fi
done

if [[ ${#PLUGINS_FOUND[@]} -eq 0 ]]; then
    info "No plugins found in $MY_TOOLS_DIR"
    echo "  To add plugins, clone them to $MY_TOOLS_DIR/"
    echo "  Each plugin needs a .devtools-plugin marker file"
else
    echo "Found ${#PLUGINS_FOUND[@]} plugin(s):"
    echo ""

    for plugin_dir in "${PLUGINS_FOUND[@]}"; do
        plugin_name=$(grep "^NAME=" "${plugin_dir}.devtools-plugin" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
        plugin_desc=$(grep "^DESCRIPTION=" "${plugin_dir}.devtools-plugin" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
        plugin_name="${plugin_name:-$(basename "$plugin_dir")}"

        echo "  • $plugin_name"
        [[ -n "$plugin_desc" ]] && echo "    $plugin_desc"
    done
    echo ""

    read -p "Set up all plugins? (Y/n) " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        for plugin_dir in "${PLUGINS_FOUND[@]}"; do
            plugin_name=$(grep "^NAME=" "${plugin_dir}.devtools-plugin" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
            plugin_name="${plugin_name:-$(basename "$plugin_dir")}"

            echo ""
            echo -e "${BOLD}Setting up: $plugin_name${NC}"

            if [[ -x "${plugin_dir}setup.sh" ]]; then
                (cd "$plugin_dir" && ./setup.sh)
            elif [[ -f "${plugin_dir}setup.sh" ]]; then
                chmod +x "${plugin_dir}setup.sh"
                (cd "$plugin_dir" && ./setup.sh)
            else
                warning "No setup.sh found in $plugin_dir"
            fi
        done
    else
        info "Skipped plugin setup"
        echo "  You can set up plugins individually:"
        for plugin_dir in "${PLUGINS_FOUND[@]}"; do
            echo "    cd $plugin_dir && ./setup.sh"
        done
    fi
fi

# ============================================================================
# Done!
# ============================================================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}✅ Setup Complete!${NC}                                          ${BOLD}${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}Framework installed to:${NC} $INSTALL_DIR"
echo ""

# Show manual actions if any
if [[ ${#MANUAL_ACTIONS[@]} -gt 0 ]]; then
    echo -e "${BOLD}${YELLOW}📋 Manual Actions Required:${NC}"
    echo ""
    for i in "${!MANUAL_ACTIONS[@]}"; do
        echo -e "   $((i+1)). ${MANUAL_ACTIONS[$i]}"
    done
    echo ""
fi

echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo -e "  1. ${BOLD}Start a new terminal${NC} (or run: source ~/.zshrc)"
echo ""
echo -e "  2. ${BOLD}Configure Powerlevel10k${NC} (if not done):"
echo "     p10k configure"
echo "     → Say YES to transient prompt!"
echo ""
echo -e "  3. ${BOLD}Check your setup${NC}:"
echo "     devsetup check"
echo ""
echo -e "  4. ${BOLD}Install more tools${NC}:"
echo "     devsetup install      # Install all required tools"
echo "     devsetup add k9s      # Install specific tool"
echo ""
echo -e "  5. ${BOLD}Git multi-account${NC} (optional - read docs first):"
echo "     See: $INSTALL_DIR/docs/GIT-MULTI-ACCOUNT.md"
echo ""
echo -e "${BOLD}Key locations:${NC}"
echo "  Tools config:  $INSTALL_DIR/config/tools.yaml"
echo "  Documentation: $INSTALL_DIR/docs/"
echo ""
echo -e "${BOLD}Enjoy your dev environment! 🎉${NC}"
echo ""
