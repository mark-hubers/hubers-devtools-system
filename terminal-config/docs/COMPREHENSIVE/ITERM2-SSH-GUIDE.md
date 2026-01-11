# 🖥️ iTerm2 + SSH Complete Guide

Your personal Mac ↔ work laptop setup guide. Includes SSH tunneling, SOCKS proxies, file transfer, and iTerm2 power features.

---

## 🚀 Quick Commands Reference

| Command | What It Does |
|---------|--------------|
| `socks work-laptop` | Browse web as if on work laptop |
| `forward 8080 internal:443 work` | Access internal site on localhost:8080 |
| `push file.txt work:~/` | Copy file to remote with progress |
| `pull work:~/file.txt .` | Download file from remote |
| `tunnels` | List active SSH tunnels |
| `tunnel-kill` | Kill all tunnels |
| `ssh-setup` | Generate SSH key if needed |
| `ssh-copy-key host` | Copy your key to remote |
| `ssh-tips` | Show SSH config examples |

---

## 📋 Initial Setup: Personal Mac ↔ Work Laptop

### Step 1: Enable SSH on Both Macs

**On EACH Mac (personal and work):**

```bash
# System Preferences → Sharing → Remote Login → ON
# Or via command line:
sudo systemsetup -setremotelogin on

# Verify it's running
sudo systemsetup -getremotelogin
```

### Step 2: Find IP Addresses

```bash
# On each Mac, get its local IP:
ipconfig getifaddr en0      # WiFi
ipconfig getifaddr en1      # Ethernet (might be en0 on some Macs)

# Or see all interfaces:
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Example:**
- Personal Mac (Apple Studio): `192.168.1.50`
- Work Laptop: `192.168.1.100`

### Step 3: Generate SSH Keys

```bash
# On your personal Mac:
ssh-setup    # Our helper command

# Or manually:
ssh-keygen -t ed25519 -C "personal-mac"
```

### Step 4: Copy Key to Work Laptop

```bash
# From personal Mac:
ssh-copy-key mark@192.168.1.100

# Or manually:
ssh-copy-id mark@192.168.1.100
```

### Step 5: Test Connection

```bash
# From personal Mac:
ssh mark@192.168.1.100

# Should connect without password!
```

### Step 6: Create SSH Config

Add to `~/.ssh/config` on your personal Mac:

```ssh-config
# Keep connections alive
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
# Connection multiplexing (faster repeat connections)
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

# Work laptop shortcut
Host work
    HostName 192.168.1.100
    User mark
    # iTerm2Profile: Work
    
Host work-laptop
    HostName 192.168.1.100
    User mark
```

Create the sockets directory:
```bash
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets
```

Now you can just type:
```bash
ssh work
```

---

## 🌐 SOCKS Proxy: Browse Web Through Work Laptop

This lets you access work-internal websites from your personal Mac!

### Start the Proxy

```bash
socks work    # Uses port 9999 by default
# Or:
socks work 1080   # Custom port
```

### Configure Browser

**Firefox (easiest - per-browser proxy):**
1. Preferences → Network Settings → Settings
2. Manual proxy → SOCKS Host: `localhost`, Port: `9999`
3. Select "SOCKS v5"
4. Check "Proxy DNS when using SOCKS v5"

**Chrome (uses system proxy):**
1. System Preferences → Network → Advanced → Proxies
2. Check "SOCKS Proxy"
3. Server: `localhost`, Port: `9999`

**Or use a browser extension:**
- FoxyProxy (Firefox/Chrome)
- Proxy SwitchyOmega (Chrome)

### Test It

```bash
# With proxy running, check your apparent IP:
curl --proxy socks5://localhost:9999 ifconfig.me
# Should show work laptop's external IP!
```

### Access Internal Sites

Once proxy is running, you can browse:
- `http://internal.company.com`
- `https://jenkins.internal`
- Any site only accessible from work network

---

## 🔗 Port Forwarding: Access Specific Services

### Forward Internal Web App

```bash
# Access internal.company.com:443 on localhost:8443
forward 8443 internal.company.com:443 work

# Then open: https://localhost:8443
```

### Forward Multiple Ports

```bash
# Jenkins on 8080, GitLab on 8443
ssh -L 8080:jenkins.internal:8080 \
    -L 8443:gitlab.internal:443 \
    -N work
```

### Forward RDP to Windows Machine

```bash
forward-rdp windows-pc.internal work
# Then connect RDP client to localhost:3389
```

### Quick Helpers

```bash
forward-web internal.company.com work   # → localhost:8443
forward-rdp windows-pc work             # → localhost:3389
```

---

## 📁 File Transfer

### Push/Pull Commands (Recommended)

```bash
# Copy file TO work laptop (with progress bar)
push myfile.txt work:~/Documents/

# Copy file FROM work laptop
pull work:~/Documents/report.pdf .

# Sync entire directory TO work
sync-to ./project work:~/projects/project

# Sync FROM work
sync-from work:~/projects/project ./project
```

### iTerm2 Drag & Drop (Requires Shell Integration)

1. Start SSH session: `ssh work`
2. Drag file from Finder into terminal → uploads to current remote directory
3. Cmd+Click on remote file → downloads to local Downloads folder

### Traditional SCP

```bash
# Copy to remote
scp file.txt work:~/

# Copy from remote  
scp work:~/file.txt .

# Copy directory
scp -r ./folder work:~/
```

