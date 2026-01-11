# ⭐ Favorites System

A customizable display of YOUR most important commands, shown at terminal startup.

## Quick Start

```bash
# See your favorites
fav

# Edit your favorites list
favedit

# Add a command quickly
favadd "docker ps | List running containers"

# Disable startup display (if it's too much)
favoff

# Re-enable startup display
favon
```

## How It Works

1. **At terminal startup**, your favorites are displayed
2. **Edit anytime** with `favedit` - opens in your editor
3. **Quick add** with `favadd "command | description"`
4. The file lives at `~/.zsh/my-favorites.txt`

## Editing Your Favorites

Run `favedit` to open the favorites file. It's simple text:

```
# ─── Section Header ───────────────────────────────────────────────
command1        | What it does
command2 <arg>  | Another command

# ─── Another Section ──────────────────────────────────────────────
more commands   | Description here
```

### Format Rules

- Lines starting with `#` are comments (not shown)
- Lines starting with `# ───` become section headers
- Commands use format: `command | description`
- Empty lines are skipped

### Example favorites.txt

```
# ╔════════════════════════════════════════════════════════════════╗
# ║  MY FAVORITE COMMANDS                                          ║
# ╚════════════════════════════════════════════════════════════════╝

# ─── Daily Shortcuts ──────────────────────────────────────────────
ll              | List files (detailed)
z <partial>     | Smart jump to directory
h               | Search command history

# ─── Git ──────────────────────────────────────────────────────────
gs              | git status
gp              | git push
lazygit         | Terminal git UI

# ─── Kubernetes ───────────────────────────────────────────────────
k9s             | Kubernetes dashboard
kctx            | Switch context
kns             | Switch namespace

# ─── Infrastructure ───────────────────────────────────────────────
tf plan         | Terraform plan
tf apply        | Terraform apply
devsetup check  | Check installed tools
```

## Commands

| Command | Description |
|---------|-------------|
| `fav` | Show your favorites |
| `favedit` | Edit favorites in your editor |
| `favadd "cmd \| desc"` | Quick add a command |
| `favoff` | Disable startup display |
| `favon` | Enable startup display |

## Tips

### Keep It Short!

Only add commands you **actually forget**. If you remember it, don't add it. A shorter list is more useful.

### Use Sections

Group related commands with section headers:

```
# ─── Docker ───────────────────────────────────────────────────────
docker ps       | List containers
docker logs -f  | Follow container logs
```

### Quick Add

Instead of editing the file, use quick add:

```bash
favadd "kubectl get pods | List all pods"
```

### Disable If Distracting

If you don't want favorites at startup:

```bash
favoff

# You can still see them anytime with:
fav
```

### Combine with motd

The old `motd` command still works and shows system stats:

```bash
motd    # Shows alias count, SSH hosts, etc.
fav     # Shows your custom favorites
```

## File Location

Your favorites file: `~/.zsh/my-favorites.txt`

You can edit it directly:

```bash
vim ~/.zsh/my-favorites.txt
# or
code ~/.zsh/my-favorites.txt
```

## Customizing the Display

The favorites system sources from `~/.zsh/favorites.zsh`. If you want to heavily customize the display format, you can edit that file.

## Backup Your Favorites

Your favorites file is just text. Back it up:

```bash
cp ~/.zsh/my-favorites.txt ~/Dropbox/backup/
```

Or add to your dotfiles repo!
