# Git Workflow & Recovery Guide

## TL;DR - Your Custom Commands

| Command | What it does |
|---------|--------------|
| `gsync` | Sync branch with latest main/master (rebase) |
| `gsync --step` | Same, but ask before each step |
| `gsync --merge` | Use merge instead of rebase |
| `gnew foo` | Create new branch from latest main |
| `gnew foo --step` | Same, step-by-step |
| `gbrecent` | Show recent branches by commit date |
| `gbhistory` | Show branches by checkout history |
| `gclean` | Delete merged branches |
| `gwip` | Quick "work in progress" commit |
| `gunwip` | Undo last WIP commit |

---

## Daily Commands (90% of your git work)

### Status & Info
```bash
gs                    # git status
glog                  # pretty log (30 commits)
gd                    # git diff (unstaged changes)
gd --staged           # diff staged changes
git log --oneline -10 # last 10 commits, compact
```

### Staging & Committing
```bash
ga .                  # git add . (stage all)
ga <file>             # stage specific file
gc -m "message"       # git commit -m
gcom "message"        # git add -A && commit (our alias)
gwip                  # quick WIP commit
```

### Branches
```bash
gb                    # list branches
gco <branch>          # checkout existing branch
gcob <name>           # checkout -b (new branch)
gnew <name>           # NEW: create from latest main
gbrecent              # NEW: see recent branches
gbd <branch>          # delete branch (with confirm)
gbD <branch>          # force delete (with confirm)
```

### Push & Pull
```bash
gp                    # git push
gpl                   # git pull
git push -u origin <branch>   # first push, set upstream
git push --force-with-lease   # safe force push (after rebase)
```

### Sync & Update
```bash
gsync                 # NEW: sync branch with main/master
gsync --merge         # use merge instead of rebase
gfb <branch>          # fetch and checkout remote branch
```

---

## Recovery & Troubleshooting

### "I need to undo my last commit"
```bash
# Keep changes staged (undo commit only)
git reset --soft HEAD~1

# Keep changes unstaged
git reset HEAD~1

# Discard changes completely (DANGEROUS)
git reset --hard HEAD~1
```

### "I messed up a file, want the last committed version"
```bash
# Restore single file to last commit
git checkout HEAD -- <file>

# Or with newer git:
git restore <file>

# Restore file from specific commit
git checkout <commit> -- <file>
```

### "I want to see what a file looked like before"
```bash
# Show file at specific commit
git show <commit>:<file>

# Show file from 3 commits ago
git show HEAD~3:<file>

# Show file from another branch
git show main:<file>
```

### "I committed to wrong branch"
```bash
# If NOT pushed yet:
git reset --soft HEAD~1       # undo commit, keep changes
gco <correct-branch>          # switch to right branch
gc -m "your message"          # commit there

# If already pushed:
# Create new branch from current, then reset original
git branch temp-save          # save current state
git reset --hard HEAD~1       # remove commit from wrong branch
gco <correct-branch>          # go to right branch
git cherry-pick temp-save     # apply the commit
git branch -d temp-save       # cleanup
```

### "I need to undo a pushed commit"
```bash
# Create a new commit that undoes the bad one (SAFE)
git revert <commit>

# Or revert last commit
git revert HEAD
```

### "My working directory is a mess, start fresh"
```bash
# Discard all unstaged changes (DANGEROUS)
git checkout -- .

# Or with newer git:
git restore .

# Discard everything including untracked files (VERY DANGEROUS)
git clean -fd
```

### "I want to save my changes temporarily"
```bash
git stash                     # stash changes
git stash list                # see stashes
git stash pop                 # restore and remove stash
git stash apply               # restore but keep stash
git stash drop                # delete stash
```

### "Rebase went wrong, abort!"
```bash
git rebase --abort            # cancel rebase, go back to before
```

### "Merge went wrong, abort!"
```bash
git merge --abort             # cancel merge, go back to before
```

### "I deleted a branch but need it back"
```bash
# Find the commit hash
git reflog

# Recreate branch at that commit
git checkout -b <branch-name> <commit-hash>
```

### "Show me what I did recently"
```bash
git reflog                    # all recent actions
git reflog --date=relative    # with timestamps
```

---

## Branch Workflow (Your 90% flow)

### Starting New Work
```bash
gnew feature-foo              # creates from latest main
# ... make changes ...
ga . && gc -m "feat: add foo"
git push -u origin feature-foo
# Create PR on GitHub
```

### While PR is Waiting, Start More Work
```bash
gnew feature-bar              # another branch from main
# If foo's PR merges, bar will get it via gsync later
```

### Before Merging PR (sync with main)
```bash
gsync                         # rebase onto latest main
git push --force-with-lease   # push rebased branch
```

### After PR Merges
```bash
gco main && gpl               # update local main
gclean                        # delete merged branches
```

---

## Commit Message Convention

```
type: short description

Types:
  feat:     New feature
  fix:      Bug fix
  docs:     Documentation
  style:    Formatting (no code change)
  refactor: Code change (no new feature or fix)
  test:     Adding tests
  chore:    Maintenance
```

---

## All Our Git Aliases & Functions

### Aliases (from oh-my-zsh + ours)
```bash
gs        # git status
ga        # git add
gc        # git commit
gp        # git push
gpl       # git pull
gd        # git diff
gco       # git checkout
gb        # git branch
glog      # git log --pretty
```

### Our Custom Functions
```bash
gsync              # Sync branch with main/master
gnew <name>        # New branch from latest main
gbrecent           # Recent branches by commit date
gbhistory          # Recent branches by checkout history
gcob <name>        # git checkout -b
gbd <name>         # Delete branch (confirm)
gbD <name>         # Force delete branch (confirm)
gfb <name>         # Fetch and checkout remote branch
gclean             # Delete merged branches
gwip [msg]         # WIP commit
gunwip             # Undo WIP commit
gcom "msg"         # git add -A && commit
gpush "msg"        # git add -A && commit && push
gdiff              # git diff with delta
```

---

## Quick Reference Card

```
DAILY WORK
  gs → status     gd → diff        glog → log
  ga . → stage    gc -m → commit   gp → push

BRANCHES
  gnew foo → new from main    gsync → update from main
  gco foo → switch            gbrecent → recent branches
  gcob foo → create+switch    gclean → delete merged

UNDO/RECOVER
  git reset --soft HEAD~1     # undo commit, keep staged
  git reset HEAD~1            # undo commit, keep unstaged
  git checkout HEAD -- file   # restore file
  git stash / git stash pop   # temp save/restore
  git rebase --abort          # cancel rebase
  git reflog                  # see recent actions
```

---

*Run `th git` anytime to see this guide*
