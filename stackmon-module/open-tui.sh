#!/bin/sh
# open-tui.sh — ouvre la TUI dans un vrai pane luvus (overlay)
# Déclenché par l'action open-tui : right-click pane, ou clic sur la ligne Σ du dock
BIN="${LUVUS_BIN_PATH:-luvus}"
exec "$BIN" module pane open "${LUVUS_MODULE_ID:-pk.stackmon}" tui
