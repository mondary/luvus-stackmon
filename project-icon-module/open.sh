#!/bin/sh
# open.sh — ouvre le pane image du workspace ciblé
BIN="${LUVUS_BIN_PATH:-luvus}"
exec "$BIN" module pane open "${LUVUS_MODULE_ID:-pk.project-icon}" icon --placement overlay
