# 🔍 FZF Complete Guide - Fuzzy Finding Everything!

## 🎯 What is FZF?

**fzf** (fuzzy finder) is a blazing-fast command-line fuzzy finder that lets you interactively search and select items from lists.

Your terminal uses fzf EVERYWHERE:
- Tab completions with previews
- Command history search (Ctrl+R)
- File selection
- Directory jumping
- SSH host selection
- And much more!

---

## 🚀 Basic FZF Usage

### Search Command History (Ctrl+R)
```bash
# Press Ctrl+R
# Start typing any part of a command you ran before
# fzf finds it instantly!

Example:
Ctrl+R
Type: "docker"
→ Shows all docker commands you've run
→ Select with arrow keys, Enter to run
```

### Pipe Anything to fzf
```bash
# Basic usage - pipe any list to fzf
ls | fzf

# Select a file and open it
vim $(ls | fzf)

# Find and kill a process
ps aux | fzf | awk '{print $2}' | xargs kill

# Select from git branches
git branch | fzf | xargs git checkout
```

---

## 🎨 FZF Key Bindings

### In Your Terminal (Already Configured!):

| Shortcut | What It Does |
|----------|--------------|
| **Ctrl+R** | Search command history |
| **Ctrl+T** | Find files (paste path) |
| **Alt+C** | cd into directory (with search) |
| **Tab** | Smart completion with fzf preview |

### Inside FZF:

| Key | Action |
|-----|--------|
| **Ctrl+J/K** or **↓/↑** | Navigate up/down |
| **Enter** | Select and exit |
| **Ctrl+U** | Clear query |
| **Ctrl+C** | Cancel |
| **Tab** | Mark multiple items |
| **Shift+Tab** | Unmark items |
| **Ctrl+A** | Select all |
| **Ctrl+D** | Deselect all |

---

## 📋 FZF Tab Completions (Already Set Up!)

Your setup has **90+ custom fzf-tab completions with previews!**

### Examples:

```bash
# SSH with preview
ssh <TAB>
# Shows: Host details, last login, IP address

# Docker with preview  
docker ps <TAB>
# Shows: Container details, status, ports

# Kubectl with preview
kubectl get pods <TAB>
# Shows: Pod status, age, containers

# Kill process with preview
kill <TAB>
# Shows: Process details, CPU, memory

# Git with preview
git log <TAB>
# Shows: Commit details, diff

# NPM scripts with preview
npm run <TAB>
# Shows: Script contents from package.json
```

---

## 🔧 How to Add More FZF Completions

### Location:
All preview files are in: `~/.zsh/previews/`

### Existing Preview Files:
```bash
ls ~/.zsh/previews/
# Shows:
# - ssh-networking.zsh (25+ SSH/network commands)
# - k8s-enhanced.zsh (20+ Kubernetes resources)
# - docker.zsh (Docker commands)
# - git.zsh (Git commands)
# - package-managers.zsh (npm, yarn, brew, etc.)
# - system-enhanced.zsh (processes, services)
# - aws.zsh (AWS commands)
# - helm.zsh (Helm charts)
# - tf.zsh (Terraform)
# - system.zsh (Basic system commands)
# - ssh.zsh (SSH hosts)
```

---

## 📝 Create Your Own FZF Completion

### Template:

```bash
# Create file: ~/.zsh/previews/my-custom.zsh

# Format:
zstyle ':fzf-tab:complete:COMMAND:*' fzf-preview 'PREVIEW_COMMAND'

# Example: Add preview for 'cat' command
zstyle ':fzf-tab:complete:cat:*' fzf-preview \
  'bat --color=always --style=numbers {1} 2>/dev/null || cat {1}'
```

### Real Examples:

#### 1. Add Preview for Your Custom Scripts:
```bash
# File: ~/.zsh/previews/my-scripts.zsh

# Show script contents when selecting
zstyle ':fzf-tab:complete:myscript:*' fzf-preview \
  'bat --color=always {1}'
```

