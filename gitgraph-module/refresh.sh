#!/bin/sh
# refresh.sh — dock GIT : graphe git --all en rows + branche courante en tête, clic = copier SHA
BIN="${LUVUS_BIN_PATH:-luvus}"
DOCK="pk:gitgraph"
CWD="${LUVUS_WORKSPACE_CWD:-$PWD}"
LIMIT=25

cd "$CWD" || exit 1
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  "$BIN" ui dock push --id "$DOCK" --title "GIT · ${CWD##*/}" --rows '[{"text":"pas un repo git","dot":"idle"}]'
  exit 0
}

BRANCH=$(git branch --show-current 2>/dev/null)
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

ROWS="{\"text\":\" $BRANCH  ↑$AHEAD ↓$BEHIND\",\"dot\":\"done\"},"

T=$(mktemp)
git log --graph --oneline --all --decorate --color=never --max-count="$LIMIT" 2>/dev/null |
while IFS= read -r line; do
  [ -n "$line" ] || continue
  esc=$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')
  sha=$(printf '%s' "$line" | grep -oE '\b[0-9a-f]{7,10}\b' | head -1)
  # dot : HEAD → working, sinon aucun
  case "$line" in
    *'HEAD'*) d=",\"dot\":\"working\"" ;;
    *) d="" ;;
  esac
  if [ -n "$sha" ]; then
    printf '{"text":"%s"%s,"action":"copy-sha","value":"%s"},' "$esc" "$d" "$sha"
  else
    printf '{"text":"%s"%s},' "$esc" "$d"
  fi
done > "$T"
ROWS="$ROWS$(cat "$T")"
rm -f "$T"

printf '%s' "$ROWS" | "$BIN" ui dock push --id "$DOCK" --title "GIT · ${CWD##*/}" --rows "[${ROWS%,}]"
