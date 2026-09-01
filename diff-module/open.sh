#!/bin/sh
# open.sh — ouvre le diff natif Luvus pour le fichier cliqué
# LUVUS_MODULE_ROW_VALUE = "layer|chemin" (layer vide ou untracked)
BIN="${LUVUS_BIN_PATH:-luvus}"
v="${LUVUS_MODULE_ROW_VALUE:-}"
[ -n "$v" ] || exit 0
layer="${v%%|*}"
p="${v#*|}"
if [ "$layer" = "untracked" ]; then
  exec "$BIN" diff open "$p" --layer untracked
else
  exec "$BIN" diff open "$p"
fi
