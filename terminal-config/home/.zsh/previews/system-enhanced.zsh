# Enhanced System fzf-tab previews for power users

# ============================================================================
# File & Directory Operations (Enhanced)
# ============================================================================

### cd: enhanced directory listing with size and git info ###
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
'if command -v eza &> /dev/null; then
  eza -la --icons --git --color=always --group-directories-first $realpath 2>/dev/null
elif command -v exa &> /dev/null; then
  exa -la --icons --git --color=always --group-directories-first $realpath 2>/dev/null
else
  ls -lah --color=always $realpath 2>/dev/null
fi'

### ls: file preview with syntax highlighting for code ###
zstyle ':fzf-tab:complete:ls:*' fzf-preview \
'if [ -f $realpath ]; then
  if command -v bat &> /dev/null; then
    bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null
  else
    head -n 100 $realpath 2>/dev/null
  fi
elif [ -d $realpath ]; then
  if command -v eza &> /dev/null; then
    eza -la --icons --git --color=always $realpath 2>/dev/null
  else
    ls -lah --color=always $realpath 2>/dev/null
  fi
else
  echo "Unknown file type"
fi'

### rm: DANGER preview - show what you're about to delete ###
zstyle ':fzf-tab:complete:rm:*' fzf-preview \
'echo "⚠️  YOU ARE ABOUT TO DELETE:"
echo ""
if [ -f $realpath ]; then
  ls -lh --color=always $realpath 2>/dev/null
  echo ""
  echo "File contents preview:"
  head -n 20 $realpath 2>/dev/null
elif [ -d $realpath ]; then
  ls -lh --color=always $realpath 2>/dev/null
  echo ""
  echo "Directory contains:"
  ls -la --color=always $realpath 2>/dev/null | head -n 20
fi'

### mv/cp: show source and estimate time for large files ###
zstyle ':fzf-tab:complete:(mv|cp):*' fzf-preview \
'if [ -f $realpath ]; then
  ls -lh --color=always $realpath 2>/dev/null
  echo ""
  file $realpath 2>/dev/null
  echo ""
  echo "Size: $(du -h $realpath 2>/dev/null | cut -f1)"
elif [ -d $realpath ]; then
  ls -lh --color=always $realpath 2>/dev/null
  echo ""
  echo "Directory size: $(du -sh $realpath 2>/dev/null | cut -f1)"
  echo "Files: $(find $realpath -type f 2>/dev/null | wc -l)"
fi'

### chmod/chown: current permissions preview ###
zstyle ':fzf-tab:complete:(chmod|chown):*' fzf-preview \
'ls -l --color=always $realpath 2>/dev/null
echo ""
stat $realpath 2>/dev/null'

# ============================================================================
# File Content Tools
# ============================================================================

### cat: enhanced with syntax highlighting ###
zstyle ':fzf-tab:complete:cat:*' fzf-preview \
'if command -v bat &> /dev/null; then
  bat --color=always --style=full $realpath 2>/dev/null
else
  cat $realpath 2>/dev/null
fi'

### tail/head: show file with context ###
zstyle ':fzf-tab:complete:(tail|head):*' fzf-preview \
'echo "File: $realpath"
echo "Size: $(du -h $realpath 2>/dev/null | cut -f1)"
echo "Lines: $(wc -l < $realpath 2>/dev/null)"
echo ""
echo "Preview:"
if command -v bat &> /dev/null; then
  bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null
else
  head -n 50 $realpath 2>/dev/null
fi'

### less/more: file preview ###
zstyle ':fzf-tab:complete:(less|more):*' fzf-preview \
'if command -v bat &> /dev/null; then
  bat --color=always --style=full $realpath 2>/dev/null
else
  cat $realpath 2>/dev/null
fi'

### grep: show file with matching context ###
zstyle ':fzf-tab:complete:grep:*' fzf-preview \
'if [ -f $realpath ]; then
  if command -v bat &> /dev/null; then
    bat --color=always --style=numbers $realpath 2>/dev/null
  else
    cat -n $realpath 2>/dev/null
  fi
fi'

# ============================================================================
# File Info Tools
# ============================================================================

