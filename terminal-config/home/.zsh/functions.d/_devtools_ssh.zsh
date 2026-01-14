#!/bin/zsh
# ============================================================================
# SSH Tunnels, Proxies & Remote Access
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# ============================================================================

# SOCKS5 proxy - browse web through remote machine
socks() {
  local host="${1:?Usage: socks <host> [port]}"
  local port="${2:-9999}"
  echo "SOCKS5 proxy through $host on localhost:$port"
  echo "Browser: SOCKS5 proxy -> localhost:$port"
  echo "CLI: export ALL_PROXY=socks5://localhost:$port"
  ssh -D "$port" -C -q -N "$host"
}
alias socks-proxy='socks'

# Port forwarding
forward() {
  local lport="${1:?Usage: forward <local_port> <remote_host:port> <ssh_host>}"
  local remote="${2:?Need remote_host:port}"
  local via="${3:?Need ssh_host}"
  echo "localhost:$lport -> $remote (via $via)"
  ssh -L "$lport:$remote" -N -q "$via"
}

forward-web() {
  local host="${1:?Usage: forward-web <internal_host> <ssh_jump>}"
  local via="${2:?Need ssh jump host}"
  ssh -L "8443:$host:443" -N -q "$via"
}

forward-rdp() {
  local host="${1:?Usage: forward-rdp <windows_host> <ssh_jump>}"
  local via="${2:?Need ssh jump host}"
  ssh -L "3389:$host:3389" -N -q "$via"
}

# Reverse tunnel - expose local service
expose() {
  local port="${1:?Usage: expose <port> <ssh_host>}"
  local host="${2:?Need ssh_host}"
  ssh -R "$port:localhost:$port" -N -q "$host"
}

# Tunnel management
tunnels() {
  echo "Active SSH tunnels:"
  ps aux | grep -E "ssh.+(-[DLRN]|ProxyJump)" | grep -v grep | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}'
  [[ $(ps aux | grep -E "ssh.+(-[DLRN])" | grep -v grep | wc -l) -eq 0 ]] && echo "  (none)"
}

tunnel-kill() {
  local count=$(ps aux | grep -E "ssh.+-[DLRN]" | grep -v grep | wc -l)
  pkill -f "ssh.*-[DLRN]"
  echo "Killed $count tunnel(s)"
}

# File transfer helpers (simple rsync wrappers)
push() {
  local file="${1:?Usage: push <file> <host>:[path]}"
  local dest="${2:?Need destination}"
  rsync -avzP --partial "$file" "$dest"
}

pull() {
  local src="${1:?Usage: pull <host>:<path> [local_path]}"
  rsync -avzP --partial "$src" "${2:-.}"
}

sync-to() {
  local dir="${1:?Usage: sync-to <dir> <host>:<path>}"
  local dest="${2:?Need destination}"
  rsync -avzP --delete "$dir/" "$dest/"
}

sync-from() {
  local src="${1:?Usage: sync-from <host>:<path> <local_dir>}"
  local dest="${2:?Need local destination}"
  rsync -avzP --delete "$src/" "$dest/"
}

# Connection helpers
sshtest() {
  local host="${1:?Usage: sshtest <host>}"
  echo -n "Testing $host... "
  ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" echo "OK" 2>/dev/null || echo "Failed"
}

remote-ip() {
  local host="${1:?Usage: remote-ip <host>}"
  ssh "$host" "hostname -I 2>/dev/null | awk '{print \$1}' || ipconfig getifaddr en0 2>/dev/null"
}

# SSH key setup
ssh-copy-key() {
  local host="${1:?Usage: ssh-copy-key <host>}"
  [[ ! -f ~/.ssh/id_ed25519.pub ]] && [[ ! -f ~/.ssh/id_rsa.pub ]] && echo "No SSH key. Run: ssh-keygen -t ed25519" && return 1
  ssh-copy-id "$host"
}

ssh-setup() {
  if [[ -f ~/.ssh/id_ed25519 ]]; then
    echo "SSH key exists: ~/.ssh/id_ed25519"
  else
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
  fi
  echo "Public key:"
  cat ~/.ssh/id_ed25519.pub
}

ssh-tips() {
  cat << 'EOF'
SSH Config Tips (~/.ssh/config):

Host *
    ServerAliveInterval 60
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

Host internal-*
    ProxyJump bastion.company.com

mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets
EOF
}

# ============================================================================
# iTerm2 File Transfer Helpers
# ============================================================================
# These commands help you SET UP and REMEMBER the iTerm2 transfer commands.
# The actual transfer commands (it2dl, it2ul) run on the REMOTE server.
# ============================================================================

# Install iTerm2 utils on a remote server via SSH
# Usage: iterm-setup-remote myserver
iterm-setup-remote() {
    local host="${1:?Usage: iterm-setup-remote <host>}"
    echo "Installing iTerm2 utilities on $host..."
    ssh "$host" 'curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash'
    echo ""
    echo "Done! Now when SSH'd into $host, you can use:"
    echo "  it2dl <file>   - sends file to your Mac's Downloads"
    echo "  it2ul          - receive file uploaded from your Mac"
}

# Show iTerm2 transfer commands (what to run on remote)
iterm-help() {
    cat << 'EOF'
iTerm2 File Transfer Commands
=============================

RUN ON REMOTE SERVER (after installing):
  it2dl <file>      Send file to your Mac's Downloads folder
  it2ul             Receive upload from your Mac (interactive)

INSTALL ON NEW SERVER:
  From your Mac:    iterm-setup-remote <host>
  Or SSH in, run:   curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

OTHER USEFUL COMMANDS (on remote):
  it2copy           Copy text to your Mac's clipboard
  imgcat <file>     Display image in terminal

NOTE: Only works in iTerm2!
EOF
}
