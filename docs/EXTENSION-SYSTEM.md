# Extension System

## Overview

External projects integrate with hubers-devtools-system by installing ONE file to `~/.zsh/extensions.d/`. This file contains BOTH functionality (aliases, functions) AND favorites display.

**Starting a new project?** See [EXTENSION-TEMPLATE.md](EXTENSION-TEMPLATE.md) for copy-paste templates.

---

## How It Works

```
~/.zsh/extensions.d/
    └── your-extension.zsh    # ONE file with everything
```

Your extension file includes:
1. **Aliases & functions** - The commands that do things
2. **`_yourext_favorites()` function** - Optional, auto-displayed in `fav`

---

## Simple Example

```bash
#!/bin/zsh
# ~/.zsh/extensions.d/foo-tools.zsh

# === FUNCTIONALITY ===
alias foo-status='echo "Foo is running"'
alias foo-help='echo "Commands: foo-status, foo-help"'

# === FAVORITES DISPLAY (optional) ===
_foo_tools_favorites() {
    cat << 'EOF'
FOO TOOLS
foo-status | Show status
foo-help | Show help
EOF
}
```

**That's it!** The system:
- Sources your file on shell startup (aliases work)
- Finds `_foo_tools_favorites` function
- Auto-displays in `fav` output with proper formatting

---

## Favorites Function Format

```bash
_yourext_favorites() {
    cat << 'EOF'
SECTION HEADER          <- First line = header
command1 | Description  <- Rest = command | description pairs
command2 | Description
command3 | Description
EOF
}
```

The system automatically:
- Uses first line as section header (with dashes)
- Formats commands in 2 columns
- Applies colors (green commands, white descriptions)
- Handles odd numbers of commands

---

## Installation

External projects install via their installer script:

```bash
# In your project's install.sh

# Check for devtools
if grep -q "Ultimate Developer .zshrc" ~/.zshrc 2>/dev/null; then
    # Devtools present - use extension system
    mkdir -p ~/.zsh/extensions.d
    cp extensions/my-extension.zsh ~/.zsh/extensions.d/
else
    # No devtools - add source line to .zshrc
    echo "source /path/to/my-extension.zsh" >> ~/.zshrc
fi
```

---

## Rules for Extensions

### 1. Use Unique Prefixes

```bash
# GOOD
alias foo-status='...'
alias foo-run='...'

# BAD (may conflict)
alias status='...'
alias run='...'
```

### 2. Name the Favorites Function Correctly

Pattern: `_projectname_favorites`

```bash
_foo_tools_favorites()      # Good
_work_tunnel_favorites()    # Good
_my_extension_favorites()   # Good
```

### 3. Don't Modify Devtools Files

Never touch:
- `~/.zshrc`
- `~/.zsh/*.zsh` (except extensions.d/)
- `~/.zshrc_hubers`

### 4. Provide Uninstall

```bash
# To uninstall:
rm ~/.zsh/extensions.d/my-extension.zsh
source ~/.zshrc
```

---

## Load Order

```
~/.zshrc (devtools)
    ├── Oh-My-Zsh, plugins
    ├── Devtools toolkits
    ├── ~/.zsh/extensions.d/*.zsh  ← YOUR EXTENSION
    ├── Favorites display + extension favorites
    └── ~/.zshrc_hubers            ← User customizations (last)
```

**User customizations always win** - they load last and can override anything.

---

## Debugging

```bash
# Check extension is installed
ls ~/.zsh/extensions.d/

# Test extension loads without errors
zsh -n ~/.zsh/extensions.d/my-extension.zsh

# Source manually to see errors
source ~/.zsh/extensions.d/my-extension.zsh

# Check if favorites function exists
type _myext_favorites

# Test favorites display
fav
```

---

## Benefits

1. **ONE folder** - Simple to understand
2. **ONE file per project** - Everything in one place
3. **Auto-formatting** - Just provide command | description
4. **Optional favorites** - Don't define the function if you don't need it
5. **Self-contained** - Each project is independent
6. **AI-friendly** - Work on one project without loading the other

---

## Quick Reference

```bash
# Extension location
~/.zsh/extensions.d/my-extension.zsh

# Check what's installed
ls ~/.zsh/extensions.d/

# Reload after changes
source ~/.zshrc

# Remove an extension
rm ~/.zsh/extensions.d/my-extension.zsh
source ~/.zshrc
```
