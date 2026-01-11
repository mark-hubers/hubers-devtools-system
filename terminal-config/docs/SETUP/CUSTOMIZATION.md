# 🎨 Customizing Your Terminal

Quick guide to making this terminal setup YOURS.

---

## 🔒 Safe Customization File: ~/.zshrc_hubers

**IMPORTANT:** Add all your personal customizations to `~/.zshrc_hubers` - this file is **NEVER overwritten** by the installer!

```bash
# Edit your personal customizations:
vim ~/.zshrc_hubers
code ~/.zshrc_hubers
nano ~/.zshrc_hubers

# Your changes are automatically loaded at shell startup
# No need to edit the main .zshrc file!
```

### Why Use .zshrc_hubers?

✅ **Safe from reinstalls** - Never gets overwritten  
✅ **Clean separation** - Your stuff separate from framework  
✅ **Easy backup** - Just one file to backup  
✅ **Already created** - Installer creates it with helpful template  

---

## ⚡ 3-Minute Quick Start

After installation, customize these three things:

```bash
# 1. Customize your startup display (most important!)
favedit

# 2. Add your project bookmarks
cd ~/Projects/myapp
bm myapp

cd ~/Documents/work
bm work

# 3. Add your personal aliases/functions
vim ~/.zshrc_hubers
# Add things like:
# alias deploy='./scripts/deploy.sh'
# alias myproject='cd ~/Projects/app && code .'
```

That's it! You're 80% customized.

---

## 🎯 Key Customization Areas

### 1. Personal Aliases & Functions (~/.zshrc_hubers)

**This is where ALL your personal customizations go!**

```bash
# Edit the file:
vim ~/.zshrc_hubers

# Example additions:
# === MY CUSTOM ALIASES ===
alias deploy='./scripts/deploy.sh'
alias logs='tail -f /var/log/app.log'
alias db='mysql -u root -p mydb'

# === MY CUSTOM FUNCTIONS ===
work() {
  cd ~/Projects/work
  code .
  npm run dev
}

# === ENVIRONMENT VARIABLES ===
export MY_API_KEY="secret123"
export DATABASE_URL="postgres://localhost/mydb"
```

**Reload after changes:**
```bash
source ~/.zshrc
# Or just open a new terminal tab
```

---

### 2. Startup Display (Favorites)

**What:** The command reference shown every time you open a terminal

**Customize with:**
```bash
favedit          # Edit your personal command list
dev-tools-edit   # Same command, alternate name
favoff           # Disable if distracting
```

**File:** `~/.zsh/my-favorites.txt`

**See:** `th favorites` for complete guide

---

### 3. Directory Bookmarks

**What:** Instantly jump to your most-used directories

**Customize with:**
```bash
cd ~/Projects/important-project
bm proj          # Create bookmark named "proj"

cd ~/Documents/work
bm work          # Create bookmark named "work"

# Jump to them:
mycd proj        # Or just: cd <TAB> and select
```

**File:** `~/.zsh-bookmarks`

**See:** `th dirs` for complete guide

---

### 4. Prompt Theme (Powerlevel10k)

**Customize your prompt appearance:**

```bash
p10k configure   # Run the configuration wizard again
```

**See:** `th powerlevel10k` for complete setup guide

---

### 5. FZF Behavior

**Customize fuzzy finder colors and behavior:**

**⚠️ NOTE:** Don't edit the main `.zshrc` - add overrides to `~/.zshrc_hubers` instead!

```bash
# In ~/.zshrc_hubers, you can override FZF settings:
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --color=fg:#YOUR_COLOR,bg:#YOUR_BG
"
```

**See:** `th fzf` for complete guide

---

## 🔧 Advanced Customizations

### Adding New Toolkits

Create your own toolkit file:

```bash
# Create new toolkit
vim ~/.zsh/my-toolkit.zsh

# Add your functions:
my-function() {
  echo "My custom function"
}

# Source it in ~/.zshrc_hubers (NOT in main .zshrc!)
echo 'source ~/.zsh/my-toolkit.zsh' >> ~/.zshrc_hubers
```

### Custom Completion Scripts

Add your own tab completions:

```bash
# Create completion file
vim ~/.zsh/_mycommand

# See existing files for examples:
ls ~/.zsh/_*
```

### Environment Variables

Add to `~/.zshrc_hubers`:

