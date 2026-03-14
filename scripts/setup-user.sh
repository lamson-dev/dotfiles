#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup-user.sh — User-level setup (no sudo required)
#
# Run as the target user:
#   cd ~/dotfiles && bash scripts/setup-user.sh
#
# What it does:
#   1. Oh My Zsh + plugins
#   2. NVM + Node
#   3. Dotfile symlinks
#   4. bat theme
#   5. Tmux Plugin Manager
#   6. Google Cloud SDK
#   7. File associations (duti)
#   8. macOS user preferences (defaults)
#
# Prereqs: Admin must have run setup-admin.sh first.
# Idempotent — safe to run multiple times.
###############################################################################

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

if [ ! -d "$DOTFILES" ]; then
  echo "Cloning dotfiles..."
  git clone "https://github.com/lamson-dev/dotfiles.git" "$DOTFILES"
fi

# Ensure Homebrew is on PATH
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

# Verify prerequisites
for cmd in brew git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd not found. Ask an admin to run: sudo bash scripts/setup-admin.sh $USER"
    exit 1
  fi
done

echo "Hello $(whoami)! Setting up your user environment."
echo ""

###############################################################################
# Oh My Zsh + plugins
###############################################################################
echo "==> Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh: already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

###############################################################################
# NVM + Node
###############################################################################
echo ""
echo "==> NVM + Node"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
if [ ! -s "$(brew --prefix nvm)/nvm.sh" ]; then
  echo "nvm installed via brew but nvm.sh not found — check brew info nvm"
else
  # shellcheck disable=SC1091
  . "$(brew --prefix nvm)/nvm.sh"
  if ! command -v node &>/dev/null; then
    echo "Installing latest LTS Node..."
    nvm install --lts
  else
    echo "Node: already installed ($(node --version))"
  fi
fi

###############################################################################
# Dotfiles symlinks
###############################################################################
echo ""
echo "==> Symlinks"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Backing up existing $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sf "$src" "$dst"
  echo "  $src → $dst"
}

link "$DOTFILES/.gitconfig"                "$HOME/.gitconfig"
link "$DOTFILES/.gitignore_global"         "$HOME/.gitignore_global"
link "$DOTFILES/.zshrc"                    "$HOME/.zshrc"
link "$DOTFILES/.zprofile"                 "$HOME/.zprofile"
link "$DOTFILES/.npmrc"                    "$HOME/.npmrc"

# Copy machine-local secrets template if it doesn't exist
if [ ! -f "$HOME/.zprofile.local" ]; then
  cp "$DOTFILES/.zprofile.local.example" "$HOME/.zprofile.local"
  echo "  Created ~/.zprofile.local from template — fill in your secrets"
fi

link "$DOTFILES/.config/starship.toml"     "$HOME/.config/starship.toml"
link "$DOTFILES/.config/.aerospace.toml"   "$HOME/.config/.aerospace.toml"
link "$DOTFILES/tmux/tmux.conf"            "$HOME/.tmux.conf"
link "$DOTFILES/ghostty/config"            "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

###############################################################################
# bat theme
###############################################################################
echo ""
echo "==> bat theme"
BAT_THEMES="$HOME/.config/bat/themes"
mkdir -p "$BAT_THEMES"
link "$DOTFILES/.config/bat/config" "$HOME/.config/bat/config"
if [ ! -d "$BAT_THEMES/night-owlish" ]; then
  git clone https://github.com/batpigandme/night-owlish "$BAT_THEMES/night-owlish"
fi
bat cache --build

###############################################################################
# Tmux Plugin Manager
###############################################################################
echo ""
echo "==> Tmux"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "  Open tmux and press Ctrl+Space, Shift+I to install plugins."
else
  echo "TPM: already installed"
fi

###############################################################################
# Google Cloud SDK
###############################################################################
echo ""
echo "==> Google Cloud SDK"
if [ ! -d "$HOME/google-cloud-sdk" ]; then
  echo "Installing Google Cloud SDK..."
  curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"
else
  echo "Google Cloud SDK: already installed"
fi

###############################################################################
# File associations — Cursor as default for code files
###############################################################################
echo ""
echo "==> File associations"
if command -v duti &>/dev/null; then
  duti "$DOTFILES/duti/config"
  echo "Cursor set as default for code files."
else
  echo "duti not found — skipping file associations"
fi

###############################################################################
# macOS user preferences
###############################################################################
echo ""
echo "==> macOS defaults"
bash "$DOTFILES/scripts/setup-macos-defaults.sh"

echo ""
echo "All done! A few manual steps remain:"
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo "  2. Open tmux and press Ctrl+Space, Shift+I to install tmux plugins"
echo "  3. Fill in secrets in ~/.zprofile.local"
echo "  4. Log into apps: 1Password, Chrome, Slack, Spotify, etc."
