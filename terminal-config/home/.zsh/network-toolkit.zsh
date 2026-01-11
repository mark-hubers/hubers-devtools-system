# ============================================================================
# NETWORK DEBUGGING TOOLKIT
# Easy commands for ports, DNS, TCP, tunneling, and more
# ============================================================================

# ====================================
# PORT MANAGEMENT
# ====================================

# List all listening ports (BETTER than 'port')
ports() {
  echo "🔌 Listening Ports (TCP & UDP)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  lsof -iTCP -sTCP:LISTEN -n -P | awk 'NR==1 || /LISTEN/' | column -t
  echo ""
  echo "UDP ports:"
  lsof -iUDP -n -P | awk 'NR==1 || /UDP/' | head -10 | column -t
}

# Show what's using a specific port (enhanced version)
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port_number>"
    echo "Example: port 8080"
    echo ""
    echo "💡 Or use 'ports' to see ALL listening ports"
    return 1
  fi
  
  echo "🔍 Checking port $1..."
  echo ""
  
  local result=$(lsof -i :$1 -n -P 2>/dev/null)
  
  if [[ -z "$result" ]]; then
    echo "✅ Port $1 is FREE"
  else
    echo "❌ Port $1 is IN USE:"
    echo ""
    echo "$result" | column -t
    echo ""
    echo "💡 Kill it with: killport $1"
  fi
}

# Kill process on port (enhanced with confirmation)
killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port_number>"
    return 1
  fi
  
  local pid=$(lsof -ti :$1)
  
  if [[ -z "$pid" ]]; then
    echo "✅ Nothing running on port $1"
    return 0
  fi
  
  echo "⚠️  Process using port $1:"
  lsof -i :$1 -n -P
  echo ""
  read "confirm?Kill this process? (y/n): "
  
  if [[ $confirm == "y" ]]; then
    kill -9 $pid
    echo "✅ Killed process on port $1"
  else
    echo "❌ Cancelled"
  fi
}

# Find next available port starting from a number
nextport() {
  local start=${1:-8000}
  local port=$start
  
  echo "🔍 Finding next available port starting from $start..."
  
  while lsof -i :$port &>/dev/null; do
    ((port++))
  done
  
  echo "✅ Next available port: $port"
}

# ====================================
# TCP/UDP CONNECTIONS
# ====================================

# Show all network connections
connections() {
  echo "🌐 Active Network Connections"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "ESTABLISHED Connections:"
  lsof -i -n -P | grep ESTABLISHED | column -t | head -20
  echo ""
  echo "💡 For all connections: lsof -i -n -P"
}

# Show connections to a specific host/IP
connto() {
  if [[ -z "$1" ]]; then
    echo "Usage: connto <host_or_ip>"
    echo "Example: connto google.com"
    return 1
  fi
  
  echo "🔍 Connections to $1:"
  echo ""
  lsof -i -n -P | grep -i "$1" | column -t
}

# Test TCP connection to host:port
tcptest() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: tcptest <host> <port>"
    echo "Example: tcptest google.com 443"
    return 1
  fi
  
  local host=$1
  local port=$2
  
  echo "🔌 Testing TCP connection to $host:$port..."
  
  if timeout 3 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
    echo "✅ Port $port is OPEN on $host"
  else
    echo "❌ Port $port is CLOSED or FILTERED on $host"
  fi
}

# Scan common ports on a host
portscan() {
  if [[ -z "$1" ]]; then
    echo "Usage: portscan <host>"
    echo "Example: portscan google.com"
    return 1
  fi
  
  local host=$1
  local common_ports=(21 22 23 25 53 80 110 143 443 445 3306 3389 5432 5900 8080 8443)
  
  echo "🔍 Scanning common ports on $host..."
  echo ""
  
  for port in "${common_ports[@]}"; do
    if timeout 1 bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
      printf "✅ Port %-5s OPEN\n" "$port"
    else
      printf "❌ Port %-5s closed\n" "$port"
    fi
  done
}

# ====================================
# DNS DEBUGGING
# ====================================

