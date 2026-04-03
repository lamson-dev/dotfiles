# Homebrew (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# openjdk (if installed via Homebrew)
[ -d "$HOMEBREW_PREFIX/opt/openjdk/bin" ] && export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"

# Claude Code CLI
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

export EDITOR=cursor

# Source machine-local overrides (secrets, project-specific config)
[ -f "$HOME/.zprofile.local" ] && . "$HOME/.zprofile.local"
