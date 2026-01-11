# 🎯 Git Workflow & Shortcuts

## Git Aliases

```bash
gs              # git status
ga .            # git add .
gc -m "msg"     # git commit
gp              # git push
gpl             # git pull
gd              # git diff
gco branch      # git checkout
gb              # git branch
gl              # git log (pretty)
```

## Git Functions

```bash
git-undo        # Undo last commit (keep changes)
git-wip         # Save work in progress
git-cleanup     # Delete merged branches
```

## Examples

```bash
# Quick workflow
gs              # Check status
ga .            # Stage all
gc -m "feat: add new feature"
gp              # Push

# Save WIP
git-wip         # Commits with timestamp

# Undo mistake
git-undo        # Undo last commit
```

## Lazygit (if installed)

```bash
lg              # Opens lazygit TUI
lazg            # Same thing
```

See [DEV-UTILITIES.md](DEV-UTILITIES.md) for lazygit guide.
