# dotfiles

Shared dotfiles for macOS. Managed with symlinks. Supports multiple users on the same machine.

## Quick Start

### New Mac (admin)

One command to set up the machine and your admin account:

```bash
curl -fsSL https://raw.githubusercontent.com/lamson-dev/dotfiles/master/.macos | bash
```

### Add another user (admin)

From the admin account, set up a new user with one command:

```bash
cd ~/dotfiles && bash scripts/setup-admin.sh --user USERNAME
```

This sets their shell, grants Homebrew access, clones dotfiles, and configures their environment — no need to log in as that user.

### Self-setup (no admin needed)

If the machine is already set up, any user can configure themselves:

```bash
curl -fsSL https://raw.githubusercontent.com/lamson-dev/dotfiles/master/scripts/setup-user.sh | bash
```

## What gets installed

### Machine-level (admin, once)

- Xcode CLI tools
- Homebrew
- CLI tools: bat, delta, duti, nvm, starship, tree, vim, zellij, zsh
- Apps: 1Password, Cursor, Dropbox, Firefox, Ghostty, Chrome, AeroSpace, Slack, Spotify, Zoom
- Fonts: Fira Code

### Per-user (each user)

- Oh My Zsh + plugins (syntax highlighting, autosuggestions)
- Node via nvm
- Dotfile symlinks (.gitconfig, .zshrc, .zprofile, starship, aerospace, ghostty, bat, tmux)
- Google Cloud SDK
- File associations (Cursor as default editor)
- macOS preferences (Finder, Activity Monitor, TextEdit, etc.)

## Git Identity

Git identity is auto-detected per user via `includeIf` in `.gitconfig`. Each user has their own identity file:

```
.gitconfig.user.dalab-tech   → Son Nguyen <lamson-dev@users.noreply.github.com>
.gitconfig.user.dalab-yolo   → Dang Nguyen <nsdang@users.noreply.github.com>
.gitconfig.user.dalab-anton  → Anton <anton-dalab@users.noreply.github.com>
.gitconfig.user.lamson-dev   → Son Nguyen <lamson-dev@users.noreply.github.com>
```

To add a new user's identity, create `.gitconfig.user.USERNAME` and add an `includeIf` block to `.gitconfig`.

## Post-install

1. Restart your terminal (or `source ~/.zshrc`)
2. Open tmux and press `Ctrl+Space, Shift+I` to install tmux plugins
3. Fill in secrets in `~/.zprofile.local` (API keys, tokens)
4. Log into apps: 1Password, Chrome, Slack, Spotify, etc.

## Structure

```
dotfiles/
├── .macos                     # Entry point — full bootstrap
├── .gitconfig                 # Shared git config (includeIf for identity)
├── .gitconfig.user.*          # Per-user git identity files
├── .gitignore_global          # Global gitignore
├── .zshrc                     # Zsh config (oh-my-zsh, aliases, nvm)
├── .zprofile                  # Login shell (Homebrew, PATH, EDITOR)
├── .zprofile.local.example    # Template for machine-local secrets
├── .npmrc                     # npm registry config
├── .config/
│   ├── .aerospace.toml        # AeroSpace window manager
│   ├── bat/                   # bat (cat replacement) config
│   └── starship.toml          # Starship prompt
├── ghostty/config             # Ghostty terminal config
├── tmux/tmux.conf             # tmux config (Ctrl+Space prefix)
├── duti/config                # File association mappings
└── scripts/
    ├── setup-admin.sh         # Machine setup + add user (requires sudo)
    ├── setup-user.sh          # User config (no sudo needed)
    └── setup-macos-defaults.sh  # macOS preferences
```

## Secrets

Machine-local secrets live in `~/.zprofile.local` (git-ignored, never committed). The setup script copies `.zprofile.local.example` on first run.

## Tmux

Prefix: `Ctrl+Space`. Most bindings use `Alt` (no prefix needed).

Plugins (managed by TPM):
- `tmux-open` — open URLs/files from copy mode with `o`
- `tmux-resurrect` — save/restore sessions
- `tmux-continuum` — auto-saves sessions every 15 min
- `tmux-prefix-highlight` — status bar indicator

## Ghostty

Requires `macos-option-as-alt = true` for tmux Alt bindings.
