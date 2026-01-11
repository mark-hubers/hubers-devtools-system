# 📚 Zoxide Bookmarks System - Never Waste Time Finding Folders!

## 🎯 The Problem You Have:
"I waste a lot of time finding my folders"

## ✅ The Solution:
Zoxide automatically tracks EVERY directory you `cd` into and lets you jump instantly!

---

## 🚀 How It Works (Automatic!)

### Every Time You cd:
```bash
cd ~/Projects/myapp
cd ~/Documents/reports
cd ~/Downloads

# zoxide is watching and learning!
```

### Jump Anywhere Instantly:
```bash
z myapp      # Jumps to ~/Projects/myapp
z reports    # Jumps to ~/Documents/reports  
z down       # Jumps to ~/Downloads
```

**You just type PART of the directory name!**

---

## 📖 Quick Commands

### See Your History:
```bash
bookmarks           # Shows your top 20 most-used directories
d                   # Same thing (short version)
```

### Jump with Tab Completion:
```bash
mycd <TAB>          # Shows all your directories
mycd proj<TAB>      # Filters to matching ones
```

### Save Your 5 Favorite Dirs:
```bash
# Bookmark your most important directories
bookmark proj ~/Projects/my-main-project
bookmark work ~/Documents/work-files
bookmark scripts ~/scripts
bookmark config ~/.config
bookmark notes ~/Documents/notes

# Now jump instantly:
mycd proj           # Goes to ~/Projects/my-main-project
mycd work           # Goes to ~/Documents/work-files
```

---

## 🎯 Setup Your 5 Favorite Directories (Do This Now!)

After installing, run these commands:

```bash
# 1. Go to your important directories and bookmark them
cd ~/Projects/most-important-project
bookmark proj

cd ~/Documents/work-stuff
bookmark work

cd ~/scripts
bookmark scripts

cd ~/.config
bookmark config

cd ~/Documents/notes
bookmark notes

# 2. Now you can jump instantly:
mycd proj          # Boom! You're there
mycd work          # Boom! You're there
```

---

## 💡 Pro Tips

### Tip 1: Let It Learn
Just use `cd` normally for a week. Zoxide learns your habits.

```bash
# Day 1-7: Just cd normally
cd ~/Projects/myapp
cd ~/Documents/reports
cd ~/Downloads

# After a week:
z myapp            # Works perfectly!
z reports          # Works perfectly!
```

### Tip 2: Use Partial Names
```bash
z dow              # Jumps to Downloads
z doc              # Jumps to Documents
z proj             # Jumps to Projects
```

### Tip 3: Check Your History
```bash
bookmarks          # See what zoxide has learned
# Shows your top 20 with scores
```

### Tip 4: Interactive Picker
```bash
zi                 # Opens interactive menu
# Use arrow keys to pick
```

### Tip 5: Go Back
```bash
z -                # Jump to previous directory
```

---

## 📋 Complete Example Workflow

```bash
# Morning: Bookmark your key directories
bookmark proj ~/Projects/main-app
bookmark docs ~/Documents/work
bookmark down ~/Downloads
bookmark notes ~/Documents/notes
bookmark scripts ~/bin/scripts

# Throughout the day: Just use mycd
mycd proj          # Jump to project
# ... do work ...

mycd docs          # Jump to documents
# ... do work ...

mycd down          # Jump to downloads
# ... do work ...

# Anytime: See your history
bookmarks          # Shows everywhere you've been

# Tab completion works!
mycd <TAB>         # Shows all bookmarked directories
mycd pr<TAB>       # Filters to "proj"
```

---

## 🆚 Old Way vs New Way

### Old Way (Slow):
```bash
cd ~/Projects/my-really-long-project-name/src/components
cd ~/Documents/work-files/2024/Q4/reports
cd ~/Downloads

# Lots of typing!
# Have to remember full paths!
# Wasting time!
```

### New Way (Fast):
```bash
z components       # Instant!
z reports          # Instant!
z down             # Instant!

# Or use bookmarks:
mycd proj          # Instant!
mycd work          # Instant!
```

---

## ❓ FAQ

### Q: Does it replace cd?
**A:** No! Regular `cd` still works and is tracked by zoxide.

### Q: How does it know where to jump?
**A:** It learns from your `cd` usage. The more you visit a directory, the higher its score.

### Q: What if two directories have similar names?
**A:** Zoxide picks the one you visit most. Or be more specific: `z proj/src`

### Q: Can I see all my directories?
**A:** Yes! Run `bookmarks` or `mycd <TAB>`

### Q: How do I remove a directory?
**A:** `zoxide remove /path/to/dir`

---

## 🔧 Customization

### Change Number of Shown Directories:
```bash
# In ~/.zshrc, find the bookmarks() function
# Change 'head -20' to 'head -50' for more

bookmarks() {
  zoxide query -l -s | head -50 | nl  # Changed from 20 to 50
}
```

### Add More Quick Aliases:
```bash
# Add to ~/.zshrc:
alias proj='z proj'        # Quick jump to project
alias docs='z docs'        # Quick jump to documents  
alias scripts='z scripts'  # Quick jump to scripts
```

---

## ✅ Summary

**Stop wasting time finding folders!**

1. ✅ Use `cd` normally - zoxide tracks automatically
2. ✅ Bookmark your 5 favorites: `bookmark name ~/path`
3. ✅ Jump instantly: `mycd <TAB>` or `z <partial-name>`
4. ✅ Check history: `bookmarks`

**Never type long paths again!** 🚀
