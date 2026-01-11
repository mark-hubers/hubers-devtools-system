# 🔧 Maintenance Guide

**System architecture and framework internals.**

This document explains how the system works technically. For specific tasks:

- **Adding tools:** See `ADDING-TOOLS.md`
- **Working with Sonnet:** See `SONNET-GUIDE.md`
- **Git workflow:** See `GIT-WORKFLOW.md`
- **Fixing problems:** See `RECOVERY.md`

---

## 📁 Installed Locations

After running `bootstrap.sh`, files are installed to:

```
~/hubers-devtools/               ← FRAMEWORK (tool management)
├── bin/devsetup                 ← Main CLI tool
├── config/tools.yaml            ← THE KEY FILE - all tool definitions
├── docs/                        ← Documentation
├── bootstrap.sh                 ← Can re-run to update
└── terminal-config/             ← Source for shell config

~/.zsh/                          ← SHELL RUNTIME (loaded by .zshrc)
├── bookmarks.zsh                ← Bookmark functions
├── favorites.zsh                ← Startup display
├── markdown-toolkit.zsh         ← MD conversion functions
├── my-favorites.txt             ← User's favorite commands
├── network-toolkit.zsh
├── aws-sso-toolkit.zsh
├── github-cli-toolkit.zsh
├── previews/                    ← FZF preview scripts
└── docs/                        ← Command reference
```

**Key file for adding tools:** `~/hubers-devtools/config/tools.yaml`

---

## 📁 Project Structure

```
mac-dev-setup/
├── bootstrap.sh              # First-run script (installs brew, zsh, oh-my-zsh, etc.)
├── bin/
│   └── devsetup             # Main CLI tool (bash script)
├── config/
│   └── tools.yaml           # THE KEY FILE - all tool definitions
├── terminal-config/         # Optional: Your P10K terminal package
│   ├── INSTALL.sh
│   ├── home/.zshrc
│   └── home/.zsh/           # Toolkits, plugins, completions
├── docs/
│   ├── ADDING-TOOLS.md
│   ├── MAINTENANCE.md       # This file
│   └── QUICK-REFERENCE.md
└── README.md
```

---

## 🔑 Key Files

### 1. `config/tools.yaml` - The Tool Manifest

This is **the most important file**. It defines every tool the system knows about.

**Structure:**
```yaml
category_name:
  - name: tool-name           # Required: unique identifier
    brew: brew-formula        # Homebrew formula/cask name
    cask: true               # Set true for GUI apps (brew --cask)
    tap: owner/tap           # Custom Homebrew tap if needed
    description: "What it does"  # Shown in listings
    check: "command --version"   # Command to verify installation
    required: true           # true = install by default, false = optional
    post_install:            # Commands to run after install
      - "some command"
    install_manual: |        # For non-brew tools
      curl ... | sh
    docs: "https://..."      # Documentation URL
```

### 2. `bin/devsetup` - The CLI Tool

A bash script that:
- Parses `tools.yaml` using `yq`
- Checks what's installed
- Installs missing tools via brew
- Provides search, list, update commands

**Key functions:**
- `get_tools_in_category()` - List tools in a category
- `get_tool_field()` - Get a specific field from a tool
- `check_tool_installed()` - Run the tool's check command
- `install_tool()` - Install a tool via brew or manual method

### 3. `bootstrap.sh` - First-Run Setup

Handles a completely fresh Mac/Linux:
1. Detects OS (macOS vs Linux)
2. Installs Homebrew
3. Installs/configures ZSH
4. Installs Oh-My-Zsh + plugins
5. Installs Powerlevel10k
6. Installs core CLI tools
7. Sets up PATH

---

## 🛠 Common Maintenance Tasks

### Adding a New Tool

1. Open `config/tools.yaml`
2. Find the right category (or create one)
3. Add the tool entry:

```yaml
dev_tools:
  # ... existing tools ...
  
  - name: new-tool
    brew: new-tool
    description: "What it does"
    check: "new-tool --version"
    required: false
```

4. Test: `devsetup add new-tool`

### Adding a Tool That Needs a Tap

```yaml
  - name: special-tool
    brew: special-tool
    tap: "owner/tap-name"
    description: "Description"
    check: "special-tool --version"
```

### Adding an asdf-managed Tool (version-managed)

Put it in the `asdf_tools` category:

```yaml
asdf_tools:
  - name: my-runtime
    asdf_plugin: my-runtime           # Plugin name (usually same as tool)
    description: "Tool that needs version management"
    check: "my-runtime --version"
    required: true
    default_version: "latest"         # or specific like "1.5.7" or "lts"
```

