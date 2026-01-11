# Extension Template

Copy this template to create a new project that integrates with hubers-devtools-system.

---

## Project Structure

```
foo-powertools/
├── extensions/
│   └── foo-powertools.zsh   # All functionality + favorites display
├── scripts/
│   └── install.sh           # Installer
├── config.sh                # Your config (optional)
└── docs/
    └── README.md
```

---

## Template Files

### 1. extensions/foo-powertools.zsh

This ONE file contains everything - aliases, functions, AND favorites display.

```bash
#!/bin/zsh
# ============================================================================
# Foo Powertools Extension for hubers-devtools-system
#
# Installed to: ~/.zsh/extensions.d/foo-powertools.zsh
# ============================================================================

# ============================================================================
# Configuration
# ============================================================================

# Find project directory
_find_foo_dir() {
    local dirs=(
        "$HOME/foo-powertools"
        "$HOME/Projects/foo-powertools"
    )
    for d in "${dirs[@]}"; do
        [[ -d "$d" ]] && echo "$d" && return 0
    done
    return 1
}

# Set FOO_DIR if not already set
[[ -z "$FOO_DIR" ]] && FOO_DIR="$(_find_foo_dir)"

# Skip if not found
[[ -z "$FOO_DIR" || ! -d "$FOO_DIR" ]] && return 0

export FOO_DIR

# Load config if exists
[[ -f "$FOO_DIR/config.sh" ]] && source "$FOO_DIR/config.sh"

# ============================================================================
# Functions
# ============================================================================

foo-status() {
    echo "Foo Powertools Status"
    echo "  Project: $FOO_DIR"
}

foo-do-something() {
    echo "Doing something..."
    # Your logic here
}

# ============================================================================
# Aliases (use foo- prefix!)
# ============================================================================

alias foo-status='foo-status'
alias foo-do='foo-do-something'
alias foo-config='${EDITOR:-nano} $FOO_DIR/config.sh'

# ============================================================================
# Help
# ============================================================================

foo-help() {
    cat << 'EOF'
Foo Powertools Commands:
--------------------------------------------
  foo-status      Show status
  foo-do          Do something
  foo-config      Edit configuration
  foo-help        Show this help
--------------------------------------------
EOF
}

# ============================================================================
# Favorites Display (auto-called by devtools)
# Line 1 = section header, rest = command | description
# ============================================================================

_foo_powertools_favorites() {
    cat << 'EOF'
FOO POWERTOOLS
foo-status | Show status
foo-do | Do something
foo-config | Edit config
foo-help | Show help
EOF
}

# ============================================================================
# End Foo Powertools Extension
# ============================================================================
```

---

### 2. scripts/install.sh

```zsh
#!/bin/zsh
# ============================================================================
# Foo Powertools Installer
# ============================================================================

set -e

echo "=========================================="
echo "Foo Powertools Installer"
echo "=========================================="

SCRIPT_DIR="${0:a:h}"           # Directory containing this script
PROJECT_ROOT="${0:a:h:h}"       # Parent directory (project root)

echo "Project: $PROJECT_ROOT"
echo ""

# ============================================================================
# Detect devtools
# ============================================================================

DEVTOOLS_DETECTED=false
if grep -q "Ultimate Developer .zshrc" ~/.zshrc 2>/dev/null; then
    DEVTOOLS_DETECTED=true
elif grep -q "EXTERNAL EXTENSIONS HOOK" ~/.zshrc 2>/dev/null; then
    DEVTOOLS_DETECTED=true
fi

if [ "$DEVTOOLS_DETECTED" = true ]; then
    echo "hubers-devtools detected"
else
    echo "hubers-devtools not found (standalone mode)"
fi
echo ""

# ============================================================================
# Confirm
# ============================================================================

echo "This will install:"
if [ "$DEVTOOLS_DETECTED" = true ]; then
    echo "  ~/.zsh/extensions.d/foo-powertools.zsh"
else
    echo "  Source line in ~/.zshrc"
fi
echo ""

echo -n "Continue? (y/n) "
read -k 1 REPLY
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0

# ============================================================================
# Install
# ============================================================================

if [ "$DEVTOOLS_DETECTED" = true ]; then
    mkdir -p ~/.zsh/extensions.d
    cp "$PROJECT_ROOT/extensions/foo-powertools.zsh" ~/.zsh/extensions.d/
    echo "Installed: ~/.zsh/extensions.d/foo-powertools.zsh"
else
    if ! grep -q "foo-powertools" ~/.zshrc 2>/dev/null; then
        cat >> ~/.zshrc << EOF

# Foo Powertools
export FOO_DIR="$PROJECT_ROOT"
[ -f "$PROJECT_ROOT/extensions/foo-powertools.zsh" ] && source "$PROJECT_ROOT/extensions/foo-powertools.zsh"
EOF
        echo "Added to ~/.zshrc"
    else
        echo "Already in ~/.zshrc"
    fi
fi

# ============================================================================
# Done
# ============================================================================

echo ""
echo "Done! Run:"
echo "  source ~/.zshrc"
echo "  foo-help"
echo ""
echo "To uninstall:"
if [ "$DEVTOOLS_DETECTED" = true ]; then
    echo "  rm ~/.zsh/extensions.d/foo-powertools.zsh"
else
    echo "  Edit ~/.zshrc and remove 'Foo Powertools' section"
fi
```

---

## Checklist for New Projects

- [ ] Create `extensions/PROJECT-NAME.zsh`
- [ ] Use unique prefix for ALL aliases (`foo-`, `bar-`, etc.)
- [ ] Add `_projectname_favorites()` function for favorites display
- [ ] Create `scripts/install.sh` that detects devtools
- [ ] Test with devtools: `bash scripts/install.sh && source ~/.zshrc && fav`
- [ ] Test without devtools (rename ~/.zshrc temporarily)
- [ ] Verify commands work: `foo-help`
- [ ] Verify favorites show: `fav`

---

## Quick Copy Commands

```bash
# Create new project structure
mkdir -p my-project/{extensions,scripts,docs}

# Copy and customize the template files above
# Then:
cd my-project
bash scripts/install.sh
source ~/.zshrc
my-help
```

---

## Favorites Format Reference

```bash
_myproject_favorites() {
    cat << 'EOF'
MY PROJECT HEADER
cmd1 | Short description
cmd2 | Another description
cmd3 | Third command
EOF
}
```

**Rules:**
- Line 1 = Section header (displayed with dashes)
- Other lines = `command | description` format
- System auto-formats into 2 columns
- System auto-applies colors
