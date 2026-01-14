#!/bin/zsh
# ============================================================================
# Docker Aliases
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# ============================================================================

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dlogs='docker logs'
alias dlogsf='docker logs -f'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dprune='docker system prune -f'

# Interactive exec into container
dexec() {
  docker exec -it "$1" "${2:-bash}"
}
