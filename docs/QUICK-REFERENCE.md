# 📋 Quick Reference

## Commands

| Command | Description |
|---------|-------------|
| `devsetup` | Interactive menu |
| `devsetup check` | What's installed/missing |
| `devsetup install` | Install required tools |
| `devsetup install-all` | Install ALL tools |
| `devsetup add <tool>` | Install specific tool |
| `devsetup search <q>` | Search for tools |
| `devsetup versions` | Show installed versions |
| `devsetup tool-versions` | Generate .tool-versions |
| `devsetup asdf-update` | Update asdf plugins |
| `devsetup update` | Update all packages |
| `devsetup outdated` | Show outdated packages |
| `devsetup categories` | List all categories |
| `devsetup list <cat>` | List tools in category |
| `devsetup doctor` | Diagnose issues |
| `devsetup export` | Export tool list |

## asdf Quick Reference

```bash
asdf current                    # Show current versions
asdf list all <tool>            # Available versions
asdf install <tool> <version>   # Install version
asdf global <tool> <version>    # Set global default
asdf local <tool> <version>     # Pin for directory
```

## Adding a Tool

```yaml
# Brew tool - in config/tools.yaml
category_name:
  - name: tool-name
    brew: brew-formula
    description: "What it does"
    check: "tool --version"
    required: false

# asdf tool (version-managed)
asdf_tools:
  - name: tool-name
    asdf_plugin: plugin-name
    description: "What it does"
    check: "tool --version"
    required: true
    default_version: "latest"
```

## File Locations

| File | Purpose |
|------|---------|
| `config/tools.yaml` | Tool definitions |
| `bin/devsetup` | CLI script |
| `bootstrap.sh` | Fresh setup script |
| `~/.zshrc` | Shell config |
| `~/.oh-my-zsh/` | Oh-My-Zsh install |
| `~/.p10k.zsh` | P10k config |
| `.tool-versions` | Per-project versions |

## Fresh Mac Setup

```bash
# 1. Clone/unzip repo
cd mac-dev-setup

# 2. Run bootstrap
./bootstrap.sh

# 3. New terminal, configure p10k
p10k configure

# 4. Install your tools
devsetup install
```

## Common Tasks

```bash
# See what's missing
devsetup check

# Add kubernetes tools
devsetup add kubectl
devsetup add k9s
devsetup add helm

# Pin terraform version for project
asdf local terraform 1.5.7

# Generate .tool-versions
devsetup tool-versions

# Update everything
devsetup update
```
