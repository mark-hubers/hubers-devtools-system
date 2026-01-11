#!/bin/zsh
# ============================================================================
# Setup Utilities - Shared Library for hubers-devtools
# ============================================================================
# Source this in any setup.sh script for consistent output and helpers.
#
# Usage:
#   source "$(dirname "$0")/../hubers-devtools-system/lib/setup-utils.sh"
#   # or if devtools location is known:
#   source "$DEVTOOLS_DIR/lib/setup-utils.sh"
#
# Provides:
#   - Color output (print_*, colors)
#   - Status functions (success, fail, warn, info, step)
#   - Idempotent helpers (ensure_dir, ensure_file, ensure_line_in_file)
#   - OS detection (detect_os, is_macos, is_linux)
#   - Plugin discovery (find_plugins, load_plugin_info)
# ============================================================================

# ============================================================================
# Colors & Formatting
# ============================================================================

# Only use colors if terminal supports it
if [[ -t 1 ]] && [[ -n "$TERM" ]] && [[ "$TERM" != "dumb" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[0;37m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
    BOLD=''
    DIM=''
    RESET=''
fi

# ============================================================================
# Output Functions
# ============================================================================

# Print with color
print_red()     { echo -e "${RED}$*${RESET}"; }
print_green()   { echo -e "${GREEN}$*${RESET}"; }
print_yellow()  { echo -e "${YELLOW}$*${RESET}"; }
print_blue()    { echo -e "${BLUE}$*${RESET}"; }
print_magenta() { echo -e "${MAGENTA}$*${RESET}"; }
print_cyan()    { echo -e "${CYAN}$*${RESET}"; }
print_bold()    { echo -e "${BOLD}$*${RESET}"; }
print_dim()     { echo -e "${DIM}$*${RESET}"; }

# Status messages
success() { echo -e "${GREEN}✓${RESET} $*"; }
fail()    { echo -e "${RED}✗${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
info()    { echo -e "${BLUE}ℹ${RESET} $*"; }
skip()    { echo -e "${DIM}○ $* (skipped)${RESET}"; }

# Step headers
step() {
    echo ""
    echo -e "${BOLD}${BLUE}▶ $*${RESET}"
    echo -e "${DIM}$(printf '─%.0s' {1..50})${RESET}"
}

# Section headers
section() {
    echo ""
    echo -e "${BOLD}════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  $*${RESET}"
    echo -e "${BOLD}════════════════════════════════════════════════════${RESET}"
    echo ""
}

# Ask yes/no question, returns 0 for yes, 1 for no
ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"  # default to yes

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    echo -n "$prompt"
    read -k 1 REPLY
    echo ""

    if [[ -z "$REPLY" ]]; then
        REPLY="$default"
    fi

    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# ============================================================================
# OS Detection
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

is_macos() { [[ "$(detect_os)" == "macos" ]]; }
is_linux() { [[ "$(detect_os)" == "linux" ]]; }

# ============================================================================
# Idempotent Helpers
# ============================================================================

# Ensure directory exists
ensure_dir() {
    local dir="$1"
    local mode="${2:-755}"

    if [[ -d "$dir" ]]; then
        skip "Directory exists: $dir"
        return 0
    fi

    mkdir -p "$dir"
    chmod "$mode" "$dir"
    success "Created directory: $dir"
}

# Ensure file exists (optionally with content)
ensure_file() {
    local file="$1"
    local content="${2:-}"

    if [[ -f "$file" ]]; then
        skip "File exists: $file"
        return 0
    fi

    if [[ -n "$content" ]]; then
        echo "$content" > "$file"
    else
        touch "$file"
    fi
    success "Created file: $file"
}

# Ensure line exists in file (append if not)
ensure_line_in_file() {
    local file="$1"
    local line="$2"

    if [[ ! -f "$file" ]]; then
        echo "$line" > "$file"
        success "Created $file with content"
        return 0
    fi

    if grep -qF "$line" "$file" 2>/dev/null; then
        skip "Line already in $file"
        return 0
    fi

    echo "$line" >> "$file"
    success "Added line to $file"
}

# Check if command exists
has_command() {
    command -v "$1" &>/dev/null
}

# ============================================================================
# Plugin Discovery
# ============================================================================

# Find the my-tools directory (parent of devtools-system)
find_my_tools_dir() {
    # If DEVTOOLS_DIR is set, use its parent
    if [[ -n "$DEVTOOLS_DIR" ]]; then
        dirname "$DEVTOOLS_DIR"
        return 0
    fi

    # Common locations to check
    local locations=(
        "$HOME/my-tools"
        "$HOME/tools"
        "$HOME/devtools"
    )

    for loc in "${locations[@]}"; do
        if [[ -d "$loc/hubers-devtools-system" ]]; then
            echo "$loc"
            return 0
        fi
    done

    # Fallback: assume ~/my-tools
    echo "$HOME/my-tools"
}

# Find all plugins (directories with .devtools-plugin marker)
find_plugins() {
    local my_tools_dir
    my_tools_dir="$(find_my_tools_dir)"

    local plugins=()

    for dir in "$my_tools_dir"/*/; do
        # Skip devtools-system itself
        [[ "$(basename "$dir")" == "hubers-devtools-system" ]] && continue

        # Check for plugin marker
        if [[ -f "${dir}.devtools-plugin" ]]; then
            plugins+=("$dir")
        fi
    done

    printf '%s\n' "${plugins[@]}"
}

# Load plugin info from .devtools-plugin file
# Usage: load_plugin_info "/path/to/plugin" "FIELD"
# Example: load_plugin_info "$plugin" "NAME" → returns plugin name
load_plugin_info() {
    local plugin_dir="$1"
    local field="$2"
    local plugin_file="${plugin_dir}/.devtools-plugin"

    if [[ ! -f "$plugin_file" ]]; then
        return 1
    fi

    grep "^${field}=" "$plugin_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"'
}

# Run a plugin's setup.sh
run_plugin_setup() {
    local plugin_dir="$1"
    local setup_script="${plugin_dir}/setup.sh"

    if [[ ! -x "$setup_script" ]]; then
        if [[ -f "$setup_script" ]]; then
            chmod +x "$setup_script"
        else
            fail "No setup.sh found in $plugin_dir"
            return 1
        fi
    fi

    (cd "$plugin_dir" && ./setup.sh)
}

# ============================================================================
# Devtools Detection
# ============================================================================

# Find devtools-system directory
find_devtools_dir() {
    local locations=(
        "$HOME/my-tools/hubers-devtools-system"
        "$HOME/hubers-devtools-system"
        "$HOME/Projects/hubers-devtools-system"
        "$HOME/repos/hubers-devtools-system"
    )

    for loc in "${locations[@]}"; do
        if [[ -d "$loc" && -f "$loc/setup.sh" ]]; then
            echo "$loc"
            return 0
        fi
    done

    # Check if bootstrap.sh exists (old name)
    for loc in "${locations[@]}"; do
        if [[ -d "$loc" && -f "$loc/bootstrap.sh" ]]; then
            echo "$loc"
            return 0
        fi
    done

    return 1
}

# Check if devtools-system is installed and working
is_devtools_installed() {
    # Check if DEVTOOLS_DIR is set and valid
    if [[ -n "$DEVTOOLS_DIR" && -d "$DEVTOOLS_DIR" ]]; then
        return 0
    fi

    # Check if the zshrc has devtools loaded
    if grep -q "Ultimate Developer" ~/.zshrc 2>/dev/null; then
        return 0
    fi

    # Check if extension system exists
    if [[ -d ~/.zsh/extensions.d ]]; then
        return 0
    fi

    return 1
}

# Require devtools to be installed (exit if not)
require_devtools() {
    if is_devtools_installed; then
        return 0
    fi

    echo ""
    fail "hubers-devtools-system is required but not installed"
    echo ""
    echo "  Please run devtools setup first:"
    echo ""

    local devtools_dir
    if devtools_dir="$(find_devtools_dir)"; then
        echo "    cd $devtools_dir && ./setup.sh"
    else
        echo "    cd ~/my-tools/hubers-devtools-system && ./setup.sh"
    fi
    echo ""
    exit 1
}

# ============================================================================
# Export DEVTOOLS_DIR if not set
# ============================================================================

if [[ -z "$DEVTOOLS_DIR" ]]; then
    if _found_dir="$(find_devtools_dir 2>/dev/null)"; then
        export DEVTOOLS_DIR="$_found_dir"
    fi
fi
