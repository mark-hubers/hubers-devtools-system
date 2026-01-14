#!/bin/zsh
# ============================================================================
# SCP & Rsync Transfer Functions with FZF
# ============================================================================
# Managed by: hubers-devtools-system
# Do not edit - changes will be overwritten on update
# ============================================================================

# Helper: Select SSH host via fzf
_select_ssh_host() {
  awk '/^Host / && $2 !~ /\*/ {print $2}' ~/.ssh/config 2>/dev/null | fzf --height=40% --prompt="SSH Host> "
}

# Interactive SCP helper
scpd() {
  echo "SCP Helper - Easy file transfers"
  echo ""
  echo "1) Download from remote"
  echo "2) Upload to remote"
  read "choice?Choice (1/2): "

  case $choice in
    1)
      local host=$(_select_ssh_host)
      [[ -z "$host" ]] && echo "No host selected" && return 1
      read "remote_path?Remote path: "
      read "local_path?Local path (default: .): "
      scp -r "$host:$remote_path" "${local_path:-.}"
      ;;
    2)
      local local_file=$(fd --type f --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local> ")
      [[ -z "$local_file" ]] && echo "No file selected" && return 1
      local host=$(_select_ssh_host)
      [[ -z "$host" ]] && echo "No host selected" && return 1
      read "remote_path?Remote path: "
      scp -r "$local_file" "$host:$remote_path"
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
}

# rsync download
rget() {
  if [[ $# -eq 0 ]]; then
    local host=$(_select_ssh_host)
    [[ -z "$host" ]] && echo "No host selected" && return 1
    read "remote_path?Remote path: "
    read "local_path?Local path (default: .): "
    rsync -avzP "$host:$remote_path" "${local_path:-.}"
  elif [[ $# -eq 1 ]]; then
    rsync -avzP "$1" .
  else
    rsync -avzP "$1" "$2"
  fi
}

# rsync upload
rput() {
  if [[ $# -eq 0 ]]; then
    local local_file=$(fd --type f --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local> ")
    [[ -z "$local_file" ]] && echo "No file selected" && return 1
    local host=$(_select_ssh_host)
    [[ -z "$host" ]] && echo "No host selected" && return 1
    read "remote_path?Remote path: "
    rsync -avzP "$local_file" "$host:$remote_path"
  else
    rsync -avzP "$1" "$2"
  fi
}

# rsync sync with dry-run confirmation
rsync-sync() {
  if [[ $# -eq 0 ]]; then
    local local_dir=$(fd --type d --max-depth 3 2>/dev/null | fzf --height=40% --prompt="Local Dir> ")
    [[ -z "$local_dir" ]] && echo "No directory selected" && return 1
    local host=$(_select_ssh_host)
    [[ -z "$host" ]] && echo "No host selected" && return 1
    read "remote_path?Remote path: "
    echo "DRY RUN:"
    rsync -avzP --dry-run "$local_dir/" "$host:$remote_path"
    read "confirm?Proceed? (y/n): "
    [[ $confirm == "y" ]] && rsync -avzP "$local_dir/" "$host:$remote_path"
  else
    echo "DRY RUN:"
    rsync -avzP --dry-run "$1/" "$2"
    read "confirm?Proceed? (y/n): "
    [[ $confirm == "y" ]] && rsync -avzP "$1/" "$2"
  fi
}

# Browse remote directory
rbrowse() {
  local host=$(_select_ssh_host)
  [[ -z "$host" ]] && echo "No host selected" && return 1
  read "remote_path?Remote path (default: ~): "
  ssh "$host" "ls -lah ${remote_path:-~}"
}

alias scpi='scpd'
alias scphelp='echo "Download: scp HOST:PATH LOCAL\nUpload: scp LOCAL HOST:PATH"'
