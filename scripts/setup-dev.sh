#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup-dev.sh — Dev tooling, apps, shell, and dotfile symlinks
# Expects: Homebrew installed, dotfiles repo cloned
# Run via setup-macos.sh or directly: bash scripts/setup-dev.sh
###############################################################################

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Ensure Homebrew is on PATH (needed when run from setup-macos.sh in same session)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true

###############################################################################
# CLI tools
###############################################################################
echo "Installing CLI tools..."
brew install \
  bat \
  duti \
  git-delta \
  nvm \
  starship \
  pulumi \
  tree \
  vim \
  zellij \
  zsh

###############################################################################
# Cask apps
###############################################################################
echo "Installing apps..."
brew install --cask \
  1password \
  cursor \
  dropbox \
  firefox \
  ghostty \
  google-chrome \
  nikitabobko/tap/aerospace \
  slack \
  spotify \
  zoom

###############################################################################
# Fonts
###############################################################################
echo "Installing fonts..."
brew install --cask font-fira-code

###############################################################################
# Shell — set Homebrew zsh as default
###############################################################################
ZSH_PATH="/opt/homebrew/bin/zsh"
if sudo -v 2>/dev/null; then
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  if [ "$SHELL" != "$ZSH_PATH" ]; then
    sudo chsh -s "$ZSH_PATH" "$USER"
  fi
else
  echo "  Skipping shell change (no sudo). Ask an admin to run:"
  echo "    echo '$ZSH_PATH' | sudo tee -a /etc/shells"
  echo "    sudo chsh -s '$ZSH_PATH' $USER"
fi

###############################################################################
# Oh My Zsh + plugins
###############################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
  fi
fi

###############################################################################
# Bun
###############################################################################
if ! command -v bun &>/dev/null; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
fi

###############################################################################
# Dotfiles symlinks
###############################################################################
echo "Creating symlinks..."

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
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "  Open tmux and press Ctrl+Space, Shift+I to install plugins."
fi

###############################################################################
# Google Cloud SDK
###############################################################################
if [ ! -d "$HOME/google-cloud-sdk" ]; then
  echo "Installing Google Cloud SDK..."
  curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"
fi

###############################################################################
# File associations — Cursor as default for code files
###############################################################################
echo "Setting Cursor as default for code files..."
duti "$DOTFILES/duti/config"

echo "Dev tooling setup complete."
