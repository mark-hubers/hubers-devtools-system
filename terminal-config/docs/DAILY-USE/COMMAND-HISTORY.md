# 🔍 Command History - Never Lose a Command Again!

## Quick Reference

```bash
h                # Interactive history search
Ctrl+R           # Same as h
```

## How to Use

1. Press `h` or `Ctrl+R`
2. Start typing keywords
3. See matching commands
4. Arrow keys to select
5. Enter to run

## Examples

```bash
# Find docker commands
h
> docker

# Find git commands
h  
> git push

# Find commands from yesterday
h
> 2024-12-18
```

## Pro Tips

```bash
# View full history
fc -li 1 | tail -100

# Search with grep
fc -li 1 | grep docker

# Save frequent commands as aliases
```

See [00-START-HERE.md](../00-START-HERE.md) for more.
