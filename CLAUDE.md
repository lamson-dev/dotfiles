# Dotfiles

Personal dotfiles for Son Nguyen on macOS.

## Symlink Convention

All configs live in `~/dotfiles/` and are symlinked to their expected locations. When adding or modifying configs, always edit the file in this repo, never the symlink target.

### Symlink Map

| Source | Target |
|--------|--------|
| `.gitconfig` | `~/.gitconfig` |
| `.gitignore_global` | `~/.gitignore_global` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config` |
| `.config/starship.toml` | `~/.config/starship.toml` |
| `.config/.aerospace.toml` | `~/.config/.aerospace.toml` |
| `.config/bat/` | `~/.config/bat/` |

## Adding New Configs

1. Create the config file under `~/dotfiles/` in a sensible directory
2. Symlink it to where the tool expects it
3. Update the symlink map above

## Key Details

- **Tmux prefix**: `Ctrl+Space` (not the default `Ctrl+B`)
- **Tmux plugins**: Managed by TPM (`~/.tmux/plugins/tpm`)
- **Ghostty**: Must have `macos-option-as-alt = true` for tmux Alt keybindings
- **Git pager**: Uses `delta` with `night-owlish` theme
- **Prompt**: Starship
- **Window manager**: AeroSpace
- **archive/**: Legacy configs (bash, zsh, vim) — not actively symlinked, kept for reference
