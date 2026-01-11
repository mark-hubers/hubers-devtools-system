# Package Manager fzf-tab previews for power users

# ============================================================================
# Homebrew (macOS/Linux)
# ============================================================================

### brew install: package info with dependencies ###
zstyle ':fzf-tab:complete:brew-install:*' fzf-preview \
'echo "🍺 Homebrew Package: $word"
echo "════════════════════════════════════════"
brew info $word 2>/dev/null || echo "Package not found"'

### brew uninstall: show what will be removed ###
zstyle ':fzf-tab:complete:brew-uninstall:*' fzf-preview \
'echo "⚠️  UNINSTALLING: $word"
echo "════════════════════════════════════════"
echo ""
brew info $word 2>/dev/null
echo ""
echo "════════════════════════════════════════"
echo "Dependencies that depend on this:"
brew uses --installed $word 2>/dev/null || echo "None"'

### brew upgrade: show current vs available ###
zstyle ':fzf-tab:complete:brew-upgrade:*' fzf-preview \
'echo "📦 Update Preview: $word"
echo ""
brew info $word 2>/dev/null || echo "Package not found"'

### brew search: package preview ###
zstyle ':fzf-tab:complete:brew-search:*' fzf-preview \
'brew info $word 2>/dev/null || echo "Searching for: $word"'

### brew services: service status ###
zstyle ':fzf-tab:complete:brew-services:*' fzf-preview \
'echo "🔧 Service: $word"
echo ""
brew services info $word 2>/dev/null || echo "Service not found"'

# ============================================================================
# npm (Node.js)
# ============================================================================

### npm install: package info from registry ###
zstyle ':fzf-tab:complete:npm-install:*' fzf-preview \
'echo "📦 npm Package: $word"
echo "════════════════════════════════════════"
if command -v npm &> /dev/null; then
  npm view $word 2>/dev/null || echo "Package not found in registry"
else
  echo "npm not available"
fi'

### npm uninstall: show installed version ###
zstyle ':fzf-tab:complete:npm-uninstall:*' fzf-preview \
'echo "⚠️  REMOVING: $word"
echo ""
npm list $word 2>/dev/null || echo "Package info not available"'

### npm run: show script from package.json ###
zstyle ':fzf-tab:complete:npm-run:*' fzf-preview \
'echo "🏃 npm script: $word"
echo ""
if [ -f package.json ]; then
  echo "Script definition:"
  cat package.json | jq -r ".scripts.\"$word\"" 2>/dev/null || echo "Script not found"
  echo ""
  echo "════════════════════════════════════════"
  echo "All scripts in package.json:"
  cat package.json | jq -r ".scripts" 2>/dev/null || echo "No scripts found"
else
  echo "No package.json found"
fi'

### npm view: detailed package info ###
zstyle ':fzf-tab:complete:npm-view:*' fzf-preview \
'npm view $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# yarn
# ============================================================================

### yarn add: package preview ###
zstyle ':fzf-tab:complete:yarn-add:*' fzf-preview \
'echo "🧶 yarn package: $word"
echo ""
npm view $word 2>/dev/null || echo "Package not found"'

### yarn run: show script ###
zstyle ':fzf-tab:complete:yarn-run:*' fzf-preview \
'echo "🏃 yarn script: $word"
echo ""
if [ -f package.json ]; then
  cat package.json | jq -r ".scripts.\"$word\"" 2>/dev/null || echo "Script not found"
fi'

# ============================================================================
# pip (Python)
# ============================================================================

### pip install: package info from PyPI ###
zstyle ':fzf-tab:complete:pip-install:*' fzf-preview \
'echo "🐍 pip Package: $word"
echo "════════════════════════════════════════"
if command -v pip &> /dev/null; then
  pip show $word 2>/dev/null || {
    echo "Not installed. Searching PyPI..."
    pip search $word 2>/dev/null | head -20 || echo "Cannot search PyPI"
  }
else
  echo "pip not available"
fi'

### pip uninstall: show installed package info ###
zstyle ':fzf-tab:complete:pip-uninstall:*' fzf-preview \
'echo "⚠️  REMOVING: $word"
echo ""
pip show $word 2>/dev/null || echo "Package info not available"'

### pip show: detailed package info ###
zstyle ':fzf-tab:complete:pip-show:*' fzf-preview \
'pip show $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# pipenv (Python)
# ============================================================================

### pipenv install: package info ###
zstyle ':fzf-tab:complete:pipenv-install:*' fzf-preview \
'echo "🐍 pipenv package: $word"
echo ""
pip show $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# poetry (Python)
# ============================================================================

### poetry add: package info ###
zstyle ':fzf-tab:complete:poetry-add:*' fzf-preview \
'echo "📝 poetry package: $word"
echo ""
pip show $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# cargo (Rust)
# ============================================================================

### cargo install: crate info ###
zstyle ':fzf-tab:complete:cargo-install:*' fzf-preview \
'echo "📦 Rust crate: $word"
echo "════════════════════════════════════════"
if command -v cargo &> /dev/null; then
  cargo search $word 2>/dev/null | head -20 || echo "Cannot search crates.io"
