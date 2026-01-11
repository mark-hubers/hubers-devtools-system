# 📋 Clipboard Functions

## Quick Reference

```bash
clip            # Copy to clipboard
paste           # Paste from clipboard
```

## Examples

### Copy File Contents
```bash
clip < script.sh
clip < config.json
```

### Copy Command Output
```bash
ls -la | clip
git log --oneline | clip
kubectl get pods | clip
```

### Paste
```bash
paste
paste > output.txt
```

## How It Works

- macOS: Uses `pbcopy/pbpaste`
- Linux X11: Uses `xclip`
- Linux Wayland: Uses `wl-copy/wl-paste`

See [00-START-HERE.md](../00-START-HERE.md) for more utilities.
