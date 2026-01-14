# asdf Version Management Guide

> **Note:** This guide is for asdf v0.18.0+. Commands like `global`, `local`, and `shell`
> have been replaced with `asdf set`.

## Why asdf?

**asdf** is a universal version manager. Instead of using `nvm` for Node, `pyenv` for Python, `tfenv` for Terraform, etc., you use ONE tool for everything.

**Key benefits:**
- **One tool** - Manage all languages/tools the same way
- **Per-project versions** - `.tool-versions` files auto-switch versions
- **Easy switching** - Install multiple versions, switch instantly
- **Huge plugin ecosystem** - 600+ tools supported

## Quick Reference (v0.18.0+)

```bash
# See what's installed
asdf current                    # Current versions in use
asdf list                       # All installed versions
asdf list <tool>                # Versions of specific tool

# Install versions
asdf install <tool> latest      # Install latest
asdf install <tool> 1.5.7       # Install specific version
asdf install                    # Install all from .tool-versions

# Set versions (NEW in v0.18.0)
asdf set -u <tool> 1.5.7        # Set user default (~/.tool-versions)
asdf set <tool> 1.5.7           # Set for current directory (.tool-versions)
asdf set -p <tool> 1.5.7        # Set in parent directory's .tool-versions

# Find versions
asdf list all <tool>            # All available versions
asdf latest <tool>              # Latest stable version

# Manage plugins
asdf plugin list                # Installed plugins
asdf plugin list all            # All available plugins
asdf plugin update --all        # Update all plugins
```

### Command Changes from Earlier Versions

| Old Command (pre-0.18) | New Command (0.18.0+) |
|------------------------|----------------------|
| `asdf global <tool> <ver>` | `asdf set -u <tool> <ver>` |
| `asdf local <tool> <ver>` | `asdf set <tool> <ver>` |
| `asdf shell <tool> <ver>` | *(removed - use env var instead)* |

## Tools Managed by asdf (in this setup)

| Tool | Why asdf? |
|------|-----------|
| **terraform** | Projects often require specific TF versions |
| **kubectl** | Match your cluster's Kubernetes version |
| **java** | JDK 17 vs 21, project requirements |
| **awscli** | AWS CLI version management |

## Common Workflows

### Starting a New Project

```bash
cd my-project

# Pin versions for this project
asdf set terraform 1.13.4
asdf set kubectl 1.33.2

# This creates .tool-versions file - commit it!
cat .tool-versions
# terraform 1.13.4
# kubectl 1.33.2
```

### Joining an Existing Project

```bash
cd existing-project

# If project has .tool-versions, install those versions
asdf install

# Done! You now have the exact versions the project needs
```

### Upgrading a Tool

```bash
# See what's available
asdf list all terraform | tail -20

# Install new version
asdf install terraform 1.14.3

# Test it in current shell (set env var)
ASDF_TERRAFORM_VERSION=1.14.3 terraform version

# If good, make it your default
asdf set -u terraform 1.14.3
```

### Working with Multiple Terraform Versions

```bash
# Install multiple versions
asdf install terraform 1.13.4
asdf install terraform 1.14.3

# Project A needs 1.13.x
cd project-a
asdf set terraform 1.13.4

# Project B needs 1.14.x
cd project-b
asdf set terraform 1.14.3

# Auto-switches when you cd!
cd project-a && terraform version  # 1.13.4
cd project-b && terraform version  # 1.14.3
```

## The .tool-versions File

This is the magic file that makes asdf awesome for teams:

```
# .tool-versions
terraform 1.13.4
kubectl 1.33.2
java temurin-17.0.17+10
awscli 2.32.34
```

**Best practices:**
- Commit this file to your repo
- Everyone on the team gets the same versions
- CI/CD can use it too
- Document why specific versions are pinned

### Your Global Defaults

Your user-level defaults are in `~/.tool-versions`:

```bash
# View your global defaults
cat ~/.tool-versions

# Set a new global default
asdf set -u terraform 1.13.4
```

## Installing via devsetup

```bash
# Install asdf itself
devsetup add asdf

# Install asdf-managed tools (adds plugin + latest version)
devsetup add terraform
devsetup add kubectl
devsetup add java

# See what's installed
asdf list
asdf current
```

## Manual Plugin Management

```bash
# Add a plugin not in the manifest
asdf plugin add <name>
asdf plugin add <name> <git-url>

# Example: Add erlang
asdf plugin add erlang

# Update plugins (gets new versions)
asdf plugin update --all
# Or just one
asdf plugin update terraform
```

## Troubleshooting

### "No version set for command"

```bash
# Set a user default
asdf set -u <tool> latest

# Or install from .tool-versions
asdf install
```

### Plugin install fails

```bash
# Some plugins need dependencies
# For nodejs:
brew install gpg gawk

# For python:
brew install openssl readline sqlite3 xz zlib

# For java:
# Usually works out of the box
```

### Wrong version being used

```bash
# Check where version is being set
asdf current

# Shows: terraform 1.13.4 /path/to/.tool-versions

# Check your .tool-versions files
cat .tool-versions
cat ~/.tool-versions
```

### asdf command not found (after install)

Your `.zshrc` should have this (added by setup):
```bash
# For Homebrew install (Apple Silicon)
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# For Homebrew install (Intel)
. /usr/local/opt/asdf/libexec/asdf.sh
```

Then: `source ~/.zshrc`

## Comparison: asdf vs Homebrew

| Scenario | Use asdf | Use Homebrew |
|----------|----------|--------------|
| Need multiple versions | Yes | No |
| Per-project versions | Yes | No |
| Just want "latest" | Either | Yes |
| GUI applications | No | Yes |
| System utilities | No | Yes |
| Team standardization | Yes | No |

## Resources

- [asdf Documentation](https://asdf-vm.com/guide/getting-started.html)
- [asdf Plugins](https://github.com/asdf-vm/asdf-plugins)
- [.tool-versions Spec](https://asdf-vm.com/manage/configuration.html)
