# Network Debugging Toolkit

Complete network toolkit for ports, DNS, connections, SSL/TLS certificates, and more.

## Quick Reference

```bash
nethelp         # Show all commands
cert-help       # Show SSL certificate commands
```

---

## Port Management

```bash
ports              # List ALL listening ports (TCP & UDP)
port 8080          # Check if port is in use
killport 8080      # Kill process on port (with confirmation)
nextport 8000      # Find next available port starting from 8000
```

---

## Connections

```bash
connections        # Show active network connections
connto google.com  # Show connections to specific host
tcptest HOST PORT  # Test if TCP port is open
portscan HOST      # Scan common ports on host
```

---

## DNS

```bash
dns google.com     # Show all DNS records (A, AAAA, MX, NS, TXT)
rdns 8.8.8.8       # Reverse DNS lookup
dnstrace DOMAIN    # Trace DNS resolution path
dnsprop DOMAIN     # Check DNS propagation across servers
flushdns           # Flush DNS cache (macOS)
```

---

## Interfaces & IPs

```bash
interfaces         # Show all network interfaces
myips              # Show all local + public IPs
myip               # Show public IP only
localip            # Get local IP (macOS wifi)
publicip           # Get public IP
```

---

## Tunneling

```bash
tunnel             # Show SSH tunnel examples
tunnels            # List active SSH tunnels
```

---

## HTTP/Headers

```bash
headers URL        # Show HTTP headers
```

---

## SSL/TLS Certificates

Comprehensive certificate testing and debugging.

### Quick Commands

```bash
cert HOST              # Certificate summary (subject, issuer, dates)
cert-test HOST         # Full SSL test suite (start here!)
```

### Detailed Inspection

```bash
cert-chain HOST        # Show all certs in chain
cert-verify HOST       # Verify chain completeness
cert-dates HOST        # Expiration with days remaining
cert-san HOST          # Subject Alternative Names (covered domains)
```

### Utilities

```bash
cert-download HOST     # Download certificate to file
cert-raw HOST          # Full certificate details
sslcheck HOST          # Alias for 'cert'
```

### PFX File Operations

```bash
pfx-extract FILE       # Extract key, cert, chain from PFX (creates 4 files)
pfx-info FILE          # Show what's in a PFX file
cert-bundle CERT CHAIN # Create bundle from cert + chain files
```

**Example PFX workflow:**
```bash
# Extract all parts from PFX (will prompt for password)
pfx-extract wildcard_2026.pfx

# Creates:
#   wildcard_2026.key         - Private key
#   wildcard_2026.crt         - Server certificate
#   wildcard_2026-chain.crt   - CA chain
#   wildcard_2026-bundle.crt  - Full bundle for nginx
```

### Common SSL Errors

| Error | Meaning |
|-------|---------|
| `unable to get local issuer certificate` | Chain is incomplete - missing intermediate cert |
| `certificate has expired` | Renew the cert! |
| `hostname mismatch` | Cert doesn't cover this domain |

### Example Output

```bash
$ cert-test google.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SSL/TLS Test: google.com:443
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Connection Test
─────────────────────────────────────────────────────
   ✅ Connection successful

2. TLS Version
─────────────────────────────────────────────────────
   Protocol: TLSv1.3

3. Certificate Subject
─────────────────────────────────────────────────────
   CN = *.google.com

4. Issuer (CA)
─────────────────────────────────────────────────────
   C = US, O = Google Trust Services, CN = WR2

5. Expiration
─────────────────────────────────────────────────────
   Valid From:  Dec 16 08:36:04 2024 GMT
   Expires:     Mar 10 08:36:03 2025 GMT
   Status:      ✅ Valid (58 days left)

6. Chain Verification
─────────────────────────────────────────────────────
   ✅ Certificate chain is valid

7. curl Test
─────────────────────────────────────────────────────
   ✅ curl works (HTTP 200)
```

---

## Monitoring

```bash
watchnet           # Watch connections live
speedtest          # Run internet speed test (requires speedtest-cli)
bandwidth          # Monitor bandwidth usage (requires nload)
```

---

## Useful Aliases

```bash
netstat-listen     # Show listening ports (netstat)
netstat-established # Show established connections
ping               # Ping with 5 packets (auto-limited)
pingg              # Ping google.com
wget               # wget with auto-resume
```

---

## All Commands Reference

| Command | Description |
|---------|-------------|
| `ports` | List ALL listening ports |
| `port <n>` | Check if port is in use |
| `killport <n>` | Kill process on port |
| `nextport <n>` | Find next available port |
| `connections` | Show active connections |
| `connto <host>` | Connections to specific host |
| `tcptest <host> <port>` | Test TCP port |
| `portscan <host>` | Scan common ports |
| `dns <domain>` | All DNS records |
| `rdns <ip>` | Reverse DNS |
| `dnstrace <domain>` | DNS resolution path |
| `dnsprop <domain>` | DNS propagation check |
| `interfaces` | Network interfaces |
| `myips` | All local + public IPs |
| `tunnel` | SSH tunnel examples |
| `tunnels` | List SSH tunnels |
| `headers <url>` | HTTP headers |
| `cert <host>` | Certificate summary |
| `cert-test <host>` | Full SSL test |
| `cert-chain <host>` | Certificate chain |
| `cert-verify <host>` | Verify chain |
| `cert-dates <host>` | Expiration check |
| `cert-san <host>` | SAN entries |
| `cert-download <host>` | Download cert |
| `cert-raw <host>` | Raw cert details |
| `pfx-extract <file>` | Extract all from PFX |
| `pfx-info <file>` | Show PFX contents |
| `cert-bundle <c> <ch>` | Create bundle file |
| `watchnet` | Watch connections |
| `speedtest` | Speed test |
| `bandwidth` | Bandwidth monitor |
