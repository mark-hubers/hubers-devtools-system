# Hubers Dev Tools

A modular dev environment framework for macOS and Linux. One command sets up your entire development environment with modern CLI tools, ZSH configuration, and a plugin system for extensions.

## Features

- **One-command setup** - `./setup.sh` handles everything, safe to re-run
- **Modern CLI tools** - eza, bat, fzf, ripgrep, delta, zoxide, and more
- **Beautiful terminal** - Powerlevel10k prompt with Oh-My-Zsh
- **Tool management** - `devsetup` command to install/manage dev tools
- **Plugin system** - Auto-discovers extensions in `~/my-tools/`
- **Idempotent** - Skips what's already installed, fixes what's broken

## Quick Start

```bash
# Clone to ~/my-tools (recommended) or anywhere
git clone https://github.com/mark-hubers/hubers-devtools-system.git ~/my-tools/hubers-devtools-system
cd ~/my-tools/hubers-devtools-system

# Run setup (installs everything)
./setup.sh

# Open new terminal, then configure your prompt
p10k configure
```

## What Gets Installed

| Category | Tools |
|----------|-------|
| Shell | ZSH, Oh-My-Zsh, Powerlevel10k |
| Modern CLI | eza, bat, fzf, ripgrep, fd, zoxide, delta |
| Plugins | zsh-autosuggestions, zsh-syntax-highlighting, fzf-tab |
| Fonts | Meslo Nerd Font |
| Framework | devsetup command, toolkits, 70+ shell functions |

## After Installation

```bash
# Check what's installed
devsetup check

# Install more tools
devsetup add terraform
devsetup add k9s

# See your favorites (customizable startup display)
fav
favedit  # customize it
```

## Plugin System

Drop additional tool repos in `~/my-tools/` with a `.devtools-plugin` marker file, and they'll be auto-discovered:

```
~/my-tools/
├── hubers-devtools-system/     ← this repo (master)
├── some-plugin/                ← auto-discovered
│   ├── .devtools-plugin        ← marker file
│   └── setup.sh                ← plugin setup
```

Run `./setup.sh` again and it will offer to set up new plugins.

## Requirements

- macOS or Linux
- Internet connection (for Homebrew packages)

## Documentation

See the `docs/` folder:
- `docs/GIT-MULTI-ACCOUNT.md` - Multiple GitHub accounts setup
- `docs/QUICK-REFERENCE.md` - Command cheat sheet
- `docs/ASDF-GUIDE.md` - Version management for terraform, node, etc.

## Structure

```
hubers-devtools-system/
├── setup.sh              ← Run this! Main entry point
├── lib/setup-utils.sh    ← Shared utilities
├── bin/devsetup          ← Tool manager command
├── config/tools.yaml     ← Tool definitions (113 tools)
├── terminal-config/      ← ZSH configuration
├── git-things/           ← Git multi-account setup
└── docs/                 ← Documentation
```

## License

MIT - Use it, fork it, make it yours.
