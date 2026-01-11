# 🚀 Modern CLI Tools Reference

Quick reference for modern tool replacements.

```bash
tools           # Show complete reference
```

## File Listing (eza → ls)

```bash
ls              # List with icons
ll              # Long detailed list
ltr             # Oldest→Newest
lsr             # Real ls -ltr
la              # Show hidden files
```

## File Viewing (bat → cat)

```bash
cat file.txt    # With syntax highlighting
catp file.txt   # Plain cat (no formatting)
rawcat file.txt # Same as catp
```

## Text Search (ripgrep → grep)

```bash
grip "text" file    # Case-insensitive search
rg "pattern"        # Search in current dir
```

## Directory Navigation (zoxide → cd)

```bash
z myproject         # Smart jump
bm proj ~/path      # Bookmark
bms                 # List bookmarks
```

See [DIRECTORY-JUMPING.md](DIRECTORY-JUMPING.md) for complete zoxide guide.