# Quick DNS lookup with all record types
dns() {
  if [[ -z "$1" ]]; then
    echo "Usage: dns <domain>"
    echo "Example: dns google.com"
    return 1
  fi
  
  local domain=$1
  
  echo "🌐 DNS Records for: $domain"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  echo "A Records (IPv4):"
  dig +short A $domain | sed 's/^/  /'
  echo ""
  
  echo "AAAA Records (IPv6):"
  dig +short AAAA $domain | sed 's/^/  /'
  echo ""
  
  echo "MX Records (Mail):"
  dig +short MX $domain | sed 's/^/  /'
  echo ""
  
  echo "NS Records (Nameservers):"
  dig +short NS $domain | sed 's/^/  /'
  echo ""
  
  echo "TXT Records:"
  dig +short TXT $domain | sed 's/^/  /'
}

# Reverse DNS lookup
rdns() {
  if [[ -z "$1" ]]; then
    echo "Usage: rdns <ip_address>"
    echo "Example: rdns 8.8.8.8"
    return 1
  fi
  
  echo "🔍 Reverse DNS for: $1"
  dig +short -x $1
}

# Trace DNS resolution path
dnstrace() {
  if [[ -z "$1" ]]; then
    echo "Usage: dnstrace <domain>"
    echo "Example: dnstrace google.com"
    return 1
  fi
  
  echo "🔍 DNS Resolution Path for: $1"
  echo ""
  dig +trace $1 | grep -v '^;'
}

# Check DNS propagation across multiple servers
dnsprop() {
  if [[ -z "$1" ]]; then
    echo "Usage: dnsprop <domain>"
    echo "Example: dnsprop google.com"
    return 1
  fi
  
  local domain=$1
  
  echo "🌍 DNS Propagation Check for: $domain"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  local servers=(
    "8.8.8.8:Google"
    "1.1.1.1:Cloudflare"
    "208.67.222.222:OpenDNS"
    "9.9.9.9:Quad9"
  )
  
  for server_info in "${servers[@]}"; do
    local server="${server_info%%:*}"
    local name="${server_info##*:}"
    printf "%-15s %-12s " "$name" "($server):"
    dig @$server +short A $domain | tr '\n' ' '
    echo ""
  done
}

# ====================================
# NETWORK INTERFACE INFO
# ====================================

# Show all network interfaces with details
interfaces() {
  echo "🌐 Network Interfaces"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  if command -v ip &>/dev/null; then
    # Linux
    ip -br addr show
  else
    # macOS
    ifconfig | grep -E "^[a-z]|inet " | sed 's/^/  /'
  fi
}

# Get all local IP addresses
myips() {
  echo "📍 Local IP Addresses"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  
  if command -v ip &>/dev/null; then
    # Linux
    ip -o -4 addr show | awk '{print $2, $4}' | column -t
  else
    # macOS
    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | while read ip; do
      local iface=$(ifconfig | grep -B 3 "$ip" | head -1 | cut -d: -f1)
      printf "%-10s %s\n" "$iface" "$ip"
    done
  fi
  
  echo ""
  echo "Public IP:"
  echo "  $(curl -s ifconfig.me || curl -s icanhazip.com)"
}

# ====================================
# TUNNELING & PROXIES
# ====================================

# Quick SSH tunnel setup helper
tunnel() {
  echo "🚇 SSH Tunnel Helper"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Examples:"
  echo ""
  echo "Local port forwarding (access remote service locally):"
  echo "  ssh -L 8080:localhost:80 user@remote"
  echo "  → Access remote:80 via localhost:8080"
  echo ""
  echo "Remote port forwarding (expose local service to remote):"
  echo "  ssh -R 9000:localhost:3000 user@remote"
  echo "  → Remote:9000 accesses your localhost:3000"
  echo ""
  echo "Dynamic port forwarding (SOCKS proxy):"
  echo "  ssh -D 1080 user@remote"
  echo "  → Use localhost:1080 as SOCKS proxy"
  echo ""
  echo "💡 Add -N -f for background tunnel without shell"
}

# List active SSH tunnels
tunnels() {
  echo "🚇 Active SSH Tunnels"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  ps aux | grep -E "ssh.*-[LRD]" | grep -v grep | sed 's/^/  /'
}

# ====================================
# BANDWIDTH & SPEED
# ====================================

