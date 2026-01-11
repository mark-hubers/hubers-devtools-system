# SSH & Networking fzf-tab previews for power users

# ============================================================================
# SSH Enhanced
# ============================================================================

### ssh: comprehensive connection preview ###
zstyle ':fzf-tab:complete:ssh:*' fzf-preview \
'echo "🔐 SSH Connection Preview: $word"
echo "════════════════════════════════════════"
echo ""
echo "📋 Config expansion:"
ssh -G $word 2>/dev/null || echo "No SSH config found"
echo ""
echo "════════════════════════════════════════"
echo "📝 Config stanza from ~/.ssh/config:"
grep -i -A10 -B1 "Host[[:space:]]\+$word" ~/.ssh/config 2>/dev/null || echo "No matching config"
echo ""
echo "════════════════════════════════════════"
echo "🔑 Available identities:"
ls -lh ~/.ssh/*.pub 2>/dev/null | tail -5
echo ""
echo "════════════════════════════════════════"
echo "📊 Recent connections to this host:"
grep -i "$word" ~/.ssh/known_hosts 2>/dev/null | wc -l | xargs echo "Known host entries:"'

### scp: source/dest preview ###
zstyle ':fzf-tab:complete:scp:*' fzf-preview \
'if [[ $word == *:* ]]; then
  echo "🌐 Remote path: $word"
  echo ""
  echo "Format: user@host:path"
  echo ""
  echo "Attempting to connect..."
  ssh -G ${word%%:*} 2>/dev/null || echo "Cannot resolve host"
else
  echo "📁 Local path: $word"
  echo ""
  if [ -f $realpath ]; then
    ls -lh --color=always $realpath 2>/dev/null
    echo ""
    echo "Size: $(du -h $realpath 2>/dev/null | cut -f1)"
  elif [ -d $realpath ]; then
    ls -lah --color=always $realpath 2>/dev/null | head -20
  fi
fi'

### sftp: similar to scp ###
zstyle ':fzf-tab:complete:sftp:*' fzf-preview \
'echo "🔐 SFTP Preview: $word"
echo ""
ssh -G $word 2>/dev/null || echo "No SSH config"'

### rsync: intelligent source/dest preview ###
zstyle ':fzf-tab:complete:rsync:*' fzf-preview \
'if [[ $word == *:* ]]; then
  echo "🌐 Remote sync: $word"
  echo ""
  ssh -G ${word%%:*} 2>/dev/null
else
  echo "📁 Local sync: $word"
  echo ""
  if [ -d $realpath ]; then
    echo "Directory contents:"
    ls -lah --color=always $realpath 2>/dev/null | head -20
    echo ""
    echo "Total size: $(du -sh $realpath 2>/dev/null | cut -f1)"
    echo "Files: $(find $realpath -type f 2>/dev/null | wc -l)"
  elif [ -f $realpath ]; then
    ls -lh --color=always $realpath 2>/dev/null
  fi
fi'

# ============================================================================
# Network Diagnostics
# ============================================================================

### ping: show host info before pinging ###
zstyle ':fzf-tab:complete:ping:*' fzf-preview \
'echo "🌐 Ping Preview: $word"
echo "════════════════════════════════════════"
echo ""
echo "🔍 DNS Lookup:"
if command -v dig &> /dev/null; then
  dig +short $word 2>/dev/null
elif command -v nslookup &> /dev/null; then
  nslookup $word 2>/dev/null | grep -A1 "Name:"
elif command -v host &> /dev/null; then
  host $word 2>/dev/null
else
  echo "No DNS tools available"
fi
echo ""
echo "════════════════════════════════════════"
echo "📍 Traceroute (first 3 hops):"
if command -v traceroute &> /dev/null; then
  traceroute -m 3 -w 1 $word 2>/dev/null || echo "Traceroute failed"
else
  echo "Traceroute not available"
fi'

### traceroute: show host info ###
zstyle ':fzf-tab:complete:traceroute:*' fzf-preview \
'echo "🗺️  Traceroute Preview: $word"
echo ""
if command -v dig &> /dev/null; then
  dig +short $word 2>/dev/null
else
  echo "Hostname: $word"
fi'

### curl/wget: URL preview with headers ###
zstyle ':fzf-tab:complete:(curl|wget):*' fzf-preview \
'if [[ $word == http* ]]; then
  echo "🌐 URL Preview: $word"
  echo "════════════════════════════════════════"
  echo ""
  echo "📡 Headers (first 20 lines):"
  curl -sI $word 2>/dev/null | head -20 || echo "Cannot fetch headers"
  echo ""
  echo "════════════════════════════════════════"
  echo "📄 Content preview (first 50 lines):"
  curl -sL $word 2>/dev/null | head -50 || echo "Cannot fetch content"
else
  echo "Not a URL: $word"
fi'

### netstat: connection details ###
zstyle ':fzf-tab:complete:netstat:*' fzf-preview \
'netstat -an | grep $word 2>/dev/null || echo "No connections found"'

### lsof: process file/network usage ###
zstyle ':fzf-tab:complete:lsof:*' fzf-preview \
'echo "📂 Open files/connections:"
echo ""
if [[ $word =~ ^[0-9]+$ ]]; then
  # Port number
  lsof -i :$word 2>/dev/null || echo "No processes using port $word"
else
  # Process name or file
  lsof | grep -i $word 2>/dev/null | head -20 || echo "Not found"
fi'

# ============================================================================
# DNS Tools
# ============================================================================

### dig: DNS query preview ###
zstyle ':fzf-tab:complete:dig:*' fzf-preview \
'echo "🔍 DNS Lookup: $word"
echo "════════════════════════════════════════"
echo ""
echo "A Record (IPv4):"
dig +short A $word 2>/dev/null || echo "No A record"
echo ""
echo "AAAA Record (IPv6):"
dig +short AAAA $word 2>/dev/null || echo "No AAAA record"
echo ""
echo "MX Record (Mail):"
dig +short MX $word 2>/dev/null || echo "No MX record"
echo ""
echo "NS Record (Nameservers):"
dig +short NS $word 2>/dev/null || echo "No NS record"
echo ""
echo "TXT Record:"
dig +short TXT $word 2>/dev/null || echo "No TXT record"
echo ""
echo "════════════════════════════════════════"
echo "Full lookup:"
dig $word 2>/dev/null | head -30'

### nslookup: DNS info ###
zstyle ':fzf-tab:complete:nslookup:*' fzf-preview \
'echo "🔍 nslookup: $word"
echo ""
nslookup $word 2>/dev/null || echo "Lookup failed"'

### host: DNS info ###
zstyle ':fzf-tab:complete:host:*' fzf-preview \
'echo "🔍 host: $word"
echo ""
host $word 2>/dev/null || echo "Lookup failed"'

# ============================================================================
# HTTP Tools
# ============================================================================

### http/https (httpie): request preview ###
zstyle ':fzf-tab:complete:(http|https):*' fzf-preview \
'if [[ $word == http* ]]; then
  echo "🌐 HTTPie Preview: $word"
  echo ""
  if command -v http &> /dev/null; then
    http --headers $word 2>/dev/null | head -30
  else
    curl -sI $word 2>/dev/null | head -30
  fi
else
  echo "URL: $word"
fi'

# ============================================================================
# Network Configuration
# ============================================================================

### ifconfig/ip: interface info (macOS/Linux) ###
zstyle ':fzf-tab:complete:(ifconfig|ip):*' fzf-preview \
'echo "🌐 Network Interface: $word"
echo ""
if [[ "$OSTYPE" == "darwin"* ]]; then
  ifconfig $word 2>/dev/null || echo "Interface not found"
else
  ip addr show $word 2>/dev/null || echo "Interface not found"
fi'

# ============================================================================
# Port & Service Information
# ============================================================================

### Custom function to show what's using a port ###
zstyle ':fzf-tab:complete:*:ports' fzf-preview \
'echo "🔌 Port Information: $word"
echo ""
if command -v lsof &> /dev/null; then
  lsof -i :$word 2>/dev/null || echo "Port not in use"
elif command -v netstat &> /dev/null; then
  netstat -an | grep :$word 2>/dev/null || echo "Port not in use"
else
  echo "No port scanning tools available"
fi'

# ============================================================================
# SSH Known Hosts
# ============================================================================

### ssh-keygen: key info ###
zstyle ':fzf-tab:complete:ssh-keygen:*' fzf-preview \
'if [ -f $realpath ]; then
  echo "🔑 SSH Key: $realpath"
  echo ""
  ssh-keygen -l -f $realpath 2>/dev/null || echo "Not a valid key file"
  echo ""
  echo "════════════════════════════════════════"
  head -n 5 $realpath 2>/dev/null
else
  echo "File: $word"
fi'

# ============================================================================
# VPN & Tunneling
# ============================================================================

### openvpn: config preview ###
zstyle ':fzf-tab:complete:openvpn:*' fzf-preview \
'if [ -f $realpath ]; then
  echo "🔐 OpenVPN Config: $realpath"
  echo ""
  grep -E "^(remote|proto|port|dev|cipher)" $realpath 2>/dev/null || cat $realpath | head -30
fi'

### ssh tunnel: show tunnel command preview ###
zstyle ':fzf-tab:complete:ssh:*:*-L*' fzf-preview \
'echo "🌉 SSH Tunnel Preview"
echo ""
echo "Local port forwarding: -L [bind_address:]port:host:hostport"
echo ""
echo "Example: ssh -L 8080:localhost:80 $word"
echo "Creates tunnel from local 8080 to remote 80"'

### wireguard: config preview (if wg is available) ###
zstyle ':fzf-tab:complete:wg:*' fzf-preview \
'if command -v wg &> /dev/null; then
  wg show $word 2>/dev/null || echo "Interface: $word"
fi'
