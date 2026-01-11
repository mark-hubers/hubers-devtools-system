# ⚙️ System Monitoring & Processes

## Quick Reference

```bash
psa             # Top 20 processes by CPU
psmem           # Top 20 processes by memory
port 8080       # Check port usage
killport 8080   # Kill process on port
```

## Examples

### Find Resource Hogs
```bash
# CPU hogs
psa

# Memory hogs
psmem
```

### Debug Port Issues
```bash
# What's using port 3000?
port 3000

# Kill it
killport 3000
```

## Advanced Tools (Optional)

```bash
# Better process viewer
brew install btop
btop

# Disk usage explorer  
brew install ncdu
ncdu
```

See [00-START-HERE.md](../00-START-HERE.md) for more tools.
