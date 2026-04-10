# GitHub CLI Toolkit — Command Reference

**File:** `terminal-config/home/.zsh/github-cli-toolkit.zsh`
**Lines:** ~2900
**Dependencies:** `gh` (required), `jq` (required), `fzf` (optional), `op` (optional)

---

## Architecture

```
                    User Commands
                         |
    +--------------------+--------------------+
    |                    |                    |
  ghvar              ghsecret             ghteam
  list/get/set       list/set             list/show
  delete/import      delete               add-member/remove-member
                                          set-repo/fix
    |                    |                    |
    +--------------------+--------------------+
                         |
               Shared Infrastructure
    +--------------------------------------------+
    | _gh_parse_target()  — org/repo detection   |
    | _gh_scoped()        — admin vs regular gh  |
    | _gh_admin()         — admin token wrapper  |
    | _gh_handle_error()  — 401/403/404/422/rate |
    | _gh_secrets_api_path() — secrets endpoint  |
    | _gh_check()         — gh + auth validation |
    | _gh_require_jq()    — jq dependency check  |
    +--------------------------------------------+
                         |
              GitHub REST API (via gh cli)
```

## Target Resolution

Commands accept a positional `target` argument. The presence of `/` determines scope:

```
"alvaria-bu"          -> org scope   -> /orgs/alvaria-bu/actions/...
"alvaria-bu/my-repo"  -> repo scope  -> /repos/alvaria-bu/my-repo/actions/...
(omitted, in git repo)-> repo scope  -> auto-detect from git remote
```

Guards:
- Rejects targets with 2+ slashes
- Trims whitespace
- Falls back to git remote when no target given
- Clear error when not in a git repo and no target specified

## Admin Token

Org-level write operations use a classic PAT stored at `~/.gh-admin-token`.

```
~/.gh-admin-token          <- chmod 600, contains ghp_xxx
     |
  _gh_admin()              <- reads file, sets GH_TOKEN= per command
     |
  _gh_scoped()             <- routes: org scope -> _gh_admin, repo -> gh
```

Required scope: `admin:org` (classic PAT only — fine-grained PATs do not support this).
Auto-fixes permissions if not 600.

---

## Commands

### ghvar — Actions Variables

| Command | Description | Admin Token |
|---------|-------------|-------------|
| `ghvar list [target] [--json]` | List all variables | Org: yes |
| `ghvar get <name> [target] [--json]` | Show variable details | Org: yes |
| `ghvar set <name> <value> [target] [--visibility ..] [--dry-run]` | Create or update | Org: yes |
| `ghvar delete <name> [target] [--dry-run]` | Delete variable | Org: yes |
| `ghvar import <file> <target> [--visibility ..] [--dry-run]` | Bulk set from file | Org: yes |

**Import file format:**
```
# Comments and blank lines are ignored
AWS_REGION=us-east-1
DEPLOY_ENV=staging
GH_ORG_NAME=alvaria-bu
```

**Idempotent:** `set` tries PATCH (update) first, falls back to POST (create) on 404.

### ghsecret — Actions Secrets

| Command | Description | Admin Token |
|---------|-------------|-------------|
| `ghsecret list [target] [--json]` | List secret names (values never shown) | Org: yes |
| `ghsecret set <name> [target] [--visibility ..] [--dry-run]` | Create or update (prompts for value) | Org: yes |
| `ghsecret delete <name> [target] [--dry-run]` | Delete with confirmation | Org: yes |

Secret values are never returned by the GitHub API.
`ghsecret set` wraps `gh secret set` which handles libsodium encryption.

### ghteam — Team Management

| Command | Description | Admin Token |
|---------|-------------|-------------|
| `ghteam list <org> [--json]` | List teams with member/repo counts | Yes |
| `ghteam show <org> <team> [--json] [--no-members] [--no-repos]` | Full team detail | Yes |
| `ghteam add-member <org> <team> <user> [--role ..] [--dry-run]` | Add or update member | Yes |
| `ghteam remove-member <org> <team> <user> [--dry-run]` | Remove with confirmation | Yes |
| `ghteam set-repo <org> <team> <repo> <perm> [--dry-run]` | Set repo access level | Yes |
| `ghteam fix <org> <team> [--parent ..] [--description ..] [--dry-run]` | Fix orphaned teams | Yes |

Permissions for `set-repo`: `pull`, `triage`, `push`, `maintain`, `admin`

### Utilities

| Command | Description |
|---------|-------------|
| `ghdoctor` / `ghd` | Check dependencies + auth health |
| `ghhelp` | Full command reference |
| `ghconfig` | Show current GitHub configuration |
| `ghtoken-check` | Verify token validity + rate limit |

### Multi-Account (Pre-existing)

| Command | Description |
|---------|-------------|
| `ghlist` | List all configured gh accounts |
| `ghadd` | Add account (guided wizard) |
| `ghswitch` | Switch between accounts (fzf) |
| `ghauto` | Auto-switch based on repo owner |
| `ghwho` | Show current vs required account |
| `gh-as <acct> <cmd>` | Run command as specific account |

---

## Global Flags

| Flag | Supported By | Description |
|------|-------------|-------------|
| `--json` | list, get, show | Machine-readable output |
| `--dry-run` | set, delete, import, add-member, remove-member, set-repo, fix | Show what would happen |
| `--visibility` | set, import (org scope) | all, private, or selected |
| `--repos` | set (with --visibility selected) | Comma-separated repo names |
| `--no-members` | ghteam show | Skip member listing |
| `--no-repos` | ghteam show | Skip repo listing |

---

## Error Handling

All commands use `_gh_handle_error()` which detects:

| HTTP Status | Message |
|-------------|---------|
| 401 | Authentication failed — token expired or invalid |
| 403 (rate limit) | Rate limited — wait and retry |
| 403 (other) | Permission denied — admin token scope |
| 404 | Not found — check target name |
| 422 | Validation error — shows API detail |

---

## Security Notes

1. Admin token is read via `$(<file)` (zsh built-in, no subprocess)
2. Token is scoped per-command via `GH_TOKEN=xxx gh ...` (not exported)
3. File permissions auto-fixed to 600 if wrong
4. Secret values never echoed to terminal (`read -s`)
5. Secret values piped to `gh secret set` (not passed as arguments)
6. Destructive operations require confirmation or `--dry-run`

---

## CI

GitHub Actions workflow at `.github/workflows/test.yml`:
- Runs on push to toolkit or test files
- Matrix: macOS + Ubuntu
- Checks: `zsh -n` syntax + `test-runner.sh github`

---

*Last updated: 2026-04-09*
