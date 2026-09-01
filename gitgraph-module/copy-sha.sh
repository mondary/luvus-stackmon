#!/bin/sh
# copy-sha.sh — copie le SHA du commit cliqué (pbcopy sur macOS, xclip/xsel sinon)
BIN="${LUVUS_BIN_PATH:-luvus}"
sha="${LUVUS_MODULE_ROW_VALUE:-}"
[ -n "$sha" ] || exit 0

if command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$sha" | pbcopy && "$BIN" ui toast "SHA $sha copié"
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$sha" | xclip -selection clipboard && "$BIN" ui toast "SHA $sha copié"
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$sha" | xsel --clipboard --input && "$BIN" ui toast "SHA $sha copié"
else
  "$BIN" ui toast "$sha"
fi
