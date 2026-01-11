# Project Context for Claude

## What This Project Is

hubers-devtools-system is the MASTER dev environment setup for macOS/Linux.
- Main entry: `./setup.sh`
- Installs: Homebrew, ZSH, Oh-My-Zsh, Powerlevel10k, CLI tools, terminal config
- Has plugin discovery system for sibling projects in ~/my-tools/

## Plugin Ecosystem

This is the **parent project**. Plugins are discovered in `~/my-tools/`:

| Plugin | Description |
|--------|-------------|
| `hubers-devtools-work-tunnel` | SSH tunnel to work Mac with SOCKS proxy |
| `hubers-devtools-streamdeck` | Stream Deck and BetterTouchTool config |

### Plugin Requirements
- Must have `.devtools-plugin` marker file (NAME, DESCRIPTION, VERSION)
- Must have `setup.sh` entry point
- Should source `lib/setup-utils.sh` for shared utilities
- Shell extensions go in `extensions/*.zsh` → `~/.zsh/extensions.d/`

## Documentation Sync

**IMPORTANT:** This project has a documentation mirror in `~/hubers-docs/` (private repo).

When making significant changes:
1. Update relevant docs in this repo's `docs/` folder
2. Sync summaries/personal notes to `~/hubers-docs/devtools/`
3. Keep the central project index updated: `~/hubers-docs/projects/index.md`

### What Goes Where
| This Repo (PUBLIC) | hubers-docs (PRIVATE) |
|-------------------|----------------------|
| Generic how-to guides | Personal setup details |
| Plugin architecture | Actual config values |
| Tool documentation | Machine-specific notes |

## Key Architecture

### Shared Library
- `lib/setup-utils.sh` - shared utilities for all setup scripts
- Colors, status messages, idempotent helpers, plugin discovery
- Plugins should source this for consistent output

### Extension System
- Shell extensions go in `~/.zsh/extensions.d/*.zsh`
- Auto-loaded by `~/.zshrc`
- Each plugin installs its own extensions there

## Files Modified on User's System

- `~/.zshrc` - has extension loader for ~/.zsh/extensions.d/
- `~/.zsh/extensions.d/` - where plugins install their aliases
- `~/.gitconfig*` - multi-account git setup (optional)

## See Also

- `docs/GIT-MULTI-ACCOUNT.md` - folder-based git identity switching
- `docs/GIT-HISTORY-CLEANUP.md` - removing sensitive data from git
- `~/hubers-docs/projects/index.md` - central index of all projects
