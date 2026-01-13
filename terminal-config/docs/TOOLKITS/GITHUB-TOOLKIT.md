# GitHub CLI Toolkit

Complete GitHub CLI toolkit with multi-account support.

## Quick Start

```bash
ghhelp          # Show all commands
ghlist          # List configured accounts
ghadd           # Add new account (guided)
ghtest          # Test current account
```

## Account Management

| Command | Description |
|---------|-------------|
| `ghlist` | List all configured accounts |
| `ghadd` | Add new account (personal/token/SSO/enterprise) |
| `ghtest` | Test current account connectivity |
| `ghremove` | Remove an account |
| `ghswitch` | Switch between accounts (fzf) |
| `ghauto` | Auto-switch based on repo owner |
| `ghwho` | Show current vs required account |
| `ghaccounts` | List accounts + owner mappings |
| `ghstatus` | Check authentication status |

## Adding Accounts

Run `ghadd` for guided setup:

```
1) Personal GitHub (github.com) - Web browser login
2) Personal GitHub (github.com) - Paste token
3) Work - GitHub Enterprise Cloud (SSO/SAML)
4) Work - GitHub Enterprise Server (self-hosted)
```

## Auto-Switch Setup

The `ghauto` command switches accounts based on repo owner.

**Configure mappings in `~/.zshrc_hubers`** (private, not in repo):

```zsh
# Add your org -> account mappings
GH_ACCOUNT_MAP+=(
  "my-work-org"    "my-work-username"
  "another-org"    "my-work-username"
)
```

## Repository Operations

| Command | Description |
|---------|-------------|
| `ghclone` | Clone repo (fzf selection) |
| `ghrepos` | Browse your repositories |
| `ghrepo` | View current repo |
| `ghopen` | Open repo in browser |
| `ghcreate` | Create new repository |
| `ghfork` | Fork repository |

## Pull Requests

| Command | Description |
|---------|-------------|
| `ghprs` | Browse PRs (fzf with preview) |
| `ghpr` | Create PR from current branch |
| `ghprstatus` | Check PR status |
| `ghprco` | Checkout PR (fzf selection) |
| `ghreview` | Review PR |

## Issues

| Command | Description |
|---------|-------------|
| `ghissues` | Browse issues (fzf) |
| `ghissue` | Create new issue |
| `ghdev` | Create branch from issue |

## Workflows

| Command | Description |
|---------|-------------|
| `ghruns` | Browse workflow runs |
| `ghwatch` | Watch current workflow |
| `ghlogs` | View workflow logs |

## Testing Your Setup

```bash
# Test current account
ghtest

# Expected output:
# 🧪 GitHub Account Test
# Testing account: your-username
#   API access:        ✅ your-username
#   User info:         ✅ Your Name <email>
#   Repo access:       ✅ Can list repos
#   Token scopes:      ✅ gist, read:org, repo
#   SSO/Org access:    ✅ org1, org2
```

## Troubleshooting

**"command not found"**
- Run: `source ~/.zshrc` or open new terminal

**Wrong account for repo**
- Run: `ghwho` to see mismatch
- Run: `ghauto` to auto-switch

**SSO not working**
- Run: `gh auth refresh -h github.com -s read:org`

## See Also

- `ghhelp` - Full command list
- `th github` - This documentation
