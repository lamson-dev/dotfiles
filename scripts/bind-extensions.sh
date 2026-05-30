#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# bind-extensions.sh — Make the preferred editor the default opener for
# extensions duti can't handle (dyn-UTI extensions like .tsx, .toml, .fish).
#
# Strategy:
#   1. For each extension, resolve its UTI via Swift's modern UTType API.
#   2. Remove stale LSHandlers entries pointing at any *other* bundle for that
#      extension or its UTI — those are usually leftovers from the user
#      clicking "Use X" in a previous Finder popup, and they out-rank the
#      target editor's native Info.plist claim.
#   3. Write an LSHandlerContentTag entry pointing at the target bundle.
#   4. Verify via NSWorkspace; drop entries that still didn't take effect so
#      they don't trigger a "use X or keep Y" popup on next login.
###############################################################################

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

if [ -z "${EDITOR_BUNDLE_ID:-}" ]; then
  for app in /Applications/Antigravity.app /Applications/Cursor.app; do
    if [ -d "$app" ]; then
      EDITOR_BUNDLE_ID="$(mdls -name kMDItemCFBundleIdentifier -r "$app" 2>/dev/null)"
      break
    fi
  done
fi
if [ -z "${EDITOR_BUNDLE_ID:-}" ]; then
  echo "No editor app found — skipping"
  exit 0
fi
BUNDLE="$EDITOR_BUNDLE_ID"
DOMAIN="com.apple.LaunchServices/com.apple.launchservices.secure"
LIST="$DOTFILES/duti/extensions-by-tag"

if [ ! -f "$LIST" ]; then
  echo "No $LIST — skipping extension bindings"
  exit 0
fi

EXTS=$(grep -v '^[[:space:]]*#' "$LIST" | tr -d ' \t' | grep -v '^$' | tr '\n' ' ')

# Resolve each extension to its current UTI via Swift (modern API sees
# UTIs registered by apps like Antigravity that duti's older lookup misses).
EXT_UTI_PAIRS=$(xcrun swift - $EXTS <<'SWIFT'
import Foundation
import UniformTypeIdentifiers
for e in CommandLine.arguments.dropFirst() {
    let id = UTType(filenameExtension: e)?.identifier ?? ""
    print("\(e)\t\(id)")
}
SWIFT
)

# Clear stale entries pointing at any other bundle, then add ours.
python3 - "$DOMAIN" "$BUNDLE" <<PY
import plistlib, subprocess, sys
domain, bundle = sys.argv[1:]
pairs = [line.split("\t") for line in """$EXT_UTI_PAIRS""".strip().splitlines() if line]
exts = {p[0] for p in pairs}
utis = {p[1] for p in pairs if len(p) > 1 and p[1]}

exported = subprocess.run(["defaults","export",domain,"-"], capture_output=True, check=True).stdout
data = plistlib.loads(exported) if exported.strip() else {}
handlers = data.get("LSHandlers", [])

def is_tag_match(h, ext_set):
    return (h.get("LSHandlerContentTagClass") == "public.filename-extension"
            and h.get("LSHandlerContentTag") in ext_set)
def is_uti_match(h, uti_set):
    return h.get("LSHandlerContentType") in uti_set

# Drop any handler entry for our extensions/UTIs that doesn't already point at
# our bundle (those are stale Cursor/Antigravity choices from prior popups).
def keep(h):
    if is_tag_match(h, exts) or is_uti_match(h, utis):
        return h.get("LSHandlerRoleAll") == bundle
    return True
handlers = [h for h in handlers if keep(h)]

# Add fresh tag-based bindings.
for ext in exts:
    handlers.append({
        "LSHandlerContentTag": ext,
        "LSHandlerContentTagClass": "public.filename-extension",
        "LSHandlerRoleAll": bundle,
    })

data["LSHandlers"] = handlers
subprocess.run(["defaults","import",domain,"-"], input=plistlib.dumps(data), check=True)
PY

# Also try LSSetDefaultRoleHandlerForContentType for each UTI — this works
# where Swift's caller context lets the API switch the binding (it silently
# no-ops for some UTI/bundle combinations).
xcrun swift - "$BUNDLE" $EXTS >/dev/null 2>&1 <<'SWIFT' || true
import Foundation
import CoreServices
import UniformTypeIdentifiers
let args = CommandLine.arguments
let bundle = args[1]
for e in args.dropFirst(2) {
    if let t = UTType(filenameExtension: e) {
        _ = LSSetDefaultRoleHandlerForContentType(t.identifier as CFString, .all, bundle as CFString)
    }
}
SWIFT

# Verify and clean up stragglers so they don't trigger Finder popups.
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
  echo "$BUNDLE is the default opener for: $EXTS"
else
  echo "$BUNDLE is the default opener for the bindable extensions."
  echo "These extensions are owned by another app and need a one-time fix:"
  echo "  Finder → right-click a file → Get Info → Open with → Change All…"
  echo "  Extensions: $STRAGGLERS"
fi