This tells devsetup to:
1. Install the asdf plugin
2. Install the specified version
3. Set it as global default

### Adding a Cask (GUI App)

```yaml
apps:
  - name: my-app
    brew: my-app
    cask: true
    description: "A GUI application"
    check: "test -d '/Applications/My App.app'"
```

### Adding a Tool Installed via Script (not brew)

```yaml
  - name: rustup
    description: "Rust toolchain installer"
    check: "rustc --version"
    install_manual: |
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```

### Creating a New Category

Just add a new top-level key in `tools.yaml`:

```yaml
my_new_category:
  - name: tool1
    brew: tool1
    description: "First tool"
    check: "tool1 --version"
```

### Marking a Tool as Required

Change `required: false` to `required: true`, or add the field if missing.

### Removing a Tool from Manifest

Just delete its entry from `tools.yaml`. The tool won't be uninstalled, just no longer tracked.

---

## 🐛 Troubleshooting

### "yq not found"

The devsetup script auto-installs yq, but if it fails:
```bash
brew install yq
```

### Tool shows as "not installed" but is installed

Check the `check` command. It might be:
- Wrong binary name
- Missing from PATH
- Need to check a different way

Test manually:
```bash
# Whatever is in the check field
some-tool --version
```

### Bootstrap fails on Linux

Make sure build tools are installed:
```bash
# Ubuntu/Debian
sudo apt-get install build-essential curl file git

# Fedora
sudo dnf groupinstall 'Development Tools'
```

### Powerlevel10k not loading

Check your `~/.zshrc` has the source line:
```bash
# For Homebrew install (Mac)
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# For git clone install (Linux)
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
```

---

## 📝 Code Style Guidelines

When modifying scripts:

1. **Use lowercase with underscores** for function names: `get_tool_field()`
2. **Use UPPERCASE** for constants: `TOOLS_FILE`, `BREW_PREFIX`
3. **Always quote variables**: `"$var"` not `$var`
4. **Use `[[ ]]` for conditionals** (bash/zsh), not `[ ]`
5. **Add comments** for non-obvious logic
6. **Keep functions focused** - one job per function

---

## 🔄 Typical Sonnet Session

When a user asks to add/modify tools, here's a typical workflow:

**User:** "Can you add support for terraform-docs?"

**Sonnet should:**
1. View `config/tools.yaml` to understand the structure
2. Find the appropriate category (probably `iac`)
3. Add the tool entry:
   ```yaml
   - name: terraform-docs
     brew: terraform-docs
     description: "Generate documentation from Terraform"
     check: "terraform-docs --version"
     required: false
   ```
4. Explain how to install: `devsetup add terraform-docs`

**User:** "Make kubectl required instead of optional"

**Sonnet should:**
1. Find kubectl in `tools.yaml`
2. Change `required: false` to `required: true`
3. Note that running `devsetup install` will now install it

---

## 🧪 Testing Changes

After modifying `tools.yaml`:

```bash
# Verify YAML syntax
yq eval '.' config/tools.yaml > /dev/null && echo "Valid YAML"

# Check the tool appears
devsetup search <tool-name>

# Test installation
devsetup add <tool-name>

# Verify it's detected
devsetup check
```

---

## 📚 Reference

### Full tools.yaml field reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | Yes | string | Unique tool identifier |
| `brew` | No | string | Homebrew formula name |
| `cask` | No | boolean | True if it's a cask |
| `tap` | No | string | Homebrew tap (owner/repo) |
| `description` | Yes | string | What the tool does |
| `check` | Yes | string | Shell command to verify install |
| `required` | No | boolean | Install by default? |
| `post_install` | No | list | Commands after install |
| `install_manual` | No | string | Non-brew install command |
| `docs` | No | string | Documentation URL |
| `asdf_plugin` | No | string | asdf plugin name |
| `default_version` | No | string | Version to install (latest, lts, 1.5.7) |

### devsetup commands

| Command | What it does |
|---------|--------------|
| `devsetup` | Interactive menu |
| `devsetup check` | Show installed/missing |
| `devsetup install` | Install required tools |
| `devsetup install-all` | Install ALL tools |
| `devsetup add <tool>` | Install one tool |
| `devsetup search <q>` | Search tools |
| `devsetup list <cat>` | List category |
| `devsetup categories` | List categories |
| `devsetup versions` | Show tool versions |
| `devsetup tool-versions` | Generate .tool-versions |
| `devsetup asdf-update` | Update asdf plugins |
| `devsetup update` | Update all packages |
| `devsetup outdated` | Show outdated |
| `devsetup doctor` | Diagnose issues |
| `devsetup export` | Export tool list |