# Quick speed test (requires speedtest-cli)
speedtest() {
  if ! command -v speedtest-cli &>/dev/null; then
    echo "❌ speedtest-cli not installed"
    echo "Install: pip install speedtest-cli --break-system-packages"
    return 1
  fi
  
  echo "🚀 Running speed test..."
  speedtest-cli --simple
}

# Monitor bandwidth usage (live)
bandwidth() {
  if ! command -v nload &>/dev/null; then
    echo "❌ nload not installed"
    echo "Install: brew install nload (macOS) or sudo apt install nload (Linux)"
    return 1
  fi
  
  nload
}

# ====================================
# HTTP/HTTPS DEBUGGING
# ====================================

# Quick HTTP headers check
headers() {
  if [[ -z "$1" ]]; then
    echo "Usage: headers <url>"
    echo "Example: headers https://google.com"
    return 1
  fi
  
  echo "📋 HTTP Headers for: $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  curl -sI "$1"
}

# Test SSL certificate
sslcheck() {
  if [[ -z "$1" ]]; then
    echo "Usage: sslcheck <domain>"
    echo "Example: sslcheck google.com"
    return 1
  fi
  
  echo "🔒 SSL Certificate for: $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates -subject -issuer
}

# ====================================
# NETWORK MONITORING
# ====================================

# Watch network connections (live updates)
watchnet() {
  echo "👁️  Watching network connections (Ctrl+C to stop)..."
  echo ""
  watch -n 2 'lsof -i -n -P | grep ESTABLISHED | head -20'
}

# Monitor DNS queries (requires tcpdump/root)
watchdns() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "❌ Requires root access"
    echo "Run: sudo watchdns"
    return 1
  fi
  
  echo "👁️  Monitoring DNS queries (Ctrl+C to stop)..."
  echo ""
  tcpdump -i any -n port 53
}

# ====================================
# ALIASES FOR CONVENIENCE
# ====================================

alias netstat-listen='netstat -an | grep LISTEN'
alias netstat-established='netstat -an | grep ESTABLISHED'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'  # macOS
alias myip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'  # macOS wifi
alias publicip='curl -s ifconfig.me'
alias ping='ping -c 5'  # Limit to 5 packets by default
alias pingg='ping google.com'
alias wget='wget -c'  # Continue downloads by default

# ====================================
# HELP COMMAND
# ====================================

nethelp() {
  echo "🌐 Network Debugging Toolkit - Quick Reference"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "PORT MANAGEMENT:"
  echo "  ports              - List ALL listening ports (TCP & UDP)"
  echo "  port 8080          - Check if port is in use"
  echo "  killport 8080      - Kill process on port (with confirmation)"
  echo "  nextport 8000      - Find next available port"
  echo ""
  echo "CONNECTIONS:"
  echo "  connections        - Show active network connections"
  echo "  connto google.com  - Show connections to specific host"
  echo "  tcptest HOST PORT  - Test if TCP port is open"
  echo "  portscan HOST      - Scan common ports on host"
  echo ""
  echo "DNS:"
  echo "  dns google.com     - Show all DNS records (A, AAAA, MX, NS, TXT)"
  echo "  rdns 8.8.8.8       - Reverse DNS lookup"
  echo "  dnstrace DOMAIN    - Trace DNS resolution path"
  echo "  dnsprop DOMAIN     - Check DNS propagation across servers"
  echo ""
  echo "INTERFACES & IPs:"
  echo "  interfaces         - Show all network interfaces"
  echo "  myips              - Show all local + public IPs"
  echo "  myip               - Show public IP only"
  echo ""
  echo "TUNNELING:"
  echo "  tunnel             - Show SSH tunnel examples"
  echo "  tunnels            - List active SSH tunnels"
  echo ""
  echo "HTTP/SSL:"
  echo "  headers URL        - Show HTTP headers"
  echo "  sslcheck DOMAIN    - Check SSL certificate"
  echo ""
  echo "MONITORING:"
  echo "  watchnet           - Watch connections live"
  echo "  speedtest          - Run internet speed test"
  echo "  bandwidth          - Monitor bandwidth usage"
  echo ""
  echo "💡 Type any command without args for usage help"
}
