# 🔍 FZF - Fuzzy Finding Everything!

## What is FZF?

Fast fuzzy finder for interactive searching.

## Key Bindings

```bash
Ctrl+R              # Search command history
Ctrl+T              # Find files
Alt+C               # cd into directory
Tab                 # Smart completion with previews
```

## Tab Completion (90+ Commands!)

```bash
ssh <TAB>           # SSH hosts with previews
docker ps <TAB>     # Containers with details
kubectl get <TAB>   # Pods with status
git log <TAB>       # Commits with diffs
npm run <TAB>       # Scripts from package.json
```

## Examples

```bash
# Find and edit file
vim $(fzf)

# Search history
h                   # Opens FZF search

# Smart completion
ssh <TAB>           # Shows all hosts
docker ps <TAB>     # Shows all containers
```

## Your Setup

You have 90+ FZF completions with previews already configured!

Try:
- `ssh <TAB>`
- `docker ps <TAB>`
- `kubectl get pods <TAB>`
- `git log <TAB>`

See main FZF guide for complete documentation on adding your own completions.
