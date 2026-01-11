# Git History Cleanup Tools

Tools for removing sensitive data from git history.

## Tools Overview

### 1. git-filter-repo (Recommended)

Modern, fast replacement for `git filter-branch`. Install via Homebrew.

```bash
brew install git-filter-repo
```

### 2. BFG Repo Cleaner

Java-based tool, very fast for large repos.

```bash
brew install bfg
```

### 3. Fresh Start (Simplest)

For small repos, just reinitialize git.

---

## TODO for Sonnet

Expand this doc with:

1. **git-filter-repo examples**
   - Replace text patterns: `--replace-text`
   - Remove files: `--path` with `--invert-paths`
   - Remove large files by size
   - Strip credentials/secrets patterns

2. **BFG examples**
   - Remove files by name
   - Replace text in all files
   - Strip large blobs

3. **Fresh start procedure**
   - Full steps for backup, reinit, force push
   - When to use vs other methods

4. **Pre-commit hooks**
   - git-secrets for preventing secrets in commits
   - detect-secrets tool

5. **Recovery scenarios**
   - What if someone already cloned?
   - GitHub cache invalidation
   - Rotating exposed credentials

6. **Add to setup.sh**
   - Consider adding git-filter-repo to Homebrew packages
   - Consider adding git-secrets for prevention
