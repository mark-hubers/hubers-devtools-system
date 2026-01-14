# Project Coexistence Guide

## Overview

External projects integrate via ONE folder: `~/.zsh/extensions.d/`

Each project installs ONE file that contains everything.

---

## How It Works

```
~/.zsh/extensions.d/
    ├── work-tunnel.zsh      # From personal-to-work-mac-setup
    ├── foo-tools.zsh        # From another project
    └── ...                  # Future projects
```

Each file contains:
- Aliases & functions (functionality)
- `_projectname_favorites()` function (display in `fav`)

---

## File Ownership

### Devtools owns:
- `~/.zshrc`
- `~/.zsh/*.zsh`

### User owns:
- `~/.zshrc_local` (personal customizations)
- `~/.zsh/extensions.d/*` (external projects)

---

## For External Projects

1. Create `extensions/your-project.zsh` with all functionality
2. Add `_your_project_favorites()` function for display
3. Create installer that copies to `~/.zsh/extensions.d/`
4. Use unique prefix for aliases (`your-*`)

**See:** [EXTENSION-TEMPLATE.md](EXTENSION-TEMPLATE.md) for complete template.

---

## Load Order

```
~/.zshrc
    ├── Devtools
    ├── ~/.zsh/extensions.d/*.zsh  ← External projects
    ├── Favorites + extension favorites
    └── ~/.zshrc_local            ← User customizations (last)
```

---

## Quick Reference

```bash
# See what's installed
ls ~/.zsh/extensions.d/

# Remove an extension
rm ~/.zsh/extensions.d/NAME.zsh
source ~/.zshrc
```