else
  echo "cargo not available"
fi'

### cargo uninstall: show installed crate ###
zstyle ':fzf-tab:complete:cargo-uninstall:*' fzf-preview \
'echo "⚠️  REMOVING crate: $word"
echo ""
ls ~/.cargo/bin/ | grep $word || echo "Crate: $word"'

# ============================================================================
# gem (Ruby)
# ============================================================================

### gem install: gem info ###
zstyle ':fzf-tab:complete:gem-install:*' fzf-preview \
'echo "💎 Ruby gem: $word"
echo ""
if command -v gem &> /dev/null; then
  gem search $word 2>/dev/null | head -20 || echo "Cannot search rubygems"
else
  echo "gem not available"
fi'

### gem uninstall: show installed gem ###
zstyle ':fzf-tab:complete:gem-uninstall:*' fzf-preview \
'gem list $word 2>/dev/null || echo "Gem: $word"'

# ============================================================================
# apt (Debian/Ubuntu)
# ============================================================================

### apt install: package info ###
zstyle ':fzf-tab:complete:apt-install:*' fzf-preview \
'echo "📦 apt package: $word"
echo ""
if command -v apt &> /dev/null; then
  apt show $word 2>/dev/null || echo "Package not found"
else
  echo "apt not available"
fi'

### apt remove: show what will be removed ###
zstyle ':fzf-tab:complete:apt-remove:*' fzf-preview \
'echo "⚠️  REMOVING: $word"
echo ""
apt show $word 2>/dev/null || echo "Package: $word"'

### apt search: package preview ###
zstyle ':fzf-tab:complete:apt-search:*' fzf-preview \
'apt show $word 2>/dev/null || echo "Searching for: $word"'

# ============================================================================
# yum/dnf (RHEL/Fedora)
# ============================================================================

### yum install: package info ###
zstyle ':fzf-tab:complete:yum-install:*' fzf-preview \
'echo "📦 yum package: $word"
echo ""
if command -v yum &> /dev/null; then
  yum info $word 2>/dev/null || echo "Package not found"
else
  echo "yum not available"
fi'

### dnf install: package info ###
zstyle ':fzf-tab:complete:dnf-install:*' fzf-preview \
'echo "📦 dnf package: $word"
echo ""
if command -v dnf &> /dev/null; then
  dnf info $word 2>/dev/null || echo "Package not found"
else
  echo "dnf not available"
fi'

# ============================================================================
# scoop (Windows)
# ============================================================================

### scoop install: package info ###
zstyle ':fzf-tab:complete:scoop-install:*' fzf-preview \
'echo "📦 scoop package: $word"
echo ""
if command -v scoop &> /dev/null; then
  scoop info $word 2>/dev/null || echo "Package not found"
else
  echo "scoop not available"
fi'

### scoop uninstall: show installed package ###
zstyle ':fzf-tab:complete:scoop-uninstall:*' fzf-preview \
'scoop info $word 2>/dev/null || echo "Package: $word"'

# ============================================================================
# winget (Windows)
# ============================================================================

### winget install: package info ###
zstyle ':fzf-tab:complete:winget-install:*' fzf-preview \
'echo "📦 winget package: $word"
echo ""
if command -v winget &> /dev/null; then
  winget show $word 2>/dev/null || echo "Package not found"
else
  echo "winget not available"
fi'

# ============================================================================
# asdf (Version Manager)
# ============================================================================

### asdf install: version preview ###
zstyle ':fzf-tab:complete:asdf-install:*' fzf-preview \
'echo "🔧 asdf: $word"
echo ""
asdf list all $word 2>/dev/null | tail -20 || echo "Plugin: $word"'

### asdf plugin-add: plugin info ###
zstyle ':fzf-tab:complete:asdf-plugin-add:*' fzf-preview \
'echo "🔌 asdf plugin: $word"
echo ""
asdf plugin list all | grep $word 2>/dev/null || echo "Plugin: $word"'

# ============================================================================
# go get (Go modules)
# ============================================================================

### go get: module info ###
zstyle ':fzf-tab:complete:go-get:*' fzf-preview \
'echo "🐹 Go module: $word"
echo ""
if command -v go &> /dev/null; then
  go list -m -versions $word 2>/dev/null || echo "Module: $word"
else
  echo "go not available"
fi'

# ============================================================================
# composer (PHP)
# ============================================================================

### composer require: package info ###
zstyle ':fzf-tab:complete:composer-require:*' fzf-preview \
'echo "🎵 Composer package: $word"
echo ""
if command -v composer &> /dev/null; then
  composer show $word 2>/dev/null || echo "Package not found"
else
  echo "composer not available"
fi'

### composer remove: show installed package ###
zstyle ':fzf-tab:complete:composer-remove:*' fzf-preview \
'composer show $word 2>/dev/null || echo "Package: $word"'
