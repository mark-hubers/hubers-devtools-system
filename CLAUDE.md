# Claude Code Guidelines for hubers-devtools-system

## Critical: Never Edit Installed Files Directly

**DO NOT edit these files directly:**
- `~/.zshrc`
- `~/.zsh/*.zsh`
- `~/.zsh/extensions.d/*.zsh`

**INSTEAD, edit the source files in the repo:**
- `terminal-config/home/.zshrc`
- `terminal-config/home/.zsh/*.zsh`

**Then run the installer to apply changes:**
```bash
cd ~/my-tools/hubers-devtools-system/terminal-config
./INSTALL.sh
```

**Then test in a new terminal** (not just `source ~/.zshrc`).

## Why This Matters

1. Edits to `~/.zshrc` get overwritten when INSTALL.sh runs
2. Testing via INSTALL.sh ensures changes work on fresh install
3. Source files in repo are the single source of truth
4. Changes are tracked in git

## Project Structure

```
hubers-devtools-system/
├── terminal-config/
│   ├── INSTALL.sh          ← Run this to apply changes
│   └── home/
│       ├── .zshrc          ← Source file (edit this)
│       └── .zsh/
│           ├── favorites.zsh
│           ├── network-toolkit.zsh
│           └── ...
├── lib/
│   └── setup-utils.sh      ← Shared utilities for all repos
├── bin/
│   └── devsetup            ← Tool management CLI
└── setup.sh                ← Main setup (runs terminal-config + plugins)
```

## Extensions (Plugins)

Extensions like work-tunnel are installed to `~/.zsh/extensions.d/`.

**To update an extension:**
1. Edit the source in the plugin repo (e.g., `hubers-devtools-work-tunnel/extensions/work-tunnel.zsh`)
2. Run the plugin's setup.sh OR manually reinstall:
   ```bash
   sed "s|__WORK_SETUP_DIR__|/path/to/plugin|g" extensions/work-tunnel.zsh > ~/.zsh/extensions.d/work-tunnel.zsh
   ```

## ZSH Scripting Standards

All scripts use `#!/bin/zsh` (not bash). Key differences:
- `read "var?prompt"` instead of `read -p "prompt" var`
- `read -k 1` for single character input
- `${0:a:h}` for script directory (instead of `BASH_SOURCE`)
- Avoid reserved variable names: `status`, `path`, `prompt`

## Testing Changes

After editing source files:
```bash
# 1. Run installer
cd ~/my-tools/hubers-devtools-system/terminal-config && ./INSTALL.sh

# 2. Test in new terminal or:
zsh -c 'source ~/.zshrc' 2>&1 | grep -i "error\|parse"

# 3. If clean, open new terminal to verify
```
