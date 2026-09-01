#!/bin/sh
# refresh.sh — dock DIFF : fichiers changés, icônes Nerd Font, stats +/−, clic = diff natif
BIN="${LUVUS_BIN_PATH:-luvus}"
DOCK="pk:diff"
CWD="${LUVUS_WORKSPACE_CWD:-$PWD}"

icon_of() {
  case "$1" in
    *.ts|*.tsx)  printf '' ;;
    *.js|*.mjs|*.cjs) printf '' ;;
    *.jsx)       printf '' ;;
    *.py)        printf '' ;;
    *.json)      printf '' ;;
    *.md|*.mdx)  printf '' ;;
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.webp|*.ico) printf '' ;;
    *.lock)      printf '' ;;
    *.sh|*.zsh)  printf '' ;;
    *.yml|*.yaml) printf '' ;;
    *.toml|*.ini|*.conf|*.cfg|*.env) printf '' ;;
    *.css|*.scss) printf '' ;;
    *.html)      printf '' ;;
    *.rs)        printf '' ;;
    *.go)        printf '' ;;
    *)           printf '' ;;
  esac
}

cd "$CWD" || exit 1
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  "$BIN" ui dock push --id "$DOCK" --title "DIFF · ${CWD##*/}" --rows '[{"text":"pas un repo git","dot":"idle"}]'
  exit 0
}

PORCELAIN=$(git status --porcelain 2>/dev/null)
NUMSTAT=$(git diff HEAD --numstat 2>/dev/null)

# totaux
ADDED=$(printf '%s\n' "$NUMSTAT" | awk '{a+=$1} END {print a+0}')
DELETED=$(printf '%s\n' "$NUMSTAT" | awk '{d+=$2} END {print d+0}')
COUNT=$(printf '%s\n' "$PORCELAIN" | grep -c . )

ROWS="{\"text\":\"$COUNT fichier(s)  +$ADDED −$DELETED\",\"dot\":\"working\"},"

while IFS= read -r line; do
  [ -n "$line" ] || continue
  xy=$(printf '%s' "$line" | cut -c1-2)
  p=$(printf '%s' "$line" | cut -c4-)
  [ -n "$p" ] || continue
  stats=$(printf '%s\n' "$NUMSTAT" | awk -v f="$p" '$3==f {printf "+%s −%s", $1, $2}')
  case "$xy" in
    '??') dot="idle";     [ -n "$stats" ] || stats="non suivi" ;;
    *D*|'D') dot="blocked"; [ -n "$stats" ] || stats="supprimé" ;;
    'A'*|' A') dot="done" ;;
    *)    dot="working" ;;
  esac
  esc=$(printf '%s' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
  name=$(printf '%s' "${p##*/}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  layer=""; case "$xy" in '??') layer="untracked" ;; esac
  ROWS="${ROWS}{\"text\":\"$(icon_of "$p") $name  $stats\",\"dot\":\"$dot\",\"action\":\"open\",\"value\":\"$layer|$esc\"},"
done <<EOF
$PORCELAIN
EOF

printf '%s' "$ROWS" | "$BIN" ui dock push --id "$DOCK" --title "DIFF · ${CWD##*/}" --rows "[${ROWS%,}]"
