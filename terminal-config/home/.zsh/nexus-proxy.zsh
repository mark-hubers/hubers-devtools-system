## -- nexus-proxy.zsh — point nxrm-xfer at the work tunnel, automatically.
## --
## -- Sets NXRM_XFER_PROXY when, and only when, a SOCKS tunnel is actually
## -- listening. nxrm-xfer reads that variable and nothing else on the machine
## -- does, which is the whole reason it exists.
## --
## -- WHY NOT JUST export HTTPS_PROXY IN .zshrc
## --
## -- HTTPS_PROXY is global. Set permanently, it sends curl, git, brew, npm, pip
## -- and every other tool down the same SSH tunnel: slower for everything, and
## -- broken for everything the moment the tunnel is down. So in practice it
## -- gets exported by hand per session and forgotten -- which is exactly how
## -- "could not reach Nexus" turns into an hour of network debugging.
## --
## -- NXRM_XFER_PROXY is read by nxrm-xfer alone. When the tunnel is down only
## -- that one tool is affected, and it says so.
## --
## -- WHY IT IS CONDITIONAL AND NOT JUST SET
## --
## -- On the work Mac, or on the VPN, Nexus is reachable directly and a proxy
## -- would be a pointless extra hop -- or a broken one, if the tunnel is not
## -- up. Setting the variable unconditionally would break the machine where
## -- everything already works. So: tunnel listening -> use it; nothing there ->
## -- say nothing and let the direct route work.
## --
## -- socks5h, NEVER socks5. The h resolves DNS AT THE PROXY. Measured
## -- 2026-08-29, same tunnel, same URL, one letter apart:
## --     socks5://    curl: (28) timed out       HTTP 000
## --     socks5h://   HTTP 200
## -- nexus.aws.alvaria.com is internal DNS and does not resolve out here at
## -- all, so plain socks5 fails before the request reaches the tunnel.

## Ports to look at, in order. 11080 is workproxy's own; the others are what a
## hand-rolled `ssh -D` usually lands on.
: ${NEXUS_PROXY_PORTS:="11080 9080 1080"}

## _nexus_proxy_port — the first port with something listening.
##
## ztcp, NOT /dev/tcp. /dev/tcp is a BASH feature and zsh does not have it: the
## probe failed silently on every shell, so the variable was never set even
## with a tunnel plainly listening on :9080. Found by running it rather than by
## reading it.
##
## ztcp is zsh's own and costs a connect() to loopback. lsof would work too and
## costs tens of milliseconds, which is real money on every new terminal - so
## it is only the fallback, for the rare zsh built without zsh/net/tcp.
##
## This only proves SOMETHING is listening, not that it is a SOCKS proxy. That
## is deliberate, and why nothing here is silent about its choice: `nxproxy`
## prints what was picked, and nxrm-xfer fails loudly rather than mysteriously
## if it is wrong.
_nexus_proxy_port() {
   local p
   if zmodload zsh/net/tcp 2>/dev/null; then
      for p in ${=NEXUS_PROXY_PORTS}; do
         if ztcp 127.0.0.1 "$p" 2>/dev/null; then
            ztcp -c "$REPLY" 2>/dev/null
            echo "$p"
            return 0
         fi
      done
      return 1
   fi
   for p in ${=NEXUS_PROXY_PORTS}; do
      if lsof -nP -iTCP:"$p" -sTCP:LISTEN -t >/dev/null 2>&1; then
         echo "$p"
         return 0
      fi
   done
   return 1
}

## Set it at shell start if a tunnel is already up. Silent by design: a message
## on every new terminal is noise, and `nxproxy` answers the question on demand.
_nexus_proxy_autoset() {
   [[ -n "${NXRM_XFER_PROXY:-}" ]] && return 0   ## already set by hand, leave it
   local port
   port="$(_nexus_proxy_port)" || return 0
   export NXRM_XFER_PROXY="socks5h://127.0.0.1:${port}"
}
_nexus_proxy_autoset

## nxproxy — say what nxrm-xfer will do, and fix it if the tunnel came up later.
##
## The common case is starting a terminal, THEN running `workproxy on`. This
## re-checks rather than requiring a new shell.
nxproxy() {
   case "${1:-status}" in
      on|refresh)
         unset NXRM_XFER_PROXY
         _nexus_proxy_autoset
         if [[ -n "${NXRM_XFER_PROXY:-}" ]]; then
            echo "-PASS- NXRM_XFER_PROXY=${NXRM_XFER_PROXY}"
         else
            echo "-INFO- no tunnel listening on: ${NEXUS_PROXY_PORTS}"
            echo "-INFO- start one with 'workproxy on', then 'nxproxy refresh'"
         fi
         ;;
      off)
         unset NXRM_XFER_PROXY
         echo "-INFO- NXRM_XFER_PROXY unset. nxrm-xfer will go direct."
         ;;
      status|*)
         if [[ -n "${NXRM_XFER_PROXY:-}" ]]; then
            echo "nxrm-xfer proxy : ${NXRM_XFER_PROXY}"
         else
            echo "nxrm-xfer proxy : <not set> (direct)"
         fi
         echo "checked ports   : ${NEXUS_PROXY_PORTS}"
         ## Only this tool. Worth stating, because the whole point is that
         ## nothing else on the machine is affected.
         echo "note            : only nxrm-xfer reads this. HTTPS_PROXY is untouched:"
         echo "                  HTTPS_PROXY=${HTTPS_PROXY:-<not set>}"
         ;;
   esac
}
