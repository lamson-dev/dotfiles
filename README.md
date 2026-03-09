# dotfiles

Personal dotfiles for macOS. Managed with symlinks.

## Structure

```
dotfiles/
├── .gitconfig              # Git config (aliases, delta pager, LFS)
├── .gitignore_global       # Global gitignore
├── .zshrc                  # Zsh config (oh-my-zsh, aliases, nvm)
├── .zprofile               # Login shell (Homebrew, PATH, EDITOR)
├── .zprofile.local.example # Template for machine-local secrets
├── .npmrc                  # npm registry config
├── .macos                  # One-liner bootstrap for a fresh Mac
├── .config/
│   ├── .aerospace.toml     # AeroSpace window manager
│   ├── bat/                # bat (cat replacement) config
│   └── starship.toml       # Starship prompt
├── ghostty/
│   └── config              # Ghostty terminal config
├── tmux/
│   └── tmux.conf           # tmux config (Ctrl+Space prefix, vim-tmux-navigator)
├── scripts/
│   ├── setup-dev.sh        # Dev tooling, apps, shell, symlinks
│   ├── setup-macos-defaults.sh  # macOS system preferences
│   └── aerospace-resize.sh # AeroSpace window resize helper
└── archive/                # Legacy configs (bash, zsh, vim) — not actively used
```

## Installation

Bootstrap a fresh Mac with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/lamson-dev/dotfiles/master/.macos | bash
```

This will:
1. Install Xcode CLI tools and Homebrew
2. Clone this repo to `~/dotfiles`
3. Install CLI tools and apps via Homebrew (`scripts/setup-dev.sh`)
4. Create symlinks for all configs
5. Set macOS system preferences (`scripts/setup-macos-defaults.sh`)

To re-run just the dev tooling and symlinks (no macOS defaults):

```bash
bash ~/dotfiles/scripts/setup-dev.sh
```

## Post-install

1. Restart your terminal (or `source ~/.zshrc`)
2. Open tmux and press `Ctrl+Space, Shift+I` to install tmux plugins
3. Fill in secrets in `~/.zprofile.local` (API keys, tokens, project config)
4. Log into apps: 1Password, Chrome, Slack, Spotify, etc.

## Secrets

Shared shell config (`.zprofile`) is committed to the repo. Machine-local secrets live in `~/.zprofile.local`, which is git-ignored and never committed.

The setup script copies `.zprofile.local.example` → `~/.zprofile.local` on first run. Fill in your API keys and tokens there.

## Tmux

Prefix is `Ctrl+Space`. Most bindings use `Alt` (no prefix needed).

Setup:

```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux, then install plugins
tmux
# Press: Ctrl+Space, Shift+I to install plugins
```

Plugins (managed by TPM):
- `tmux-open` — open URLs/files from copy mode with `o`
- `tmux-resurrect` — save/restore sessions (`Ctrl+Space, Ctrl+s` / `Ctrl+Space, Ctrl+r`)
- `tmux-continuum` — auto-saves sessions every 15 min
- `tmux-prefix-highlight` — status bar flashes when prefix is pressed

## Ghostty

Requires `macos-option-as-alt = true` for tmux Alt bindings to work.