### file: detailed file type info ###
zstyle ':fzf-tab:complete:file:*' fzf-preview \
'file -b $realpath 2>/dev/null
echo ""
ls -lh --color=always $realpath 2>/dev/null
echo ""
if [ -f $realpath ]; then
  if command -v bat &> /dev/null; then
    bat --color=always --style=numbers --line-range=:30 $realpath 2>/dev/null
  else
    head -n 30 $realpath 2>/dev/null
  fi
fi'

### stat: full file statistics ###
zstyle ':fzf-tab:complete:stat:*' fzf-preview \
'stat $realpath 2>/dev/null
echo ""
ls -lh --color=always $realpath 2>/dev/null'

### du: disk usage with visualization ###
zstyle ':fzf-tab:complete:du:*' fzf-preview \
'echo "Disk usage for: $realpath"
echo ""
if [ -d $realpath ]; then
  du -h --max-depth=1 $realpath 2>/dev/null | sort -hr | head -n 20
else
  du -h $realpath 2>/dev/null
fi'

### df: filesystem info ###
zstyle ':fzf-tab:complete:df:*' fzf-preview \
'df -h $realpath 2>/dev/null'

# ============================================================================
# Process Management
# ============================================================================

### ps: detailed process info ###
zstyle ':fzf-tab:complete:ps:*' fzf-preview \
'[[ $group == "[process ID]" ]] && ps -f -p $word 2>/dev/null || echo $word'

### kill: process details before killing ###
zstyle ':fzf-tab:complete:kill:*' fzf-preview \
'[[ $group == "[process ID]" ]] && {
  ps -f -p $word 2>/dev/null
  echo ""
  echo "⚠️  You are about to kill this process!"
  echo ""
  lsof -p $word 2>/dev/null | head -n 20
} || echo $word'

### killall: show all matching processes ###
zstyle ':fzf-tab:complete:killall:*' fzf-preview \
'ps aux | grep -i $word | grep -v grep 2>/dev/null || echo "No processes found"'

# ============================================================================
# Archive Operations
# ============================================================================

### tar: show archive contents ###
zstyle ':fzf-tab:complete:tar:*' fzf-preview \
'if [ -f $realpath ]; then
  echo "Archive: $realpath"
  echo "Size: $(du -h $realpath 2>/dev/null | cut -f1)"
  echo ""
  echo "Contents:"
  tar -tzf $realpath 2>/dev/null || tar -tjf $realpath 2>/dev/null || echo "Cannot read archive"
fi'

### zip/unzip: show archive contents ###
zstyle ':fzf-tab:complete:(zip|unzip):*' fzf-preview \
'if [ -f $realpath ]; then
  echo "Archive: $realpath"
  echo "Size: $(du -h $realpath 2>/dev/null | cut -f1)"
  echo ""
  echo "Contents:"
  unzip -l $realpath 2>/dev/null || echo "Cannot read archive"
fi'

# ============================================================================
# System Information
# ============================================================================

### systemctl: service status (Linux) ###
zstyle ':fzf-tab:complete:systemctl:*' fzf-preview \
'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null || echo "Service: $word"'

### brew: package info (macOS) ###
zstyle ':fzf-tab:complete:brew:*' fzf-preview \
'brew info $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# Environment Variables
# ============================================================================

### export/env: show variable value ###
zstyle ':fzf-tab:complete:(export|env):*' fzf-preview \
'echo "Variable: $word"
echo "Value: ${(P)word}"
echo ""
echo "All environment variables with similar names:"
env | grep -i $word 2>/dev/null'

# ============================================================================
# Man Pages
# ============================================================================

### man: show man page preview ###
zstyle ':fzf-tab:complete:man:*' fzf-preview \
'man $word 2>/dev/null | col -bx | head -n 100 || echo "No man page for: $word"'

### which: show binary info ###
zstyle ':fzf-tab:complete:which:*' fzf-preview \
'which $word 2>/dev/null
echo ""
file $(which $word 2>/dev/null) 2>/dev/null
echo ""
ls -lh $(which $word 2>/dev/null) 2>/dev/null'
