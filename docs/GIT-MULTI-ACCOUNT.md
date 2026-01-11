# Git Multi-Account Setup

Use multiple Git identities on one machine with automatic switching based on folder.

## How It Works

Git's `includeIf` directive loads different configs based on which folder you're in:

```
~/git/personal/     → personal@gmail.com
~/git/work-org/     → you@company.com
~/git/client-abc/   → contractor@client.com
```

Each folder can have its own:
- Name and email
- SSH key
- Git settings

## Folder Structure

```
~/git/
├── personal/           → Personal GitHub
├── work-org/           → Work GitHub Enterprise
├── client-project/     → Client's GitLab
└── open-source/        → Different identity for OSS
```

## Setup

### 1. Create SSH Keys

One key per account:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/git_personal -C "personal@gmail.com"
ssh-keygen -t ed25519 -f ~/.ssh/git_work -C "you@company.com"
```

Add public keys to each GitHub/GitLab account.

### 2. Create Override Configs

**~/.gitconfig_personal:**
```gitconfig
[user]
    name = your-username
    email = personal@gmail.com
[core]
    sshCommand = "ssh -i ~/.ssh/git_personal"
```

**~/.gitconfig_work:**
```gitconfig
[user]
    name = Your Name
    email = you@company.com
[core]
    sshCommand = "ssh -i ~/.ssh/git_work"
```

### 3. Add includeIf to Main Config

**~/.gitconfig:**
```gitconfig
# Default identity
[user]
    name = your-username
    email = personal@gmail.com
[core]
    sshCommand = "ssh -i ~/.ssh/git_personal"

# Override for work folder
[includeIf "gitdir:~/git/work-org/"]
    path = ~/.gitconfig_work

# Override for client folder
[includeIf "gitdir:~/git/client-project/"]
    path = ~/.gitconfig_client
```

## Verify

```bash
cd ~/git/work-org/some-repo
git config user.email
# → you@company.com

cd ~/git/personal/some-repo
git config user.email
# → personal@gmail.com
```

## Tips

- Path must end with `/`
- Must be inside a git repo for includeIf to activate
- Use `git config --list --show-origin` to debug
- Use absolute paths if `~` doesn't work: `gitdir:/Users/you/git/work/`

## See Also

- [Git includeIf docs](https://git-scm.com/docs/git-config#_includes)