```bash
# === MY ENVIRONMENT ===
export MY_APP_ENV=production
export DATABASE_URL=postgres://localhost/mydb
export API_KEY=secret123
```

---

## 📋 Customization Checklist

After installation, customize these (in order):

- [ ] Edit `~/.zshrc_hubers` - add your custom aliases/functions
- [ ] Run `favedit` - add your most-used commands
- [ ] Add directory bookmarks with `bm`
- [ ] Run `p10k configure` if you want a different prompt style
- [ ] Explore `th <TAB>` to discover all features
- [ ] Customize FZF colors/behavior (in ~/.zshrc_hubers, optional)

---

## 🎨 Examples of Common Customizations

### Web Developer

```bash
# In ~/.zshrc_hubers
alias dev='npm run dev'
alias test='npm test'
alias build='npm run build'

deploy() {
  npm run build
  rsync -avz dist/ server:/var/www/
}
```

### DevOps Engineer

```bash
# In ~/.zshrc_hubers
alias k='kubectl'
alias tf='terraform'

prod() {
  export AWS_PROFILE=production
  export KUBECONFIG=~/.kube/prod-config
  echo "✅ Switched to PRODUCTION"
}

staging() {
  export AWS_PROFILE=staging
  export KUBECONFIG=~/.kube/staging-config
  echo "✅ Switched to STAGING"
}
```

### Data Scientist

```bash
# In ~/.zshrc_hubers
alias jlab='jupyter lab'
alias jnb='jupyter notebook'

activate() {
  source ~/envs/$1/bin/activate
  echo "✅ Activated: $1"
}
```

---

## 🔗 Related Documentation

- `th favorites` - Customize startup display
- `th dirs` - Directory bookmarks
- `th fzf` - Fuzzy finding customization
- `th git` - Git workflow customization
- `th powerlevel10k` - Prompt customization

---

## 💡 Pro Tips

### Tip 1: Always Use ~/.zshrc_hubers

**❌ DON'T:**
```bash
# Don't edit the main .zshrc
vim ~/.zshrc  # This gets overwritten on reinstall!
```

**✅ DO:**
```bash
# Always edit your personal file
vim ~/.zshrc_hubers  # Safe from reinstalls!
```

### Tip 2: Start Small
Don't try to customize everything at once. Start with:
1. Add 3-5 aliases to ~/.zshrc_hubers
2. Add 5 commands to favorites
3. Bookmark 3 directories

### Tip 3: Iterate Over Time
Add to your customizations as you discover needs:
- Forgot a command? → Add to favorites
- Visit a directory often? → Bookmark it
- Run a complex command repeatedly? → Add alias to ~/.zshrc_hubers

### Tip 4: Backup Your Customizations
```bash
# Backup your custom files (version control these!)
cp ~/.zshrc_hubers ~/.dotfiles/
cp ~/.zsh/my-favorites.txt ~/.dotfiles/
cp ~/.zsh-bookmarks ~/.dotfiles/

# Or use git:
cd ~
git init
git add .zshrc_hubers .zsh/my-favorites.txt .zsh-bookmarks
git commit -m "My terminal customizations"
```

### Tip 5: Check the Template
If you forget what you can add, check the template:

```bash
# The template has helpful examples:
cat ~/.zshrc_hubers
```

---

## 🔄 What Happens on Reinstall?

When you run `./INSTALL.sh` again:

| File | What Happens |
|------|--------------|
| `~/.zshrc` | ⚠️ **Overwritten** (backed up first) |
| `~/.zshrc_hubers` | ✅ **SAFE** - Never touched! |
| `~/.zsh/my-favorites.txt` | ✅ **SAFE** - Never touched! |
| `~/.zsh-bookmarks` | ✅ **SAFE** - Never touched! |
| `~/.zsh/*.zsh` toolkits | ⚠️ **Overwritten** (but you shouldn't edit these) |

**The rule:** Only edit files in your "safe zone" and they'll survive any reinstall!

**Your Safe Zone:**
- `~/.zshrc_hubers` ← All your aliases/functions go here
- `~/.zsh/my-favorites.txt` ← Edit with `favedit`
- `~/.zsh-bookmarks` ← Managed by `bm` command

---

**Next Step:** Run `vim ~/.zshrc_hubers` and add your first alias! 🚀
