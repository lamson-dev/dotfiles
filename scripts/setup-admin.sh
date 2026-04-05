#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# setup-admin.sh — Machine setup & user provisioning (requires sudo)
#
# Full machine setup (run once on a new Mac):
#   bash scripts/setup-admin.sh
#
# Add a user to an already-setup machine:
#   bash scripts/setup-admin.sh --user USERNAME
#
# Idempotent — safe to run multiple times.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"

# Parse arguments
ADD_USER_ONLY=false
TARGET_USER=""
if [ "${1:-}" = "--user" ]; then
  ADD_USER_ONLY=true
  TARGET_USER="${2:-}"
  if [ -z "$TARGET_USER" ]; then
    echo "Usage: bash scripts/setup-admin.sh --user USERNAME"
    exit 1
  fi
fi

if ! sudo -v 2>/dev/null; then
  echo "ERROR: This script requires sudo. Run as admin."
  exit 1
fi

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Machine setup (skipped with --user)
###############################################################################
if [ "$ADD_USER_ONLY" = false ]; then
  echo "==> Setting up this Mac..."
  echo ""

  # Xcode Command Line Tools
  if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Waiting for Xcode CLI tools to finish installing..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi
  echo "Xcode CLI tools: OK"

  # Homebrew
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  echo "Homebrew: OK"

  # CLI tools
  echo "Installing CLI tools..."
  brew install \
    bat \
    codex \
    duti \
    gh \
    git \
    git-delta \
    nvm \
    pnpm \
    pulumi \
    starship \
    tree \
    vim \
    zellij \
    zsh

  # Cask apps
  echo "Installing apps..."

  # Stop Tailscale before install/upgrade — its installer fails while the daemon is running
  TAILSCALE_WAS_RUNNING=false
  if pgrep -q "[Tt]ailscale" 2>/dev/null; then
    TAILSCALE_WAS_RUNNING=true
    echo "Stopping Tailscale for upgrade..."
    osascript -e 'quit app "Tailscale"' 2>/dev/null || true
    sudo killall tailscaled 2>/dev/null || true
    sudo killall Tailscale 2>/dev/null || true
    sudo killall "Tailscale IPNExtension" 2>/dev/null || true
    sleep 3
  fi

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
    tailscale \
    zoom

  # Restart Tailscale if it was running before
  if [ "$TAILSCALE_WAS_RUNNING" = true ]; then
    echo "Restarting Tailscale..."
    open -a Tailscale
  fi

  # Fonts
  echo "Installing fonts..."
  brew install --cask font-fira-code

  # Add Homebrew zsh to allowed shells
  ZSH_PATH="/opt/homebrew/bin/zsh"
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi

  # Fix permissions for shared Homebrew usage
  # Remove group/other write (Homebrew security), but ensure read+execute
  # so non-admin users can access zsh functions, completions, etc.
  echo "Fixing Homebrew permissions..."
  sudo chmod -R go-w /opt/homebrew/share
  sudo chmod -R o+rX /opt/homebrew/share
  sudo chmod -R o+rX /opt/homebrew/Cellar/zsh

  echo ""
  echo "Machine setup complete!"

  # Set up the admin's own account
  TARGET_USER="$USER"
fi

###############################################################################
# User provisioning
###############################################################################
echo ""
echo "==> Setting up user: $TARGET_USER"

# Verify user exists
if ! id "$TARGET_USER" &>/dev/null; then
  echo "ERROR: User '$TARGET_USER' does not exist on this machine."
  exit 1
fi

# Set default shell
ZSH_PATH="/opt/homebrew/bin/zsh"
CURRENT_SHELL=$(dscl . -read "/Users/$TARGET_USER" UserShell 2>/dev/null | awk '{print $2}')
if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
  sudo chsh -s "$ZSH_PATH" "$TARGET_USER"
  echo "Shell: set to $ZSH_PATH"
else
  echo "Shell: already $ZSH_PATH"
fi

# Grant Homebrew access
sudo dseditgroup -o edit -a "$TARGET_USER" -t user admin 2>/dev/null || true

# Run user setup as target user
echo ""
echo "Running user setup as $TARGET_USER..."
sudo -u "$TARGET_USER" -i bash -c "
  cd \$HOME/dotfiles 2>/dev/null || git clone https://github.com/lamson-dev/dotfiles.git \$HOME/dotfiles
  cd \$HOME/dotfiles && git pull --ff-only && bash scripts/setup-user.sh
"

echo ""
echo "Done! $TARGET_USER is ready to go."
