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

---

<!--
================================================================================
ADDITIONAL CLAUDE.MD FEATURES
================================================================================
The sections below show what else you can add to CLAUDE.md files.
Uncomment and customize any that are useful.
See ~/hubers-docs/tools/CLAUDE-MD-GUIDE.md for full documentation.
================================================================================
-->


<!--
## On Session Start

At the start of each session, check if `NEXT-SESSION-NOTES.md` exists.
If so, read it first for context from the last session.
-->


<!--
## On Session End

When Mark says "done for the day", "wrap up", "save this", or similar:
1. Update NEXT-SESSION-NOTES.md with what was done and what's next
2. Ask if Mark wants to commit changes
3. Keep it brief - bullet points and tables
-->


<!--
## Git Commits

- Use conventional commits (feat:, fix:, docs:, chore:)
- Always ask before committing
- Never push without asking
- Test with INSTALL.sh before committing zsh changes
-->


<!--
## Common Tasks

When Mark says "test it":
1. Run ./terminal-config/INSTALL.sh
2. Check for errors
3. Report results

When Mark says "add a new alias":
1. Ask what the alias should do
2. Add to appropriate .zsh file in terminal-config/home/.zsh/
3. Run INSTALL.sh
4. Test in new terminal
-->


<!--
## Do NOT Do

- Never edit ~/.zshrc directly (use source files)
- Never edit ~/.zsh/* directly (use source files)
- Don't commit without running INSTALL.sh first
- Don't add features without asking about location
-->


<!--
## Vocabulary

- "devtools" = this system (hubers-devtools-system)
- "extensions" = plugins that add functionality
- "favorites" = the favorites.zsh bookmark system
- "tunnel" = SSH tunnel to work Mac (separate repo)
-->
