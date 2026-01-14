# ============================================================================
# NETWORK DEBUGGING TOOLKIT
# Easy commands for ports, DNS, TCP, tunneling, and more
# ============================================================================

# Clear conflicting aliases (may be defined elsewhere)
unalias ports port 2>/dev/null

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

# ====================================
# SSL/TLS CERTIFICATE TOOLS
# ====================================

# Quick certificate summary (alias for sslcheck)
sslcheck() {
  cert "$@"
}

# Certificate summary - subject, issuer, dates
cert() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert <host> [port]"
    echo "Example: cert google.com"
    return 1
  fi

  echo "Certificate for $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates 2>/dev/null
}

# Full SSL test suite
cert-test() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-test <host> [port]"
    return 1
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "SSL/TLS Test: $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # 1. Connection test
  echo "1. Connection Test"
  echo "─────────────────────────────────────────────────────"
  if timeout 5 bash -c "echo | openssl s_client -servername '$host' -connect '$host:$port' 2>/dev/null" | grep -q "BEGIN CERTIFICATE"; then
    echo "   ✅ Connection successful"
  else
    echo "   ❌ Connection FAILED"
    return 1
  fi
  echo ""

  # Get cert data
  local cert_data=$(echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null)

  # 2. TLS Version
  echo "2. TLS Version"
  echo "─────────────────────────────────────────────────────"
  local tls_version=$(echo "$cert_data" | grep "Protocol" | head -1 | awk '{print $NF}')
  echo "   Protocol: ${tls_version:-unknown}"
  echo ""

  # 3. Subject
  echo "3. Certificate Subject"
  echo "─────────────────────────────────────────────────────"
  echo "$cert_data" | openssl x509 -noout -subject 2>/dev/null | sed 's/subject=/   /'
  echo ""

  # 4. Issuer
  echo "4. Issuer (CA)"
  echo "─────────────────────────────────────────────────────"
  echo "$cert_data" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=/   /'
  echo ""

  # 5. Expiration
  echo "5. Expiration"
  echo "─────────────────────────────────────────────────────"
  local not_before=$(echo "$cert_data" | openssl x509 -noout -startdate 2>/dev/null | cut -d= -f2)
  local not_after=$(echo "$cert_data" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
  echo "   Valid From:  $not_before"
  echo "   Expires:     $not_after"

  # Calculate days remaining
  local exp_epoch=$(date -j -f "%b %d %T %Y %Z" "$not_after" "+%s" 2>/dev/null || date -d "$not_after" "+%s" 2>/dev/null)
  local now_epoch=$(date "+%s")
  if [[ -n "$exp_epoch" ]]; then
    local days_left=$(( (exp_epoch - now_epoch) / 86400 ))
    if [[ $days_left -lt 0 ]]; then
      echo "   Status:      ❌ EXPIRED (${days_left#-} days ago)"
    elif [[ $days_left -lt 30 ]]; then
      echo "   Status:      ⚠️  Expires soon ($days_left days left)"
    else
      echo "   Status:      ✅ Valid ($days_left days left)"
    fi
  fi
  echo ""

  # 6. Chain verification
  echo "6. Chain Verification"
  echo "─────────────────────────────────────────────────────"
  local verify_result=$(echo | openssl s_client -servername "$host" -connect "$host:$port" 2>&1 | grep "Verify return code")
  if echo "$verify_result" | grep -q "0 (ok)"; then
    echo "   ✅ Certificate chain is valid"
  else
    echo "   ⚠️  $verify_result"
  fi
  echo ""

  # 7. curl test
  echo "7. curl Test"
  echo "─────────────────────────────────────────────────────"
  local curl_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$host:$port/" 2>/dev/null)
  if [[ "$curl_code" =~ ^[23] ]]; then
    echo "   ✅ curl works (HTTP $curl_code)"
  elif [[ "$curl_code" == "000" ]]; then
    echo "   ❌ curl failed to connect"
  else
    echo "   ⚠️  HTTP $curl_code"
  fi
}

# Show full certificate chain
cert-chain() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-chain <host> [port]"
    return 1
  fi

  echo "Full certificate chain for $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo | openssl s_client -servername "$host" -connect "$host:$port" -showcerts 2>/dev/null | \
    grep -E "s:|i:" | sed 's/^ *//'
}

# Verify certificate chain
cert-verify() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-verify <host> [port]"
    return 1
  fi

  echo "Verifying certificate chain for $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo | openssl s_client -servername "$host" -connect "$host:$port" 2>&1 | \
    grep -E "Verify return code|depth=|verify"
}

