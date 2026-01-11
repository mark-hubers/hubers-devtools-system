# GitHub CLI Complete Guide - 2025 Edition

**Updated:** December 17, 2025  
**For:** macOS, Linux, WSL2  
**Includes:** Latest features, extensions, and fzf-powered toolkit

---

## 🎯 What is GitHub CLI?

`gh` is GitHub's official command-line tool that brings GitHub to your terminal. Think of it as GitHub in your terminal - no more switching to the browser!

**What makes it powerful:**
- 🔐 Secure OAuth authentication (no PATs to manage)
- 🚀 Full GitHub workflow from terminal
- 🔌 Extensible with 300+ community extensions
- 🎯 Works with forks, PRs, issues, actions, gists, and more
- 🌐 API access built-in

---

## 📦 Installation

### macOS:
```bash
brew install gh
```

### Linux/WSL2:
```bash
# Debian/Ubuntu
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# or using snap
sudo snap install gh
```

### Verify:
```bash
gh --version
```

---

## 🔐 Authentication (New in 2025!)

### First Time Setup:
```bash
gh auth login --clipboard
```

**New in 2025:** The `--clipboard` flag automatically copies the OAuth code!

**Steps:**
1. Select GitHub.com
2. Select HTTPS or SSH
3. Authenticate: Browser opens
4. Code is auto-copied to clipboard
5. Paste and authorize
6. Done!

### Check Status:
```bash
gh auth status
```

### Multiple Accounts:
```bash
gh auth switch
```

---

## 🚀 Enhanced Toolkit Commands

After installing the toolkit, you get 40+ easy commands:

### 📋 Repository Operations:
```bash
ghclone        # Clone with fzf selection
ghrepos        # Browse your repos (fzf)
ghopen         # Open in browser
ghcreate       # Create new repo
ghfork         # Fork repo
ghinfo         # Show current repo info
```

### 🔀 Pull Requests:
```bash
ghprs          # Browse PRs with fzf (AWESOME!)
ghpr           # Create PR from current branch
ghprstatus     # Check PR status
ghprco         # Checkout PR with fzf
ghreview       # Review PR
```

### 🐛 Issues:
```bash
ghissues       # Browse issues with fzf
ghissue        # Create issue
ghdev          # Create branch from issue (NEW 2025!)
```

### 🌿 Branches:
```bash
ghbranch       # Switch branches with fzf fuzzy find
ghnewbranch    # Create new branch
```

### 🔄 Workflows (Actions):
```bash
ghruns         # Browse workflow runs with fzf
ghwatch        # Watch current run live
ghlogs         # View workflow logs
```

### 📝 Gists:
```bash
ghgists        # Browse your gists with fzf
ghgist <file>  # Create gist from file
```

---

## 💡 Real Workflows

### Morning Routine:
```bash
ghprstatus     # Check your PRs
ghissues       # Review issues
ghnotify       # Check notifications
```

### Feature Development:
```bash
# 1. Create issue
ghissue

# 2. Create branch from issue (NEW 2025!)
ghdev

# 3. Work on feature...
# ...

# 4. Commit, push, and create PR
ghpush "feat: add cool feature"
```

### PR Review Workflow:
```bash
# 1. Browse PRs
ghprs

# 2. In fzf menu, select PR
# 3. Choose action: [v]iew | [c]heckout | [d]iff | [m]erge

# Or direct:
ghprco 123     # Checkout PR #123
gh pr diff     # View diff
gh pr review   # Leave review
gh pr merge    # Merge when ready
```

### Quick Bug Fix:
```bash
ghbranch       # Switch to main (fzf fuzzy find)
git pull
ghnewbranch hotfix/bug-123
# ... fix bug ...
ghpush "fix: resolve bug #123"
```

---

## 🎯 What's New in 2025

### 1. **Issue Development Workflow**
Create and checkout branches directly from issues:
```bash
gh issue develop 123 --checkout
# Creates branch named: 123-issue-title
# Automatically links PR to issue
```

Or with toolkit:
```bash
ghdev 123
```

### 2. **Triangular Workflow Support**
Better handling of forks:
```bash
# Clone a fork
gh repo clone yourusername/somerepo

# Automatically sets upstream!
# No more manual: git remote add upstream ...
```

### 3. **Release Attestations** (Security!)
Verify releases cryptographically:
```bash
gh release verify v1.2.3
gh release verify-asset my-asset.zip
```

### 4. **Clipboard OAuth** (`--clipboard`)
No more copy-paste fumbling during auth:
```bash
gh auth login --clipboard
# Code automatically copied!
```

### 5. **Enhanced Accessibility**
Screen reader support and better terminal output.

---

## 🔌 Must-Have Extensions

Extensions add superpowers to `gh`!

### Install Extensions:
```bash
# Interactive browser (NEW 2025!)
gh extension browse

# Or direct install:
gh extension install OWNER/REPO
```

### Top Extensions:

#### 1. **gh-dash** - Interactive Dashboard
```bash
gh extension install dlvhdr/gh-dash
gh dash
```
Beautiful TUI dashboard for PRs and issues!

#### 2. **gh-branch** - Branch Switcher
```bash
gh extension install mislav/gh-branch
gh branch
```
Fuzzy find branches with preview!

#### 3. **gh-eco** - Repository Insights
```bash
gh extension install jrnxf/gh-eco
gh eco
```
See repo statistics and insights.

#### 4. **gh-copilot** - AI Assistant (if you have Copilot)
```bash
gh extension install github/gh-copilot
gh copilot suggest "deploy to production"
```

#### 5. **gh-skyline** - 3D Contribution Graph
```bash
gh extension install github/gh-skyline
gh skyline 2025
```
Generate 3D printable contribution graph!

