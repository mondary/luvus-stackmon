#!/bin/sh
# reveal.sh — développe l'arborescence FILES native jusqu'au fichier cliqué
BIN="${LUVUS_BIN_PATH:-luvus}"
p="${LUVUS_MODULE_ROW_VALUE:-}"
[ -n "$p" ] && exec "$BIN" files reveal "$p"
