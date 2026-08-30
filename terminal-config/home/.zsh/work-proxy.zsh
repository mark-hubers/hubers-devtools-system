## -- work-proxy.zsh — reach INTERNAL Alvaria hosts from a machine that cannot
## -- see them, by borrowing the work Mac's network with an SSH SOCKS proxy.
## --
## -- Source from ~/.zshrc:   source ~/.zsh/work-proxy.zsh
## --
## -- WHY A SHELL FUNCTION AND NOT A SCRIPT
## --
## -- It has to EXPORT into the shell you are typing in. A script runs in a
## -- child process and its exports die with it. Same reason awsid and ghid are
## -- sourced functions rather than files in ~/bin.
## --
## -- WHAT IT IS
## --
## -- `ssh -D` opens a real SOCKS5 proxy: anything that speaks SOCKS routes
## -- through the work Mac BY HOSTNAME. That is the difference from `ssh -L`,
## -- which pins one host to one local port -- one tunnel covers Nexus,
## -- Bitbucket and everything else inside, and every tool keeps using the
## -- real hostname, so TLS certificates validate normally. No --insecure,
## -- no host-header games, no /etc/hosts edits.
## --
## -- It is the terminal equivalent of SwitchyOmega in the browser.
## --
## -- WHAT USES IT
## --
## --   nxrm-xfer          yes. Go's http.DefaultTransport reads HTTPS_PROXY,
## --                      including socks5:// URLs. PROVEN 2026-08-29 from the
## --                      Mac Studio: whoami went from "could not reach Nexus"
## --                      to "-PASS- can see 103 repositories" with nothing
## --                      changed but this variable.
## --   curl, git, gh      yes, all read the same variables.
## --   the PowerShell     NO. Checked 2026-08-29: nexus-tools has no
## --   nexus-tools        network-proxy support at all. Every "proxy" in that
## --                      repo is the nxrm-public-proxy hostname or a Nexus
## --                      "proxy repository". Run those on the work Mac.
## --
## -- NOTHING HERE IS EVASIVE. It is your own SSH access to your own work Mac,
## -- using the stock OpenSSH client, exactly as `ssh` already appears in that
## -- machine's logs. If a tool needs to be hidden to be used, it is the wrong
## -- tool -- that is a conversation with IT, not a flag.

## Local SOCKS port. High and specific so it cannot collide with the 18443
## port-forward nexus-admin-api uses.
: ${WORK_PROXY_PORT:=11080}
: ${WORK_PROXY_HOST:=work-mac}

## _workproxy_pid — the ssh holding the SOCKS port, by PORT not by pattern.
##
## FOUND BY TESTING, 2026-08-29: `pkill -f "ssh -f -N -D 11080"` matched
## NOTHING while the tunnel was live. `ssh -f` daemonises and the surviving
## process does not carry the original argv, so a pattern kill silently does
## nothing -- and `workproxy off` cheerfully reported success while the tunnel
## stayed up. A tool that lies about being off is worse than no tool.
##
## Checking `nc -z` was the other half of the same bug: a listening port only
## proves SOMETHING is there, not that it is our proxy.
##
## lsof asks the only question that matters: who owns this port right now.
## It also avoids `pgrep -fl` / `ps -ww`, which print other processes' whole
## environment -- that leaked an API key from a Cursor helper on 2026-08-07.
_workproxy_pid() {
   lsof -nP -iTCP:"${WORK_PROXY_PORT}" -sTCP:LISTEN -t 2>/dev/null | head -1 | grep .
}

