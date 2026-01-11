# 🌐 Network Utilities

## Quick Reference

```bash
myip            # Show local + public IPv4
port 8080       # Check what's using port 8080
killport 8080   # Kill process on port 8080
path            # Show $PATH one per line
```

## Examples

### Check Your IPs
```bash
myip
# Shows:
# Local IPv4:  192.168.1.100
# Public IPv4: 203.0.113.45
```

### Debug Port Issues
```bash
# Check if port is in use
port 8080

# Kill process on port
killport 8080
```

### View PATH
```bash
path
# Shows all PATH entries numbered
```

See [../TOOLKITS/NETWORK-TOOLKIT.md](../TOOLKITS/NETWORK-TOOLKIT.md) for 24 network debugging commands.