### Browse All Extensions:
```bash
ghext          # Interactive browser
ghextlist      # List installed
```

---

## 🎨 Integration with Your Workflow

### With Git:
```bash
# Git for local operations
git commit -m "feat: add feature"
git push

# gh for GitHub operations
gh pr create
gh pr merge
```

### With Terraform (Your Use Case!):
```bash
# Clone infrastructure repo
ghclone myorg/terraform-infra

# Create issue for change
ghissue

# Create branch from issue
ghdev

# Make changes...
terraform plan
terraform apply

# Push and create PR
ghpush "feat: add new environment"
```

### With CI/CD:
```bash
# Watch your workflow
ghwatch

# Check logs if failed
ghlogs

# Re-run if needed
gh run rerun
```

---

## 📊 API Access

The `gh api` command gives you direct API access:

### Examples:
```bash
# Get your user info
gh api user

# List org repos
gh api orgs/myorg/repos

# With jq for filtering
gh api orgs/myorg/repos --jq '.[].name'

# POST request
gh api repos/owner/repo/issues -f title="Bug" -f body="Found a bug"
```

### Your Scripts Can Use gh:
```bash
#!/bin/bash
# Get all repo names in org
repos=$(gh api orgs/your-org/repos --jq '.[].name')
```

---

## 🔧 Advanced Features

### 1. **Default Repository**
Set default repo for current directory:
```bash
gh repo set-default
```

Now commands work without `-R owner/repo`!

### 2. **Aliases**
Create custom commands:
```bash
# Create alias
gh alias set pv 'pr view'

# Use it
gh pv 123
```

### 3. **Configuration**
```bash
# Edit config
gh config set editor code
gh config set git_protocol https
gh config set pager less

# View config
gh config list
```

### 4. **Environment Variables**
```bash
export GH_TOKEN="ghp_xxx"           # Use specific token
export GH_REPO="owner/repo"         # Default repo
export GH_BROWSER="firefox"         # Browser to use
export EDITOR="code"                # Editor for gh
```

---

## 💡 Pro Tips

### 1. **Tab Completion**
Add to your `.zshrc`:
```bash
# GitHub CLI completion (if not using our toolkit)
eval "$(gh completion -s zsh)"
```

### 2. **Quick PR Checkout**
```bash
# Checkout PR by number
gh pr checkout 123

# Or with fzf (toolkit)
ghprco
```

### 3. **Search Everything**
```bash
gh search repos "language:python stars:>1000"
gh search issues "is:open label:bug"
gh search code "TODO" --repo owner/repo
```

### 4. **Watch Live**
```bash
# Watch workflow run live
gh run watch

# Watch PR checks
gh pr checks --watch
```

### 5. **Batch Operations**
```bash
# Close multiple issues
for i in 10 11 12; do
  gh issue close $i
done
```

---

## 🎓 Learning Path

### Day 1: Basics
```bash
gh auth login
gh repo list
gh repo clone owner/repo
gh pr status
```

### Day 2: Interactive Tools
```bash
ghprs          # Browse PRs
ghissues       # Browse issues
ghbranch       # Switch branches
```

### Day 3: Workflows
```bash
ghissue        # Create issue
ghdev          # Branch from issue
ghpush "msg"   # Commit + push + PR
```

### Day 4: Advanced
```bash
gh api user    # API access
ghext          # Install extensions
gh run watch   # Watch workflows
```

---

## 📚 Common Commands Quick Reference

| Task | Command | Toolkit Shortcut |
|------|---------|------------------|
| Login | `gh auth login` | `ghlogin` |
| Clone repo | `gh repo clone` | `ghclone` |
| Create PR | `gh pr create` | `ghpr` |
| List PRs | `gh pr list` | `ghprs` |
| Create issue | `gh issue create` | `ghissue` |
| Browse issues | `gh issue list` | `ghissues` |
| Open in browser | `gh browse` | `ghopen` |
| View workflows | `gh run list` | `ghruns` |
| View repo | `gh repo view` | `ghrepo` |
| Branch from issue | `gh issue develop` | `ghdev` |

---

## 🐛 Troubleshooting

### "gh: command not found"
```bash
# Install gh first
brew install gh  # macOS
```

### "Not authenticated"
```bash
gh auth login --clipboard
```

### "Permission denied"
```bash
# Check auth
gh auth status

# Re-authenticate
gh auth refresh
```

### "Rate limit exceeded"
```bash
# Check your rate limit
gh api rate_limit

# Use authenticated requests (they have higher limits)
gh auth status
```

### Extensions not working
```bash
# Update extensions
gh extension upgrade --all

# List to see status
gh extension list
```

---

## 🎊 Why This Toolkit is Better

### Before (Plain gh):
```bash
gh pr list
# View PR 123
gh pr view 123
# Want to checkout? Type again
gh pr checkout 123
```

### After (With Toolkit):
```bash
ghprs
# fzf menu appears
# Select PR
# Choose: [c]heckout
# Done!
```

**Way faster!** 🚀

---

## 📖 Resources

- Official Docs: https://cli.github.com/manual/
- Extensions: https://github.com/topics/gh-extension
- Our Toolkit: Type `ghhelp`

---

## 🎯 Next Steps

1. **Install gh**: `brew install gh` (macOS)
2. **Authenticate**: `ghlogin`
3. **Install toolkit**: Copy to `~/.zsh/github-cli-toolkit.zsh`
4. **Add to .zshrc**: `source ~/.zsh/github-cli-toolkit.zsh`
5. **Test**: `ghprs`
6. **Install extensions**: `ghext`

---

**Welcome to GitHub from your terminal!** 🐙✨
