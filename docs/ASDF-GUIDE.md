# 🔄 asdf Version Management Guide

## Why asdf?

**asdf** is a universal version manager. Instead of using `nvm` for Node, `pyenv` for Python, `tfenv` for Terraform, etc., you use ONE tool for everything.

**Key benefits:**
- 🎯 **One tool** - Manage all languages/tools the same way
- 📁 **Per-project versions** - `.tool-versions` files auto-switch versions
- 🔄 **Easy switching** - Install multiple versions, switch instantly
- 📦 **Huge plugin ecosystem** - 600+ tools supported

## Quick Reference

```bash
# See what's installed
asdf current                    # Current versions in use
asdf list                       # All installed versions
asdf list <tool>                # Versions of specific tool

# Install versions
asdf install <tool> latest      # Install latest
asdf install <tool> 1.5.7       # Install specific version
asdf install                    # Install all from .tool-versions

# Set versions
asdf global <tool> 1.5.7        # Set global default
asdf local <tool> 1.5.7         # Set for current directory (creates .tool-versions)
asdf shell <tool> 1.5.7         # Set for current shell session only

# Find versions
asdf list all <tool>            # All available versions
asdf latest <tool>              # Latest stable version

# Manage plugins
asdf plugin list                # Installed plugins
asdf plugin list all            # All available plugins
asdf plugin update --all        # Update all plugins
```

## Tools Managed by asdf (in this setup)

| Tool | Why asdf? |
|------|-----------|
| **terraform** | Projects often require specific TF versions |
| **kubectl** | Match your cluster's Kubernetes version |
| **helm** | Helm 2 vs 3, version compatibility |
| **nodejs** | Different projects, different Node versions |
| **python** | Python 2 vs 3, project requirements |
| **golang** | Go version requirements |
| **awscli** | AWS CLI v1 vs v2 |
| **java** | JDK version requirements |

## Common Workflows

### Starting a New Project

```bash
cd my-project

# Pin versions for this project
asdf local terraform 1.5.7
asdf local nodejs 20.10.0
asdf local python 3.11.7

# This creates .tool-versions file - commit it!
cat .tool-versions
# terraform 1.5.7
# nodejs 20.10.0
# python 3.11.7
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
asdf install terraform 1.6.0

# Test it
asdf shell terraform 1.6.0    # Try in this shell only
terraform version

# If good, make it your default
asdf global terraform 1.6.0
```

### Working with Multiple Terraform Versions

```bash
# Install multiple versions
asdf install terraform 1.4.6
asdf install terraform 1.5.7
asdf install terraform 1.6.0

# Project A needs 1.4.x
cd project-a
asdf local terraform 1.4.6

# Project B needs 1.5.x
cd project-b
asdf local terraform 1.5.7

# Auto-switches when you cd!
cd project-a && terraform version  # 1.4.6
cd project-b && terraform version  # 1.5.7
```

## The .tool-versions File

This is the magic file that makes asdf awesome for teams:

```
# .tool-versions
terraform 1.5.7
nodejs 20.10.0
python 3.11.7
kubectl 1.28.0
helm 3.13.0
```

**Best practices:**
- ✅ Commit this file to your repo
- ✅ Everyone on the team gets the same versions
- ✅ CI/CD can use it too
- ✅ Document why specific versions are pinned

### Generating .tool-versions

```bash
# Generate from your current global versions
devsetup tool-versions

# Or manually create
echo "terraform 1.5.7" >> .tool-versions
echo "nodejs 20.10.0" >> .tool-versions
```

## Installing via devsetup

```bash
# Install asdf-managed tools
devsetup add terraform     # Installs plugin + latest version
devsetup add kubectl
devsetup add nodejs

# Install all required asdf tools at once
devsetup install

# See what's installed
devsetup versions
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

### "No version set for <tool>"

```bash
# Set a global default
asdf global <tool> latest

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

# For ruby:
brew install openssl@3 readline libyaml gmp
```

### Wrong version being used

```bash
# Check where version is being set
asdf current

# Shows: terraform 1.5.7 (set by /path/to/.tool-versions)

# Check your .tool-versions files
cat .tool-versions
cat ~/.tool-versions
```

### asdf command not found (after install)

Add to your `~/.zshrc`:
```bash
# For Homebrew install
. $(brew --prefix asdf)/libexec/asdf.sh

# For git install
. $HOME/.asdf/asdf.sh
```

Then: `source ~/.zshrc`

## Comparison: asdf vs Homebrew

| Scenario | Use asdf | Use Homebrew |
|----------|----------|--------------|
| Need multiple versions | ✅ | ❌ |
| Per-project versions | ✅ | ❌ |
| Just want "latest" | Either | ✅ |
| GUI applications | ❌ | ✅ |
| System utilities | ❌ | ✅ |
| Team standardization | ✅ | ❌ |

## Resources

- [asdf Documentation](https://asdf-vm.com/guide/getting-started.html)
- [asdf Plugins](https://github.com/asdf-vm/asdf-plugins)
- [.tool-versions Spec](https://asdf-vm.com/manage/configuration.html)
