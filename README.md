# dotfiles

Personal dotfiles for macOS. Managed with symlinks.

## Structure

```
dotfiles/
├── .gitconfig              # Git config (aliases, delta pager, LFS)
├── .gitignore_global        # Global gitignore
├── .macos                   # macOS system preferences script
├── .config/
│   ├── .aerospace.toml      # AeroSpace window manager
│   ├── bat/                 # bat (cat replacement) config
│   └── starship.toml        # Starship prompt
├── ghostty/
│   └── config               # Ghostty terminal config
├── tmux/
│   └── tmux.conf            # tmux config (Ctrl+Space prefix, vim-tmux-navigator)
└── archive/                 # Legacy configs (bash, zsh, vim) - not actively used
```

## Installation

Symlink each config to its expected location:

```bash
# Git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.gitignore_global ~/.gitignore_global

# Tmux
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf

# Ghostty
ln -sf ~/dotfiles/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config

# Starship
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml

# AeroSpace
ln -sf ~/dotfiles/.config/.aerospace.toml ~/.config/.aerospace.toml

# bat
ln -sf ~/dotfiles/.config/bat ~/.config/bat
```

## Tmux

Prefix is `Ctrl+Space`. Most bindings use `Alt` (no prefix needed).

Requires [TPM](https://github.com/tmux-plugins/tpm):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then press: Ctrl+Space, I (capital i) to install plugins
```

## Ghostty

Requires `macos-option-as-alt = true` for tmux Alt bindings to work.