#### 2. Add Preview for Directories:
```bash
# Show directory contents
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --level=2 --color=always $realpath 2>/dev/null || ls -la $realpath'
```

#### 3. Add Preview for Environment Variables:
```bash
# Show variable value
zstyle ':fzf-tab:complete:export:*' fzf-preview \
  'echo ${(P)word}'
```

#### 4. Add Preview for Your Projects:
```bash
# Show README.md when selecting project directories
zstyle ':fzf-tab:complete:proj:*' fzf-preview \
  'cat $realpath/README.md 2>/dev/null || eza --tree $realpath'
```

---

## 🎯 Advanced FZF Patterns

### Multiple Selection:
```bash
# Select multiple files
vim $(ls | fzf -m)
# -m enables multi-select (use Tab to mark)

# Delete multiple files
rm $(ls | fzf -m)
```

### With Preview Window:
```bash
# Find file with preview
fzf --preview 'bat --color=always {}'

# Find directory with tree preview
find . -type d | fzf --preview 'eza --tree --level=2 {}'
```

### Custom Key Bindings:
```bash
# Execute command on selection
ls | fzf --bind 'enter:execute(vim {})'

# Multiple actions
ls | fzf --bind 'ctrl-o:execute(open {})' \
         --bind 'ctrl-e:execute(vim {})'
```

---

## 💡 Useful FZF Functions (Add to ~/.zshrc)

### 1. Find and Edit File:
```bash
fe() {
  local file
  file=$(fzf --preview 'bat --color=always {}')
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}
```

### 2. Find and cd to Directory:
```bash
fcd() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf)
  [ -n "$dir" ] && cd "$dir"
}
```

### 3. Search File Contents (ripgrep + fzf):
```bash
fif() {
  rg --files-with-matches --no-messages "$1" | fzf \
    --preview "rg --pretty --context 3 '$1' {}"
}
```

### 4. Git Commit Browser:
```bash
fshow() {
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" | \
  fzf --ansi --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % git show --color=always %" \
      --bind "enter:execute:echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % git show %"
}
```

### 5. Process Killer with Preview:
```bash
fkill() {
  local pid
  pid=$(ps aux | fzf --header-lines=1 \
    --preview 'echo {}' | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid"
}
```

### 6. Docker Container Interactive:
```bash
fdocker() {
  local container
  container=$(docker ps -a | fzf --header-lines=1 | awk '{print $1}')
  [ -n "$container" ] && docker exec -it "$container" bash
}
```

---

## 🎨 Customize FZF Appearance

### Color Schemes:

```bash
# Add to ~/.zshrc

# Dracula theme
export FZF_DEFAULT_OPTS='
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Nord theme
export FZF_DEFAULT_OPTS='
  --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
  --color=fg+:#e5e9f0,bg+:#434c5e,hl+:#81a1c1
  --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
  --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

# Gruvbox theme
export FZF_DEFAULT_OPTS='
  --color=fg:#ebdbb2,bg:#282828,hl:#fabd2f
  --color=fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
  --color=info:#83a598,prompt:#bdae93,spinner:#fabd2f
  --color=pointer:#83a598,marker:#fe8019,header:#665c54'
```

### Layout Options:

```bash
# Reverse layout (list at bottom)
export FZF_DEFAULT_OPTS='--layout=reverse'

# Bigger preview window
export FZF_DEFAULT_OPTS='--preview-window=right:60%'

# Preview on top
export FZF_DEFAULT_OPTS='--preview-window=up:40%'

# Borderless
export FZF_DEFAULT_OPTS='--border=none'
```

---

## 🔍 FZF with Ripgrep (Search File Contents)

### Basic Search:
```bash
# Search for text in files
rg "search term" | fzf

# With preview
rg "search term" --line-number | fzf \
  --preview 'bat --color=always {1} --highlight-line {2}'
```

