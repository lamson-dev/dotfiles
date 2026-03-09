#!/bin/bash
# Resize focused AeroSpace window to 2/3 of the focused monitor's width.
# Uses osascript to get screen dimensions, then aerospace CLI to resize.
SCREEN_WIDTH=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | cut -d',' -f3 | tr -d ' ')
TARGET=$((SCREEN_WIDTH * 2 / 3))
aerospace move right
aerospace balance-sizes
aerospace resize width "$TARGET"
