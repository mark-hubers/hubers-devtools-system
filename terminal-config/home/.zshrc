# ============================================================================
# Ultimate Developer .zshrc - Modular Configuration
# ============================================================================
# Managed by: hubers-devtools-system
# This file sources modular configs from ~/.zsh/{aliases.d,functions.d,path.d}
# For custom aliases/functions, create files in those dirs WITHOUT _devtools_ prefix
# For personal overrides, edit ~/.zshrc_local (never overwritten by installer)
# ============================================================================

# ============================================================================
# Completion System - MUST LOAD BEFORE OH-MY-ZSH
# ============================================================================

fpath=("$HOME/.zsh" $fpath)
autoload -Uz compinit
compinit

# Prevent dynamic function shadowing static completion
unset -f _kubectl 2>/dev/null
unset -f _microk8s_kubectl_completion 2>/dev/null
export KUBECTL_ENABLE_DYNAMIC_COMPLETION=false

# Source static kubectl completion if available
[[ -f "$HOME/.zsh/_kubectl_static" ]] && source "$HOME/.zsh/_kubectl_static"

# ============================================================================
# Oh-My-Zsh Core Setup
# ============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # No theme - Powerlevel10k handles the prompt
CASE_SENSITIVE="true"
DISABLE_AUTO_TITLE="true"
HIST_STAMPS="mm/dd/yyyy"

plugins=(
  git
  terraform
  asdf
  docker
  kubectl
  helm
  npm
  node
  python
  rust
  golang
  fzf
  fzf-tab
  zsh-autosuggestions
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Unalias commands that oh-my-zsh adds which can break scripts
unalias grep cat ls find 2>/dev/null

# ============================================================================
# Homebrew Environment
# ============================================================================

eval "$(/opt/homebrew/bin/brew shellenv)"

# ============================================================================
# PATH Configuration (Core)
# ============================================================================

# VSCode CLI
[[ -d "/Applications/Visual Studio Code.app" ]] && \
  export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# User bin directories
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Hubers Dev Tools framework detection
for possible_location in \
  "$HOME/my-tools/hubers-devtools-system" \
  "$HOME/hubers-devtools-system" \
  "$HOME/Projects/hubers-devtools-system" \
  "$HOME/repos/hubers-devtools-system" \
  "$HOME/mac-dev-setup" \
  "$HOME/Projects/mac-dev-setup"; do

  if [[ -f "$possible_location/bin/devsetup" ]]; then
    export DEVTOOLS_DIR="$possible_location"
    export PATH="$possible_location/bin:$PATH"
    break
  fi
done

# Additional PATH from path.d
for f in "$HOME/.zsh/path.d"/_devtools_*.zsh(N); do
  [[ -f "$f" ]] && source "$f"
done
for f in "$HOME/.zsh/path.d"/*.zsh(N); do
  [[ "$f" != */_devtools_* ]] && [[ -f "$f" ]] && source "$f"
done

# ============================================================================
# Load Modular Aliases (from ~/.zsh/aliases.d/)
# ============================================================================
# Files with _devtools_ prefix are managed by hubers-devtools-system
# Your custom files (without prefix) are loaded after and never touched

for f in "$HOME/.zsh/aliases.d"/_devtools_*.zsh(N); do
  [[ -f "$f" ]] && source "$f"
done
for f in "$HOME/.zsh/aliases.d"/*.zsh(N); do
  [[ "$f" != */_devtools_* ]] && [[ -f "$f" ]] && source "$f"
done

# ============================================================================
# Load Modular Functions (from ~/.zsh/functions.d/)
# ============================================================================
# Files with _devtools_ prefix are managed by hubers-devtools-system
# Your custom files (without prefix) are loaded after and never touched

for f in "$HOME/.zsh/functions.d"/_devtools_*.zsh(N); do
  [[ -f "$f" ]] && source "$f"
done
for f in "$HOME/.zsh/functions.d"/*.zsh(N); do
  [[ "$f" != */_devtools_* ]] && [[ -f "$f" ]] && source "$f"
done

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR='code --wait'
export VISUAL='code --wait'
export PAGER=""
export AWS_PAGER=""

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS

# Locale (cross-platform)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export LANG="${LANG:-en_US.UTF-8}"
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
else
  export LANG=en_US.UTF-8
fi

# Terraform
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
export TERRAGRUNT_DOWNLOAD="$HOME/.terraform.d/terragrunt"

# ============================================================================
# ASDF Version Manager
# ============================================================================