# Check certificate expiration with color-coded status
cert-dates() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-dates <host> [port]"
    return 1
  fi

  echo "Certificate dates for $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  local cert_data=$(echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null)
  local not_before=$(echo "$cert_data" | openssl x509 -noout -startdate 2>/dev/null | cut -d= -f2)
  local not_after=$(echo "$cert_data" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

  echo "Valid From:  $not_before"
  echo "Expires:     $not_after"

  # Calculate days remaining (macOS compatible)
  local exp_epoch=$(date -j -f "%b %d %T %Y %Z" "$not_after" "+%s" 2>/dev/null || date -d "$not_after" "+%s" 2>/dev/null)
  local now_epoch=$(date "+%s")

  if [[ -n "$exp_epoch" ]]; then
    local days_left=$(( (exp_epoch - now_epoch) / 86400 ))
    if [[ $days_left -lt 0 ]]; then
      echo "Status:      ❌ EXPIRED (${days_left#-} days ago)"
    elif [[ $days_left -lt 30 ]]; then
      echo "Status:      ⚠️  Expires soon ($days_left days left)"
    else
      echo "Status:      ✅ Valid ($days_left days left)"
    fi
  fi
}

# Show Subject Alternative Names (what domains the cert covers)
cert-san() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-san <host> [port]"
    return 1
  fi

  echo "Subject Alternative Names for $host:$port"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null | \
    openssl x509 -noout -ext subjectAltName 2>/dev/null | \
    grep -oE "DNS:[^,]+" | sed 's/DNS://' | sort -u
}

# Download certificate to file
cert-download() {
  local host="${1:-}"
  local port="${2:-443}"
  local output="${3:-$host.crt}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-download <host> [port] [output_file]"
    echo "Example: cert-download google.com"
    echo "         cert-download google.com 443 my-cert.crt"
    return 1
  fi

  echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null | \
    openssl x509 > "$output"

  if [[ -s "$output" ]]; then
    echo "✅ Certificate saved to: $output"
  else
    echo "❌ Failed to download certificate"
    rm -f "$output"
    return 1
  fi
}

# Raw openssl output
cert-raw() {
  local host="${1:-}"
  local port="${2:-443}"

  if [[ -z "$host" ]]; then
    echo "Usage: cert-raw <host> [port]"
    return 1
  fi

  echo | openssl s_client -servername "$host" -connect "$host:$port" 2>/dev/null | \
    openssl x509 -text -noout
}

# Help for certificate commands
cert-help() {
  echo "🔒 SSL/TLS Certificate Tools"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "QUICK COMMANDS:"
  echo "  cert <host>           Certificate summary (subject, issuer, dates)"
  echo "  cert-test <host>      Full SSL test suite (start here!)"
  echo ""
  echo "DETAILED INSPECTION:"
  echo "  cert-chain <host>     Show all certs in chain"
  echo "  cert-verify <host>    Verify chain completeness"
  echo "  cert-dates <host>     Expiration with days remaining"
  echo "  cert-san <host>       Subject Alternative Names (covered domains)"
  echo ""
  echo "UTILITIES:"
  echo "  cert-download <host>  Download certificate to file"
  echo "  cert-raw <host>       Full certificate details (openssl x509 -text)"
  echo "  sslcheck <host>       Alias for 'cert'"
  echo ""
  echo "PFX FILE OPERATIONS:"
  echo "  pfx-extract <file>    Extract key, cert, and chain from PFX"
  echo "  pfx-info <file>       Show what's in a PFX file"
  echo "  cert-bundle <cert> <chain>  Create bundle file"
  echo ""
  echo "All commands accept optional port: cert-test example.com 8443"
  echo ""
  echo "COMMON ISSUES:"
  echo "  'unable to get local issuer certificate' = incomplete chain"
  echo "  'certificate has expired' = renew the cert!"
  echo "  'hostname mismatch' = cert doesn't cover this domain"
}

# ====================================
# PFX FILE OPERATIONS
# ====================================

