#!/bin/sh
# open.sh — ouvre le fichier cliqué dans la vue Luvus (LUVUS_MODULE_ROW_VALUE = chemin relatif)
BIN="${LUVUS_BIN_PATH:-luvus}"
p="${LUVUS_MODULE_ROW_VALUE:-}"
[ -n "$p" ] && exec "$BIN" files open "$p"