### Interactive File Content Search:
```bash
# Add to ~/.zshrc
# Usage: rgf <search-term>
rgf() {
  local selected
  selected=$(rg --line-number --color=always "$@" | 
    fzf --ansi --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} {1}' \
        --preview-window '+{2}/2')
  
  if [ -n "$selected" ]; then
    local file=$(echo "$selected" | cut -d: -f1)
    local line=$(echo "$selected" | cut -d: -f2)
    ${EDITOR:-vim} "+$line" "$file"
  fi
}
```

---

## 📊 FZF Performance Tips

### Speed Up File Finding:
```bash
# Use fd instead of find (much faster)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# For Ctrl+T
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# For Alt+C (directories)
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
```

### Respect .gitignore:
```bash
# Already configured in your setup!
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
```

---

## 🎯 Your Setup's FZF Features

### Already Configured:

1. **90+ Tab Completions with Previews**
   - SSH, Docker, Kubernetes, Git, etc.
   
2. **Smart Preview Windows**
   - Right side preview (60% width)
   - Automatic syntax highlighting
   - Context-aware previews

3. **Key Bindings**
   - Ctrl+R: Command history
   - Ctrl+T: File finder
   - Alt+C: Directory jumper

4. **Custom Previews For:**
   - SSH hosts (shows IP, last login)
   - Docker containers (shows status, ports)
   - Kubernetes pods (shows status, age)
   - Git commits (shows diff)
   - Processes (shows CPU, memory)
   - And 85+ more!

---

## 💾 Backup & Restore Your FZF Config

### Backup Preview Files:
```bash
# Your previews are in
~/.zsh/previews/

# Backup
cp -r ~/.zsh/previews ~/previews-backup

# They're also in the ZIP you downloaded!
```

### Add New Preview File:
```bash
# 1. Create file
nano ~/.zsh/previews/my-custom.zsh

# 2. Add completions (see examples above)

# 3. Reload
source ~/.zshrc

# 4. Test
mycommand <TAB>
```

---

## 🆘 Troubleshooting

### Preview Not Showing?
```bash
# Check if fzf-tab is loaded
echo $fzf_tab_version

# Check if preview file exists
ls ~/.zsh/previews/

# Reload
source ~/.zshrc
```

### Tab Completion Not Working?
```bash
# Check if completion is enabled
echo $fpath | grep fzf

# Reload completions
autoload -Uz compinit && compinit
```

### Preview Shows Error?
```bash
# Check if preview command exists
# Example: bat for file previews
command -v bat

# Install missing tools:
brew install bat eza fd ripgrep
```

---

## 📚 More Resources

### Official Docs:
- FZF: https://github.com/junegunn/fzf
- fzf-tab: https://github.com/Aloxaf/fzf-tab

### Example Completions:
Your setup includes 11 preview files with 90+ completions!
See: `~/.zsh/previews/` for examples

### Test Your Completions:
```bash
# Try these:
ssh <TAB>
docker ps <TAB>
kubectl get pods <TAB>
git log <TAB>
npm run <TAB>
kill <TAB>
```

---

## ✅ Summary

**You already have 90+ fzf completions set up!**

To add more:
1. Create file in `~/.zsh/previews/`
2. Use template: `zstyle ':fzf-tab:complete:COMMAND:*' fzf-preview 'PREVIEW'`
3. Reload: `source ~/.zshrc`
4. Test: `command <TAB>`

**Your terminal is already legendary with fzf!** 🚀

---

## 🎯 Quick Add Examples

Copy these to add more completions:

```bash
# File: ~/.zsh/previews/my-additions.zsh

# Preview for 'cat' command
zstyle ':fzf-tab:complete:cat:*' fzf-preview \
  'bat --color=always {1} 2>/dev/null'

# Preview for 'cd' command  
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --tree --level=2 $realpath 2>/dev/null'

# Preview for 'vim' command
zstyle ':fzf-tab:complete:vim:*' fzf-preview \
  'bat --color=always {1} 2>/dev/null'

# Preview for custom commands
zstyle ':fzf-tab:complete:mycommand:*' fzf-preview \
  'echo "Your preview here: {1}"'
```

Save, reload (`source ~/.zshrc`), and test!
