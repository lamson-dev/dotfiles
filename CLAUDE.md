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

`setup-user.sh` uses Cursor as the default editor and routes both mechanisms below to its bundle ID. The duti config uses `__EDITOR_BUNDLE_ID__` as a placeholder that's substituted before duti runs.

- `duti/config` — extensions with **static UTIs** that LaunchServices accepts (e.g. `.js`, `.py`). `.html`/`.htm` are intentionally **not** bound: setting any handler for `public.html` (even role `editor`) makes macOS pop the "change your default web browser?" dialog on every run, so html is left to Chrome entirely.
- `duti/extensions-by-tag` — extensions that resolve to **dynamic UTIs** (e.g. `.tsx`, `.toml`, `.scss`, `.fish`). `scripts/bind-extensions.sh` strips stale `LSHandlers` entries pointing at other editors (usually leftovers from earlier "Use X" popup clicks), writes `LSHandlerContentTag` entries for the chosen editor, verifies each via `NSWorkspace.urlForApplication(toOpen:)`, and drops any that didn't take effect so Finder doesn't pop up a confirmation on every login.

Swift/Xcode project files intentionally excluded — they stay with Xcode.

### Switching editors triggers Finder popups

When the script changes a file-type default from one editor to another, macOS shows a "Do you want all documents with the extension X to open with A, or keep using B?" dialog per affected binding. Click the new editor on each to confirm; after that they don't recur. To avoid the popup cascade entirely, uninstall the previous editor before switching (`brew uninstall --cask cursor`).

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