# Extract all components from a PFX file
pfx-extract() {
  local pfx_file="${1:-}"
  local base_name="${2:-}"

  if [[ -z "$pfx_file" ]]; then
    echo "Usage: pfx-extract <pfx_file> [base_name]"
    echo ""
    echo "Extracts key, certificate, and CA chain from a PFX file."
    echo ""
    echo "Example:"
    echo "  pfx-extract wildcard_2026.pfx"
    echo "  pfx-extract wildcard_2026.pfx myserver"
    echo ""
    echo "Creates:"
    echo "  <base_name>.key        - Private key"
    echo "  <base_name>.crt        - Server certificate"
    echo "  <base_name>-chain.crt  - CA chain"
    echo "  <base_name>-bundle.crt - Full bundle (cert + chain)"
    return 1
  fi

  if [[ ! -f "$pfx_file" ]]; then
    echo "❌ File not found: $pfx_file"
    return 1
  fi

  # Default base name from pfx filename
  if [[ -z "$base_name" ]]; then
    base_name="${pfx_file%.pfx}"
    base_name="${base_name%.p12}"
  fi

  echo "🔐 Extracting from: $pfx_file"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Extract private key
  echo "Extracting private key..."
  if openssl pkcs12 -in "$pfx_file" -nocerts -nodes 2>/dev/null | \
      sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > "${base_name}.key"; then
    if [[ -s "${base_name}.key" ]]; then
      chmod 600 "${base_name}.key"
      echo "  ✅ ${base_name}.key"
    else
      echo "  ⚠️  No private key found (or wrong password)"
      rm -f "${base_name}.key"
    fi
  fi

  # Extract server certificate
  echo "Extracting server certificate..."
  if openssl pkcs12 -in "$pfx_file" -clcerts -nokeys 2>/dev/null | \
      sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${base_name}.crt"; then
    if [[ -s "${base_name}.crt" ]]; then
      echo "  ✅ ${base_name}.crt"
    else
      echo "  ⚠️  No server certificate found"
      rm -f "${base_name}.crt"
    fi
  fi

  # Extract CA chain
  echo "Extracting CA chain..."
  if openssl pkcs12 -in "$pfx_file" -cacerts -nokeys -chain 2>/dev/null | \
      sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${base_name}-chain.crt"; then
    if [[ -s "${base_name}-chain.crt" ]]; then
      echo "  ✅ ${base_name}-chain.crt"
    else
      echo "  ⚠️  No CA chain found"
      rm -f "${base_name}-chain.crt"
    fi
  fi

  # Create bundle if we have cert and chain
  if [[ -s "${base_name}.crt" && -s "${base_name}-chain.crt" ]]; then
    echo "Creating bundle..."
    cat "${base_name}.crt" "${base_name}-chain.crt" > "${base_name}-bundle.crt"
    echo "  ✅ ${base_name}-bundle.crt"
  fi

  echo ""
  echo "Done! Files created:"
  ls -la ${base_name}*.{key,crt} 2>/dev/null | awk '{print "  " $NF " (" $5 " bytes)"}'
}

# Show info about a PFX file
pfx-info() {
  local pfx_file="${1:-}"

  if [[ -z "$pfx_file" ]]; then
    echo "Usage: pfx-info <pfx_file>"
    return 1
  fi

  if [[ ! -f "$pfx_file" ]]; then
    echo "❌ File not found: $pfx_file"
    return 1
  fi

  echo "🔐 PFX File Info: $pfx_file"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Try to get info (will prompt for password)
  openssl pkcs12 -in "$pfx_file" -nokeys 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null
}

# Create a certificate bundle from cert + chain
cert-bundle() {
  local cert_file="${1:-}"
  local chain_file="${2:-}"
  local output="${3:-bundle.crt}"

  if [[ -z "$cert_file" || -z "$chain_file" ]]; then
    echo "Usage: cert-bundle <cert_file> <chain_file> [output_file]"
    echo ""
    echo "Creates a bundle with cert first, then chain."
    echo "Default output: bundle.crt"
    return 1
  fi

  if [[ ! -f "$cert_file" ]]; then
    echo "❌ Certificate file not found: $cert_file"
    return 1
  fi

  if [[ ! -f "$chain_file" ]]; then
    echo "❌ Chain file not found: $chain_file"
    return 1
  fi

  cat "$cert_file" "$chain_file" > "$output"
  echo "✅ Bundle created: $output"

  # Verify
  echo ""
  echo "Bundle contents:"
  openssl crl2pkcs7 -nocrl -certfile "$output" 2>/dev/null | \
    openssl pkcs7 -print_certs -noout 2>/dev/null | \
    grep -E "subject=|issuer=" | head -10
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
# myip - defined as function in .zshrc (shows both local and public IP)
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
  echo "HTTP/HEADERS:"
  echo "  headers URL        - Show HTTP headers"
  echo ""
  echo "SSL/TLS CERTIFICATES:"
  echo "  cert HOST          - Certificate summary"
  echo "  cert-test HOST     - Full SSL test suite (start here!)"
  echo "  cert-chain HOST    - Show all certs in chain"
  echo "  cert-verify HOST   - Verify chain completeness"
  echo "  cert-dates HOST    - Expiration with days remaining"
  echo "  cert-san HOST      - Subject Alternative Names"
  echo "  cert-download HOST - Save certificate to file"
  echo "  cert-help          - Full SSL/TLS help"
  echo ""
  echo "PFX FILES:"
  echo "  pfx-extract FILE   - Extract key, cert, chain from PFX"
  echo "  pfx-info FILE      - Show what's in a PFX file"
  echo "  cert-bundle C CH   - Create bundle from cert + chain"
  echo ""
  echo "MONITORING:"
  echo "  watchnet           - Watch connections live"
  echo "  speedtest          - Run internet speed test"
  echo "  bandwidth          - Monitor bandwidth usage"
  echo ""
  echo "💡 Type any command without args for usage help"
}
