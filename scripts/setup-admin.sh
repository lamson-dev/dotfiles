#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup-admin.sh — Machine-level setup (run once per Mac, requires sudo)
#
# Run as an admin user:
#   sudo bash scripts/setup-admin.sh [USERNAME]
#
# What it does:
#   1. Installs Xcode CLI tools
#   2. Installs Homebrew
#   3. Installs CLI tools, cask apps, and fonts via Homebrew
#   4. Adds Homebrew zsh to /etc/shells
#   5. Sets default shell for the target user
#
# Idempotent — safe to run multiple times.
###############################################################################

TARGET_USER="${1:-$USER}"

if [ "$(id -u)" -ne 0 ] && ! sudo -v 2>/dev/null; then
  echo "ERROR: This script requires sudo. Run as admin or with sudo."
  exit 1
fi

echo "Setting up machine for user: $TARGET_USER"
echo ""

# Keep sudo alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Xcode Command Line Tools
###############################################################################
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Waiting for Xcode CLI tools to finish installing..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
fi
echo "Xcode CLI tools: OK"

###############################################################################
# Homebrew
###############################################################################
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
echo "Homebrew: OK"

###############################################################################
# Fix Homebrew permissions for target user
###############################################################################
echo "Fixing Homebrew permissions for $TARGET_USER..."
sudo chown -R "$TARGET_USER" /opt/homebrew

###############################################################################
# CLI tools
###############################################################################
echo "Installing CLI tools..."
brew install \
  bat \
  duti \
  git \
  git-delta \
  nvm \
  starship \
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
# Shell — add Homebrew zsh to allowed shells and set for target user
###############################################################################
ZSH_PATH="/opt/homebrew/bin/zsh"
if ! grep -q "$ZSH_PATH" /etc/shells; then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi
sudo chsh -s "$ZSH_PATH" "$TARGET_USER"
echo "Default shell set to $ZSH_PATH for $TARGET_USER"

echo ""
echo "Admin setup complete! Now have $TARGET_USER run:"
echo "  cd ~/dotfiles && bash scripts/setup-user.sh"
