# 🛠️ File Utilities

## Quick Reference

```bash
extract file.zip             # Extract any archive
mkcd new-folder              # Create dir and cd into it
clip < file.txt              # Copy file to clipboard
echo "text" | clip           # Copy text to clipboard
paste                        # Paste from clipboard
serve                        # HTTP server on port 8000
serve 3000                   # HTTP server on port 3000
```

## Examples

### Extract Anything
```bash
extract project.zip
extract backup.tar.gz
extract data.rar
extract package.7z
# It just works!
```

### Quick Directory Creation
```bash
mkcd new-project
# Creates ~/new-project and enters it
```

### Clipboard
```bash
# Copy file contents
clip < script.sh

# Copy command output
ls -la | clip

# Paste
paste
```

### HTTP Server
```bash
# Share files quickly
cd ~/Documents
serve
# Open http://localhost:8000 in browser
```

See [00-START-HERE.md](../00-START-HERE.md) for more utilities.
