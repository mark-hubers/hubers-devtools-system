# SSH fzf-tab preview - Shows SSH config details

# Preview for ssh command
zstyle ':fzf-tab:complete:ssh:*' fzf-preview '
echo "SSH Connection: $word"
echo "════════════════════════════════════════"
echo ""
echo "Config expansion (ssh -G):"
ssh -G $word 2>/dev/null | head -20
echo ""
echo "════════════════════════════════════════"
echo "Config stanza from ~/.ssh/config:"
grep -i -A10 -B1 "^Host[[:space:]]\+$word" ~/.ssh/config 2>/dev/null || echo "No config entry"
'

# Preview for scp command
zstyle ':fzf-tab:complete:scp:*' fzf-preview '
if [[ $word == *:* ]]; then
  echo "Remote: $word"
  ssh -G ${word%%:*} 2>/dev/null | head -15
else
  echo "Local: $word"
  ls -lah $word 2>/dev/null
fi
'

# Preview for sftp command  
zstyle ':fzf-tab:complete:sftp:*' fzf-preview '
echo "SFTP to: $word"
ssh -G $word 2>/dev/null | head -15
'
