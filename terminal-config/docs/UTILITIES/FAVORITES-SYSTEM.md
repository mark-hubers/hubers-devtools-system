# ⭐ Favorites System - Customize Your Terminal Startup

Your customizable command reference display - shown at every terminal startup.

---

## 🎯 Quick Start

```bash
# View your favorites anytime
fav

# Edit your favorites list
favedit

# Quick add a single command
favadd "docker ps | List running containers"

# Disable startup display
favoff

# Re-enable startup display
favon

# Show with alias (same as fav)
dev-tools
```

---

## 📖 What Is This?

The favorites system is YOUR personalized command reference - a beautiful display of the commands YOU actually use, shown every time you open a terminal. Think of it as your personal cheat sheet.

### Why It's Useful

- **No more forgetting** that perfect command syntax
- **Faster than searching** docs or history
- **Customizable** - only show what YOU need
- **Two-column layout** - more info in less space
- **Categorized sections** - organize by topic

---

## 🚀 Basic Usage

### View Your Favorites

```bash
fav              # Show the display anytime
dev-tools        # Same command, shorter alias
```

The display shows:
- **Commands** in green (left column)
- **Descriptions** in white (right column)
- **Sections** in magenta (categories)
- Helpful reminders at top and bottom

### Edit Your Favorites

```bash
favedit          # Opens ~/.zsh/my-favorites.txt in your editor
```

Your default editor opens (vim, nano, vscode - whatever `$EDITOR` is set to).

### Quick Add a Command

```bash
favadd "kubectl get pods | List all K8s pods"
```

Appends directly to your file without opening an editor.

---

## 📝 File Format

### Location

Your favorites file: `~/.zsh/my-favorites.txt`

### Two-Column Format

The favorites use a special **two-column** format to show more commands in less space:

```
#= SECTION NAME
cmd1           | Description 1                 || cmd2        | Description 2
cmd3 <args>    | Description 3                 || cmd4        | Description 4
```

**Format breakdown:**
- `#=` creates a section header
- `#` alone is a comment (not shown)
- Commands use: `command | description || command | description`
- `||` separates left and right columns
- Empty lines are skipped

### Example File

```
#= NAVIGATION
bm <n>          | Jump to bookmark              || bm <n> .     | Save current dir
bms             | List bookmarks (fzf)          || bmedit       | Edit bookmarks
z <partial>     | Smart jump (zoxide)           || z -          | Previous dir
#
#= SSH & REMOTE
socks <host>    | SOCKS proxy                   || tunnels      | List active tunnels
forward 8080 hp | Port forward                  || tunnel-kill  | Kill all tunnels
push file h:~   | Upload file (rsync)           || pull h:f .   | Download file
#
#= GIT
lazygit         | Git terminal UI               || gs           | git status
gp              | git push                      || gpl          | git pull
gco <branch>    | checkout branch               || gcob <n>     | checkout -b new
```

---

## ⚙️ Commands Reference

| Command | Description |
|---------|-------------|
| `fav` | Show your favorites display |
| `dev-tools` | Same as `fav` (shorter alias) |
| `favedit` | Edit favorites in your editor |
| `favadd "cmd \| desc"` | Quick add a command |
| `favoff` | Disable startup display |
| `favon` | Enable startup display |

---

## 💡 Best Practices

### 1. Keep It Short

**Only add commands you ACTUALLY forget.** If you remember it, don't add it. A shorter list is more useful.

**Bad approach:**
```
#= GIT (too many)
gs              | git status
ga              | git add
gc              | git commit
gp              | git push
gpl             | git pull
gd              | git diff
...50 more commands...
```

**Good approach:**
```
#= GIT (just the tricky ones)
gundo           | Undo last commit (keep changes)
gwip            | Save WIP commit
gclean          | Remove untracked files
```

### 2. Use Sections Wisely

Group related commands under clear section headers:

```
#= NAVIGATION
...bookmarks and jumping...
#
#= SSH & REMOTE  
...remote server commands...
#
#= KUBERNETES
...k8s commands...
```

The `#` line creates visual spacing between sections.

### 3. Two-Column Layout

Take advantage of the two-column format:

```
# Instead of this (single column):
docker ps       | List containers
docker stop     | Stop container
docker logs     | View logs
docker exec     | Execute in container

# Do this (two columns):
docker ps       | List containers              || docker stop    | Stop container
docker logs     | View logs                    || docker exec    | Execute command
```

### 4. Include Arguments

Show the **pattern** of how to use commands:

```
# Good - shows usage pattern
bm <name>       | Jump to bookmark              || bm <name> .    | Save bookmark
socks <host>    | SOCKS proxy via host          || forward 8080   | Forward port

# Less useful - no usage hints
bm              | Bookmarks                     || socks          | Proxy
```

### 5. Cross-Reference Documentation

Point users to detailed docs for complex topics:

```
#= HELP & DOCS
th <TAB>        | Browse all help topics        || th iterm2      | iTerm2 + SSH guide
th git          | Git reference                 || th ssh         | SSH tunnels guide
```