workproxy() {
   local cmd="${1:-status}"

   case "$cmd" in
      on)
         if _workproxy_pid >/dev/null; then
            echo "-INFO- tunnel already up on :${WORK_PROXY_PORT}"
         else
            ## ControlPath=none IS THE FIX, not an optimisation.
            ##
            ## ~/.ssh/config sets ControlMaster auto + ControlPersist 8h. With
            ## those, the -D forward attaches to the SHARED master connection:
            ## measured 2026-08-29, the listener survived a TERM and
            ## `workproxy off` reported success while the proxy stayed up for
            ## the rest of the 8 hours.
            ##
            ## Killing the master instead would be worse -- it would drop
            ## every other ssh session to this host at the same time.
            ##
            ## So the tunnel gets its OWN connection. It costs one extra
            ## handshake and it is the only version that can actually be
            ## turned off.
            ssh -f -N -D "$WORK_PROXY_PORT" -o ConnectTimeout=10 \
                -o ControlPath=none -o ControlMaster=no \
                -o ExitOnForwardFailure=yes "$WORK_PROXY_HOST" || {
               echo "-ERROR- could not open the tunnel to ${WORK_PROXY_HOST}" >&2
               return 1
            }
            sleep 1
            echo "-PASS- tunnel up: ${WORK_PROXY_HOST} -> socks5://127.0.0.1:${WORK_PROXY_PORT}"
         fi

         ## socks5h, NOT socks5. The h means "resolve the hostname AT THE
         ## PROXY". Measured 2026-08-29 on the Mac Studio, same tunnel, same
         ## URL, one letter apart:
         ##
         ##   socks5://   curl: (28) Connection timed out    HTTP 000
         ##   socks5h://  HTTP 200
         ##
         ## nexus.aws.alvaria.com is internal DNS, so it does not resolve out
         ## here at all -- with plain socks5 curl fails before it ever reaches
         ## the tunnel. Go is more forgiving (it hands the hostname to the
         ## SOCKS server either way, which is why nxrm-xfer worked with socks5
         ## and misled the first test), but it accepts socks5h too. One value
         ## for every tool is worth more than being right about Go.
         ##
         ## Both spellings of the variable. Some tools only read lower-case,
         ## and being half-proxied is worse than not being proxied: it works
         ## for some hosts and not others, which reads as a network fault.
         export HTTPS_PROXY="socks5h://127.0.0.1:${WORK_PROXY_PORT}"
         export HTTP_PROXY="$HTTPS_PROXY"
         export https_proxy="$HTTPS_PROXY"
         export http_proxy="$HTTPS_PROXY"

         ## Keep localhost and the local network direct. Without this, a
         ## request to 127.0.0.1 goes out to the work Mac and comes back to
         ## ITS localhost, which is a different machine and a confusing hour.
         export NO_PROXY="localhost,127.0.0.1,::1,*.local"
         export no_proxy="$NO_PROXY"

         echo "-INFO- HTTPS_PROXY set. 'workproxy off' when done."
         ;;

      off)
         unset HTTPS_PROXY HTTP_PROXY https_proxy http_proxy NO_PROXY no_proxy
         local pid
         pid="$(_workproxy_pid)" && kill "$pid" 2>/dev/null
         sleep 1
         if _workproxy_pid >/dev/null; then
            echo "-WARNING- variables unset, but something still holds :${WORK_PROXY_PORT}"
            echo "-WARNING- check it: lsof -nP -iTCP:${WORK_PROXY_PORT} -sTCP:LISTEN"
         else
            echo "-PASS- proxy off, tunnel closed"
         fi
         ;;

      status)
         ## "IS THERE A USABLE PROXY", NOT "DID I START ONE".
         ##
         ## This used to report only its OWN tunnel on WORK_PROXY_PORT. On
         ## 2026-08-30 it printed "tunnel : down" while a perfectly good SOCKS
         ## tunnel was listening on :9080 -- so the answer was true and useless,
         ## and the next thing anybody does is run `workproxy on`, which then
         ## fails to bind and falls back to a port that dies with its shell.
         ##
         ## Same failure as everything else that day: answering a question
         ## adjacent to the one being asked.
         if _workproxy_pid >/dev/null; then
            echo "tunnel : UP on :${WORK_PROXY_PORT} (via ${WORK_PROXY_HOST}, ours)"
         else
            echo "tunnel : down on :${WORK_PROXY_PORT} (ours)"
         fi

         ## Anything else listening that could serve as a proxy. Ports only, by
         ## lsof -- never pgrep -fl or ps -ww, which print other processes'
         ## whole environment and once leaked an API key.
         local other found="" first=""
         for other in 9080 1080 8080 11080; do
            [[ "$other" == "${WORK_PROXY_PORT}" ]] && continue
            if lsof -nP -iTCP:"$other" -sTCP:LISTEN -t >/dev/null 2>&1; then
               found="${found} :${other}"
               [[ -z "$first" ]] && first="$other"
            fi
         done
         if [[ -n "$found" ]]; then
            echo "other  : something is also listening on${found}"
            echo "         if one of those is a SOCKS tunnel, use it directly:"
            ## first, not a substring of the display string -- ${found## }
            ## still carried the leading colon and produced 127.0.0.1::9080,
            ## a command that cannot be pasted. A suggestion that does not run
            ## is worse than none.
            echo "         export HTTPS_PROXY=socks5h://127.0.0.1:${first}"
         fi

         echo "env    : ${HTTPS_PROXY:-<not set>}"

         ## socks5 without the h resolves DNS LOCALLY, so an internal hostname
         ## fails in a way that looks like the server is down. Measured: curl
         ## with socks5 timed out where socks5h answered in 0.25s.
         if [[ "${HTTPS_PROXY:-}" == socks5://* ]]; then
            echo "         -WARNING- socks5:// resolves DNS locally. Use socks5h://"
         fi
         ;;

      test)
         ## Proves the whole path, not just the socket. A listening port only
         ## says ssh is alive; this says an internal host actually answers.
         if [[ -z "${HTTPS_PROXY:-}" ]]; then
            echo "-WARNING- HTTPS_PROXY is not set. Run 'workproxy on' first." >&2
         fi
         echo -n "nexus.aws.alvaria.com : "
         curl -sS -o /dev/null -m 20 -w "HTTP %{http_code}\n" \
            "https://nexus.aws.alvaria.com/nexus/service/rest/v1/status" \
            2>&1 || echo "unreachable"
         ;;

      *)
         cat <<'HELP'
workproxy — borrow the work Mac's network over SSH SOCKS

   workproxy on       open the tunnel and export HTTPS_PROXY
   workproxy off      unset and close it
   workproxy status   is it up, and is the variable set
   workproxy test     does an internal host actually answer

Per shell. Another terminal keeps its own setting, which is deliberate:
one window talking to internal Nexus while another stays on the open
internet is usually what you want.

The PowerShell nexus-tools do NOT read these variables. Run those on the
work Mac itself.
HELP
         ;;
   esac
}
