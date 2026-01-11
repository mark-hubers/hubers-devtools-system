# 📂 Directory Jumping - Never Waste Time Finding Folders!

## Quick Reference

```bash
bm proj ~/Projects/myapp     # Bookmark directory
bms                          # List bookmarks
mycd proj                    # Jump to bookmark
z myapp                      # Smart jump (partial match)
d                            # Show history
```

## Examples

```bash
# Save your 5 main directories
cd ~/Projects/main-app && bm proj
cd ~/Documents/work && bm work
cd ~/Downloads && bm down
cd ~/.config && bm config
cd ~/scripts && bm scripts

# Jump instantly
mycd proj          # Goes to ~/Projects/main-app
mycd <TAB>         # Shows all bookmarks
```

## How It Works

- Every `cd` is tracked automatically
- Zoxide learns your habits
- Use `z <partial-name>` to jump
- Use `bm` to boost important directories

See [ZOXIDE-BOOKMARKS-GUIDE.md](../../ZOXIDE-BOOKMARKS-GUIDE.md) for complete guide.
