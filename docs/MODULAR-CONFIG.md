# Modular Shell Configuration

Your shell config is split into modular `.d` directories for easy management.

## Directory Structure

```
~/.zsh/
├── aliases.d/          # Shell aliases
│   ├── _devtools_*.zsh # Managed by devsetup (don't edit)
│   └── my-custom.zsh   # YOUR aliases (never touched)
│
├── functions.d/        # Shell functions
│   ├── _devtools_*.zsh # Managed by devsetup (don't edit)
│   └── my-custom.zsh   # YOUR functions (never touched)
│
├── path.d/             # PATH additions
│   ├── _devtools_*.zsh # Managed by devsetup (don't edit)
│   └── my-custom.zsh   # YOUR paths (never touched)
│
└── ... (other toolkit files)
```

## The Rules

| File Pattern | Who Manages | Safe to Edit? |
|--------------|-------------|---------------|
| `_devtools_*.zsh` | `devsetup sync` | NO - will be overwritten |
| `my-custom.zsh` | You | YES - never touched |
| Any other `*.zsh` | You | YES - never touched |

## Managed Files (_devtools_*)

These are synced from the devtools repo when you run `devsetup sync`:

### aliases.d/
| File | Contents |
|------|----------|
| `_devtools_k8s.zsh` | kubectl aliases (k, kg, kgp, kd, etc.) |
| `_devtools_docker.zsh` | docker aliases (d, dc, dps, dexec, etc.) |
| `_devtools_git.zsh` | git aliases (g, gs, ga, gc, gp, gl, etc.) |
| `_devtools_modern-cli.zsh` | eza, bat, ripgrep, fd aliases |
| `_devtools_navigation.zsh` | .., ..., reload, zshconfig |

### functions.d/
| File | Contents |
|------|----------|
| `_devtools_utils.zsh` | myip, weather, notes, port, killport, serve, json, yaml, mkcd, extract |
| `_devtools_help.zsh` | tools(), termhelp(), th |
| `_devtools_fzf.zsh` | ff, fh, fif, fkill, fcd |
| `_devtools_git.zsh` | gcob, gwip, gunwip, gcom, gpush, gdiff |
| `_devtools_k8s.zsh` | kns, kctx, kex, klogs, kgetl, kwatch |
| `_devtools_ssh.zsh` | socks, forward, tunnels, push, pull, ssh-tips |
| `_devtools_transfer.zsh` | scpd, rget, rput, rsync-sync, rbrowse |

### path.d/
| File | Contents |
|------|----------|
| `_devtools_core.zsh` | VSCode, ~/bin, ~/.local/bin, devtools, krew |

## How to Update

### Update Managed Files
```bash
devsetup sync
```
This copies the latest `_devtools_*.zsh` files from the devtools repo to your `~/.zsh/` directories.

### Add Your Own Customizations
Edit `my-custom.zsh` in any directory:
```bash
# Add your own aliases
code ~/.zsh/aliases.d/my-custom.zsh

# Add your own functions
code ~/.zsh/functions.d/my-custom.zsh

# Add your own PATH entries
code ~/.zsh/path.d/my-custom.zsh
```

Or create any other `*.zsh` file (without `_devtools_` prefix):
```bash
# Create a project-specific file
code ~/.zsh/aliases.d/work-shortcuts.zsh
```

## Load Order

In `~/.zshrc`, the directories are sourced in this order:
1. `path.d/*.zsh` - PATH setup (loaded early)
2. `aliases.d/*.zsh` - Aliases
3. `functions.d/*.zsh` - Functions

Within each directory, files are loaded alphabetically.

## Adding New Functions/Aliases to Devtools

If you want to contribute a function or alias to the devtools system:

1. Edit the source file in the repo:
   ```
   ~/my-tools/hubers-devtools-system/terminal-config/home/.zsh/
   ├── aliases.d/_devtools_*.zsh
   ├── functions.d/_devtools_*.zsh
   └── path.d/_devtools_*.zsh
   ```

2. Run sync to deploy:
   ```bash
   devsetup sync
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   # or just: reload
   ```

## Testing

Run the test suite to verify everything is loaded:
```bash
devsetup test functions
```

Each function file has a self-test function (e.g., `_test_devtools_fzf`) that verifies its functions are defined.

## Troubleshooting

### Function/alias not working after sync
```bash
source ~/.zshrc
# or start a new terminal
```

### Check if file is being loaded
```bash
# See what's in aliases.d
ls -la ~/.zsh/aliases.d/

# Check if sourced (should see the file)
grep "aliases.d" ~/.zshrc
```

### Check which file defines something
```bash
# Find where an alias is defined
grep -r "alias ll=" ~/.zsh/

# Find where a function is defined
grep -r "^myip()" ~/.zsh/
```
