#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# bind-extensions.sh — Bind Cursor to extensions duti can't handle.
#
# duti fails with `error -50` for extensions whose UTI lookup returns a
# dynamic UTI (.tsx, .toml, .fish, ...). This script tries to bind those via
# LSHandlerContentTag, then verifies which actually take effect. Entries that
# would conflict with another app's `LSHandlerRank = Owner` claim are removed
# so Finder doesn't pop up a "use Cursor or keep <other app>" dialog for every
# affected extension. macOS doesn't let those bindings be overridden
# programmatically — they need a one-time Finder fix per extension.
#
# Idempotent — safe to run repeatedly.
###############################################################################

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
BUNDLE="${CURSOR_BUNDLE_ID:-com.todesktop.230313mzl4w4u92}"
DOMAIN="com.apple.LaunchServices/com.apple.launchservices.secure"
LIST="$DOTFILES/duti/extensions-by-tag"

if [ ! -f "$LIST" ]; then
  echo "No $LIST — skipping extension bindings"
  exit 0
fi

EXTS=$(grep -v '^[[:space:]]*#' "$LIST" | tr -d ' \t' | grep -v '^$' | tr '\n' ' ')

# Add LSHandlerContentTag entries (idempotent — strips existing matches first).
python3 - "$DOMAIN" "$BUNDLE" $EXTS <<'PY'
import plistlib, subprocess, sys
domain, bundle, *exts = sys.argv[1:]
exported = subprocess.run(["defaults","export",domain,"-"], capture_output=True, check=True).stdout
data = plistlib.loads(exported) if exported.strip() else {}
handlers = data.get("LSHandlers", [])
def matches(h, ext):
    return (h.get("LSHandlerContentTagClass") == "public.filename-extension"
            and h.get("LSHandlerContentTag") == ext)
handlers = [h for h in handlers if not any(matches(h, e) for e in exts)]
for ext in exts:
    handlers.append({
        "LSHandlerContentTag": ext,
        "LSHandlerContentTagClass": "public.filename-extension",
        "LSHandlerRoleAll": bundle,
    })
data["LSHandlers"] = handlers
subprocess.run(["defaults","import",domain,"-"], input=plistlib.dumps(data), check=True)
PY

# Verify which extensions actually open in Cursor.
STRAGGLERS=$(xcrun swift - "$BUNDLE" $EXTS <<'SWIFT'
import Foundation
import AppKit
let args = CommandLine.arguments
let bundle = args[1]
var bad: [String] = []
for e in args.dropFirst(2) {
    let tmp = URL(fileURLWithPath: "/tmp/_bindcheck.\(e)")
    try? Data().write(to: tmp)
    defer { try? FileManager.default.removeItem(at: tmp) }
    let app = NSWorkspace.shared.urlForApplication(toOpen: tmp)
    if (app.flatMap { Bundle(url: $0)?.bundleIdentifier } ?? "") != bundle {
        bad.append(e)
    }
}
print(bad.joined(separator: " "))
SWIFT
)

# Remove entries that didn't take — otherwise Finder pops up a conflict dialog
# for each one on next launch.
if [ -n "$STRAGGLERS" ]; then
  python3 - "$DOMAIN" "$BUNDLE" $STRAGGLERS <<'PY'
import plistlib, subprocess, sys
domain, bundle, *exts = sys.argv[1:]
exported = subprocess.run(["defaults","export",domain,"-"], capture_output=True, check=True).stdout
data = plistlib.loads(exported)
handlers = data.get("LSHandlers", [])
def is_ours(h):
    return (h.get("LSHandlerContentTagClass") == "public.filename-extension"
            and h.get("LSHandlerContentTag") in exts
            and h.get("LSHandlerRoleAll") == bundle)
data["LSHandlers"] = [h for h in handlers if not is_ours(h)]
subprocess.run(["defaults","import",domain,"-"], input=plistlib.dumps(data), check=True)
PY
fi

killall cfprefsd 2>/dev/null || true

if [ -z "$STRAGGLERS" ]; then
  echo "Cursor is the default opener for: $EXTS"
else
  echo "Cursor is the default opener for the bindable extensions."
  echo "These extensions are owned by another app and need a one-time fix:"
  echo "  Finder → right-click a file → Get Info → Open with: Cursor → Change All…"
  echo "  Extensions: $STRAGGLERS"
fi