if [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
elif [[ -f /usr/local/opt/asdf/libexec/asdf.sh ]]; then
  . /usr/local/opt/asdf/libexec/asdf.sh
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  . "$HOME/.asdf/asdf.sh"
fi

# ============================================================================
# fzf Configuration
# ============================================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Catppuccin Mocha theme
export FZF_DEFAULT_OPTS="--preview-window=right:60%:wrap --ansi --height 60% --layout=reverse --border --inline-info \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons --git --color=always {}'"

# ============================================================================
# fzf-tab Configuration
# ============================================================================

zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' switch-group ',' '.'

zstyle ':fzf-tab:*' fzf-preview \
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

# Load preview modules
for file in ~/.zsh/previews/*.zsh(N); do
  [[ -r "$file" ]] && source "$file"
done

# ============================================================================
# Toolkits (loaded from ~/.zsh/)
# ============================================================================

[[ -f ~/.zsh/network-toolkit.zsh ]] && source ~/.zsh/network-toolkit.zsh
[[ -f ~/.zsh/aws-sso-toolkit.zsh ]] && source ~/.zsh/aws-sso-toolkit.zsh
[[ -f ~/.zsh/github-cli-toolkit.zsh ]] && source ~/.zsh/github-cli-toolkit.zsh
[[ -f ~/.zsh/bookmarks.zsh ]] && source ~/.zsh/bookmarks.zsh
[[ -f ~/.zsh/markdown-toolkit.zsh ]] && source ~/.zsh/markdown-toolkit.zsh
[[ -f ~/.zsh/favorites.zsh ]] && source ~/.zsh/favorites.zsh
[[ -f ~/.zsh/project-status.zsh ]] && source ~/.zsh/project-status.zsh

# ============================================================================
# iTerm2 Integration
# ============================================================================

export COLORTERM=truecolor

if [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -n "$ITERM_SESSION_ID" ]]; then
    export ITERM2_DETECTED=1
    [[ -f ~/.iterm2_shell_integration.zsh ]] && source ~/.iterm2_shell_integration.zsh

    imgcat() {
        [[ -x ~/.iterm2/imgcat ]] && ~/.iterm2/imgcat "$@" || echo "Run: brew install imgcat"
    }
    title() { echo -ne "\033]0;$*\007"; }
    badge() { printf "\e]1337;SetBadgeFormat=%s\a" $(echo -n "$*" | base64); }
    clearbadge() { printf "\e]1337;SetBadgeFormat=\a"; }
    notify() {
        local msg="${1:-Done}"
        osascript -e "display notification \"$msg\" with title \"Terminal\"" 2>/dev/null
        printf "\e]9;%s\a" "$msg"
    }
    tabcolor() { printf "\e]6;1;bg;red;brightness;%s\a\e]6;1;bg;green;brightness;%s\a\e]6;1;bg;blue;brightness;%s\a" "$1" "$2" "$3"; }
    tabreset() { printf "\e]6;1;bg;*;default\a"; }
    tabwork() { tabcolor 255 100 100; badge "WORK"; }
    tabprod() { tabcolor 255 50 50; badge "PROD"; }
    tabdev() { tabcolor 100 255 100; badge "DEV"; }

    # SSH with auto profile switch
    ssh() {
        local host=""
        for arg in "$@"; do [[ "$arg" != -* ]] && host="$arg" && break; done
        if [[ -n "$host" ]]; then
            local profile=$(grep -A5 "Host $host" ~/.ssh/config 2>/dev/null | grep "# iTerm2Profile:" | cut -d: -f2 | tr -d ' ')
            [[ -n "$profile" ]] && echo -ne "\033]50;SetProfile=$profile\a"
        fi
        command ssh "$@"
        echo -ne "\033]50;SetProfile=Default\a"
    }
else
    export ITERM2_DETECTED=0
    imgcat() { echo "Requires iTerm2"; }
    badge() { :; }
    clearbadge() { :; }
fi

# ============================================================================
# Powerlevel10k Prompt
# ============================================================================

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ============================================================================
# Extensions Hook (for external projects)
# ============================================================================
# Projects install *.zsh files to ~/.zsh/extensions.d/ and they load here
# Loaded BEFORE ~/.zshrc_local so user can override extension aliases

if [[ -d "$HOME/.zsh/extensions.d" ]]; then
  for _ext in "$HOME/.zsh/extensions.d"/*.zsh(N); do
    [[ -f "$_ext" ]] && source "$_ext"
  done
  unset _ext
fi

# ============================================================================
# Favorites Startup
# ============================================================================

if type _favorites_startup &>/dev/null; then
  _favorites_startup
fi

# Disable bracketed paste
unset zle_bracketed_paste

# ============================================================================
# User customizations loaded from ~/.zshrc_local (never overwritten by setup)
# ============================================================================
[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local

# ============================================================================
# PRESERVE BELOW - Everything after this line is kept when setup updates .zshrc
# ============================================================================
# Tools like iTerm2, nvm, conda, etc. append lines here - they won't be lost!