---

## 🎨 Customization Tips

### Custom Sections

Create sections that match YOUR workflow:

```
#= MY DAILY ROUTINE
...commands you run every morning...
#
#= DEPLOYMENT
...your deployment workflow...
#
#= DEBUGGING
...troubleshooting commands...
```

### Company/Project Specific

Add your team's specific commands:

```
#= ACME PROJECT
deploy-staging  | Deploy to staging             || check-logs     | View app logs
db-tunnel       | Connect to prod DB            || cache-clear    | Clear Redis
```

### Quick Reference Links

Include helpful reminders:

```
#= USEFUL LINKS
wiki            | Company wiki: wiki.acme.com   || docs           | Project docs
jenkins         | CI: jenkins.acme.com          || grafana        | Metrics
```

---

## 🔧 Advanced Usage

### Edit Directly

You can edit the file directly without the command:

```bash
vim ~/.zsh/my-favorites.txt
code ~/.zsh/my-favorites.txt
nano ~/.zsh/my-favorites.txt
```

### Backup Your Favorites

Your favorites are just text - back them up:

```bash
cp ~/.zsh/my-favorites.txt ~/Dropbox/backup/
# or
cp ~/.zsh/my-favorites.txt ~/.dotfiles/
```

### Share with Team

Share your favorites file with teammates:

```bash
# Add to your dotfiles repo
cd ~/.dotfiles
cp ~/.zsh/my-favorites.txt terminal/
git add terminal/my-favorites.txt
git commit -m "Add my terminal favorites"
git push
```

### Temporary Disable

If the startup display becomes distracting during intensive work:

```bash
favoff           # Disable at startup

# You can still view anytime with:
fav
dev-tools
```

Later, re-enable:

```bash
favon            # Show at startup again
```

### Combine with motd

The old `motd` command still works and shows system stats. Use both:

```bash
motd             # Shows: alias count, SSH hosts, system info
fav              # Shows: your custom command favorites
```

---

## 🎯 Real-World Examples

### Example 1: DevOps Engineer

```
#= KUBERNETES
k9s             | K8s terminal UI               || kctx           | Switch context
kns             | Switch namespace              || kgp            | get pods
kl <pod>        | Pod logs                      || kex <pod>      | Exec into pod
#
#= AWS
awslogin        | AWS SSO login                 || awswho         | AWS identity
awslist         | List profiles                 || awsenv         | Show current env
#
#= DOCKER
docker ps       | List containers               || docker logs -f | Follow logs
docker exec -it | Enter container               || lazydocker     | Docker TUI
```

### Example 2: Web Developer

```
#= DEVELOPMENT
npm run dev     | Start dev server              || npm test       | Run tests
npm run build   | Build for prod                || npm run lint   | Lint code
#
#= GIT
lazygit         | Git UI                        || gs             | git status
gp              | git push                      || gpl            | git pull
#
#= DATABASE
db-connect      | Connect to local DB           || db-migrate     | Run migrations
db-seed         | Seed test data                || db-reset       | Reset DB
```

### Example 3: Minimal Power User

```
#= MUST REMEMBER
th <TAB>        | Browse help docs              || favedit        | Edit this list
bm proj .       | Save bookmark here            || z proj         | Jump to proj
h               | Search history                || extract file   | Extract any archive
#
#= SSH MAGIC
socks work      | Browse via work laptop        || tunnels        | Active tunnels
push file h:~   | Upload file                   || pull h:file .  | Download file
```

---

## 🆘 Troubleshooting

### "Command not found: favedit"

The favorites system isn't loaded. This means:

1. The installation didn't complete properly
2. Run: `source ~/.zshrc` to reload
3. Or check: `ls ~/.zsh/favorites.zsh` exists

### Favorites not showing at startup

Check if it's enabled:

```bash
ls ~/.zsh/.favorites_enabled
```

If file doesn't exist, run:

```bash
favon
```

### Changes not appearing

After editing, you need to open a new terminal or run:

```bash
fav              # Preview changes immediately
```

The display auto-updates each time you open a new terminal.

### Editor not working

Check your `$EDITOR` variable:

```bash
echo $EDITOR     # Should show: vim, nano, code, etc.
```

Set it if empty:

```bash
export EDITOR=vim       # or nano, or code
# Add to ~/.zshrc to make permanent
```

---

## 🔗 Related Commands

- `th <TAB>` - Browse all documentation topics
- `th dirs` - Learn about directory bookmarks
- `th fzf` - Learn about fuzzy finding
- `bmedit` - Edit directory bookmarks (similar concept)
- `motd` - Show system status (complements favorites)

---

## 📚 Further Reading

- See `docs/FAVORITES-SYSTEM.md` in the project root for development notes
- See `.zsh/favorites.zsh` for the implementation code
- All your customizations are in `~/.zsh/my-favorites.txt`

---

**💡 Pro Tip:** Start small! Add just 5-10 commands you actually forget. You can always add more later. A focused list is way more useful than trying to document everything.
