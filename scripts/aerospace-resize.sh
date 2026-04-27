#!/bin/bash
# Resize focused AeroSpace window to 2/3 of the focused monitor's width.
# Get the focused monitor's width via aerospace
MONITOR_WIDTH=$(aerospace list-monitors --focused --format '%{monitor-width}' 2>/dev/null)

# Fallback: use AppleScript to get the screen size of the frontmost window's screen
if [ -z "$MONITOR_WIDTH" ]; then
    MONITOR_WIDTH=$(osascript -e '
        use framework "AppKit"
        set mainScreen to current application'\''s NSScreen'\''s mainScreen()
        set screenFrame to mainScreen'\''s frame()
        set screenWidth to item 1 of item 2 of screenFrame
        return screenWidth as integer
    ')
fi

TARGET=$((MONITOR_WIDTH * 2 / 3))
aerospace move right
aerospace balance-sizes
aerospace resize width "$TARGET"
