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
| `.zshrc` | `~/.zshrc` |
| `.zprofile` | `~/.zprofile` |
| `.npmrc` | `~/.npmrc` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` (copied) |
| `claude/fetch-usage.sh` | `~/.claude/fetch-usage.sh` (copied) |
| `claude/settings.json` | `~/.claude/settings.json` (merged) |

## File Associations

Code extensions map to Cursor (`com.todesktop.230313mzl4w4u92`) via two mechanisms applied by `setup-user.sh`:

- `duti/config` — extensions with **static UTIs** that LaunchServices accepts (e.g. `.js`, `.html`, `.py`). Applied with `duti ~/dotfiles/duti/config`.
- `duti/extensions-by-tag` — extensions that resolve to **dynamic UTIs** (e.g. `.tsx`, `.toml`, `.scss`, `.fish`). duti can't bind these (`error -50` for `dyn.*` UTIs), so `scripts/bind-extensions.sh` writes `LSHandlerContentTag` entries via `defaults import`, verifies each via `NSWorkspace.urlForApplication(toOpen:)`, and **removes any that didn't actually take effect** — leaving them in place would trigger a Finder "use Cursor or keep <other app>" dialog on every login.

Swift/Xcode project files intentionally excluded — they stay with Xcode.

### Antigravity / multi-editor caveat

If another editor (e.g. Antigravity) declares `LSHandlerRank = Owner` for a code extension in its `Info.plist`, **macOS doesn't allow programmatic override** — `LSSetDefaultRoleHandlerForContentType` returns success but the change doesn't stick. `bind-extensions.sh` reports the affected extensions and a one-time manual fix is required:

> Finder → right-click a file with that extension → **Get Info** → **Open with: Cursor** → **Change All…**

After that, the choice persists. Uninstalling Antigravity (or any editor not in active use) is the cleanest way to avoid these conflicts.

## Adding New Configs

1. Create the config file under `~/dotfiles/` in a sensible directory
2. Symlink it to where the tool expects it
3. Update the symlink map above

## Key Details

- **Tmux prefix**: `Ctrl+Space` (not the default `Ctrl+B`)
- **Tmux plugins**: Managed by TPM (`~/.tmux/plugins/tpm`). After symlinking the config, install TPM with `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then open tmux and press `Ctrl+Space, Shift+I` to install plugins
- **Ghostty**: Must have `macos-option-as-alt = true` for tmux Alt keybindings
- **Git pager**: Uses `delta` with `night-owlish` theme
- **Prompt**: Starship
- **Window manager**: AeroSpace
- **archive/**: Legacy configs (bash, zsh, vim) — not actively symlinked, kept for reference