### Rsync (Better for Large Files)

```bash
# With progress, resume partial transfers
rsync -avzP file.iso work:~/

# Mirror directory (deletes files not in source)
rsync -avzP --delete ./folder/ work:~/folder/
```

---

## 🏃 Jump Hosts / Bastion Servers

Access servers behind a bastion/jump host.

### SSH Config Setup

```ssh-config
# Bastion server
Host bastion
    HostName bastion.company.com
    User mark

# Internal servers - auto-jump through bastion
Host internal-*
    ProxyJump bastion
    User mark

# Specific internal server
Host internal-web
    HostName 10.0.1.50
    ProxyJump bastion
```

### Usage

```bash
# Jumps through bastion automatically!
ssh internal-web

# Or manually:
ssh -J bastion mark@10.0.1.50
```

### Port Forward Through Jump Host

```bash
# Access internal-web:443 via bastion
ssh -J bastion -L 8443:10.0.1.50:443 -N bastion
```

---

## 🖥️ iTerm2 Power Features

### Shell Integration Benefits

When you have shell integration installed:
- **Cmd+Click** on files in `ls` output → opens locally
- **Drag files** into SSH session → uploads them
- **Cmd+Shift+Click** on URL → opens in browser
- **Marks** appear at each prompt (scroll between with Cmd+Shift+↑↓)

### Tab Colors for Context

```bash
tabwork     # Red tab + "WORK" badge
tabprod     # Bright red + "⚠️ PROD" badge  
tabdev      # Green tab + "DEV" badge
tabreset    # Clear color
```

### Custom Tab Color

```bash
tabcolor 255 100 100    # RGB values
```

### Badges

```bash
badge "PRODUCTION"      # Shows in corner
badge "🔥 ALERT"        # Emoji work too
clearbadge              # Remove it
```

### Window/Tab Title

```bash
title "Work Laptop SSH"
```

### Notifications

```bash
# After a long command:
make build; notify "Build finished!"
```

### Images in Terminal

```bash
imgcat image.png        # Display image inline
imgcat *.jpg            # Multiple images
```

### Automatic Profile Switching

Add to `~/.ssh/config`:
```ssh-config
Host prod-*
    # iTerm2Profile: Production
    
Host work
    # iTerm2Profile: Work
```

Create matching profiles in iTerm2 (different colors/fonts), and they'll auto-switch!

---

## 🔧 Troubleshooting

### "Connection refused"

```bash
# Check if SSH is enabled on remote:
sudo systemsetup -getremotelogin

# Check if you can reach the host:
ping 192.168.1.100

# Check firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

### "Permission denied (publickey)"

```bash
# Check your key is loaded:
ssh-add -l

# Add your key:
ssh-add ~/.ssh/id_ed25519

# Copy key to remote:
ssh-copy-key user@host
```

### Connection Drops

Add to `~/.ssh/config`:
```ssh-config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

### Tunnel Not Working

```bash
# Check if tunnel is running:
tunnels

# Check if port is listening:
lsof -i :9999

# Kill and restart:
tunnel-kill
socks work
```

### SOCKS Proxy Not Working in Browser

1. Make sure tunnel is running: `tunnels`
2. Check browser proxy settings point to correct port
3. Try: `curl --proxy socks5://localhost:9999 https://google.com`
4. Check DNS: enable "Proxy DNS" in browser settings

---

## 📋 Complete Example: Personal Mac ↔ Work Laptop

### ~/.ssh/config on Personal Mac

```ssh-config
# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    AddKeysToAgent yes
    UseKeychain yes

# Work laptop on LAN
Host work
    HostName 192.168.1.100
    User mark
    IdentityFile ~/.ssh/id_ed25519
    # iTerm2Profile: Work

# Work laptop via hostname (if DNS works)
Host work-laptop
    HostName marks-work-mbp.local
    User mark

# Internal servers through work laptop
Host internal-*
    ProxyJump work
    User mark

Host internal-jenkins
    HostName jenkins.internal.company.com
    ProxyJump work
```

### Daily Workflow

```bash
# Morning: Start SOCKS proxy for web browsing
socks work &

# SSH to work laptop
ssh work

# Access internal Jenkins
forward 8080 jenkins.internal:8080 work &
open http://localhost:8080

# Push code to work
sync-to ./project work:~/projects/

# Pull logs from work  
pull work:~/logs/app.log .

# End of day: kill tunnels
tunnel-kill
```

---

## 🔑 Security Tips

1. **Use SSH keys, not passwords**
2. **Protect your private key**: `chmod 600 ~/.ssh/id_ed25519`
3. **Use passphrases** on keys (macOS keychain remembers them)
4. **Limit SSH access** in System Preferences → Sharing → Remote Login → "Only these users"
5. **Consider fail2ban** if exposing SSH to internet
6. **Use non-standard port** for internet-facing SSH

---

## 📚 Related Commands

```bash
ssh-tips        # Show SSH config examples
ssh-setup       # Generate SSH key
ssh-copy-key    # Copy key to remote host
tunnels         # List active tunnels
tunnel-kill     # Kill all tunnels
socks           # Start SOCKS proxy
forward         # Port forward
push/pull       # File transfer
```

Run `th ssh` or `th iterm2` to see this guide anytime!
