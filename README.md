# Hubers Dev Tools

A modular dev environment framework for macOS (Linux coming soon). One command sets up your entire development environment with modern CLI tools, ZSH configuration, and a plugin system for extensions.

## Features

- **One-command setup** - `./setup.sh` handles everything, safe to re-run
- **Modern CLI tools** - eza, bat, fzf, ripgrep, delta, zoxide, and more
- **Beautiful terminal** - Powerlevel10k prompt with Oh-My-Zsh
- **Tool management** - `devsetup` command to install/manage 113+ dev tools
- **Plugin system** - Auto-discovers extensions in `~/my-tools/`
- **Test suite** - Verify your setup with `devsetup test`
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

# Verify everything works
devsetup test
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

# Run verification tests
devsetup test
```

## Testing Your Setup

The framework includes a test suite to verify everything is configured correctly:

```bash
devsetup test           # Run all tests (56 checks)
devsetup test path      # Check PATH configuration only
devsetup test tools     # Check core tools only
devsetup test config    # Check config preservation only
```

**Test categories:**
- `path` - PATH configuration, devsetup availability
- `aliases` - Core aliases and functions defined
- `tools` - Required CLI tools installed
- `favorites` - Favorites system working
- `plugins` - Plugin detection and loading
- `config` - Configuration file preservation

**When to run tests:**
- After initial setup
- After adding new tools or aliases
- After system updates
- When troubleshooting issues

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

## Personal Customizations

Your personal settings go in `~/.zshrc_local` - this file is **never overwritten** by updates:

```bash
# Edit your personal config
vim ~/.zshrc_local

# Re-run setup (your customizations are preserved)
cd ~/my-tools/hubers-devtools-system/terminal-config
./INSTALL.sh
```

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection (for Homebrew packages)

Linux support coming soon.

## Documentation

See the `docs/` folder:
- `docs/GIT-MULTI-ACCOUNT.md` - Multiple GitHub accounts setup
- `docs/QUICK-REFERENCE.md` - Command cheat sheet
- `docs/ASDF-GUIDE.md` - Version management for terraform, node, etc.

Or use the built-in help:
```bash
th <TAB>       # Browse all help topics
devsetup help  # Tool management help
```

## Structure

```
hubers-devtools-system/
├── setup.sh              ← Run this! Main entry point
├── lib/
│   ├── setup-utils.sh    ← Shared utilities
│   └── test-utils.sh     ← Test framework
├── bin/devsetup          ← Tool manager command
├── config/tools.yaml     ← Tool definitions (113 tools)
├── tests/                ← Test suite
│   ├── test-runner.sh    ← Test orchestrator
│   └── tests.d/          ← Individual test modules
├── terminal-config/      ← ZSH configuration
├── git-things/           ← Git multi-account setup
└── docs/                 ← Documentation
```

## Contributing

When adding new features:
1. Add the feature to the appropriate toolkit file
2. Update tests in `tests/tests.d/` if needed
3. Run `devsetup test` to verify
4. Update documentation

## License

MIT - Use it, fork it, make it yours.
