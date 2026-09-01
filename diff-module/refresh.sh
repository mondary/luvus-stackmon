#!/bin/sh
# refresh.sh — dock DIFF : fichiers changés, icônes Nerd Font, stats +/−, clic = diff natif
BIN="${LUVUS_BIN_PATH:-luvus}"
DOCK="pk:diff"
CWD="${LUVUS_WORKSPACE_CWD:-$PWD}"

I_FILE='\357\205\233'; I_TS='\356\230\250';  I_JS='\356\235\216'; I_REACT='\356\236\272'
I_PY='\356\234\274';   I_JSON='\356\230\213'; I_MD='\357\222\212'; I_IMG='\357\207\205'
I_LOCK='\357\200\243'; I_SH='\357\222\211';  I_YML='\356\230\225'; I_CONF='\357\200\223'
I_CSS='\356\235\211';  I_HTML='\356\234\266'; I_RS='\356\236\250'; I_GO='\356\230\246'

icon_of() {
  case "$1" in
    *.ts|*.tsx)  printf "$I_TS" ;;
    *.js|*.mjs|*.cjs) printf "$I_JS" ;;
    *.jsx)       printf "$I_REACT" ;;
    *.py)        printf "$I_PY" ;;
    *.json)      printf "$I_JSON" ;;
    *.md|*.mdx)  printf "$I_MD" ;;
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.webp|*.ico) printf "$I_IMG" ;;
    *.lock)      printf "$I_LOCK" ;;
    *.sh|*.zsh)  printf "$I_SH" ;;
    *.yml|*.yaml) printf "$I_YML" ;;
    *.toml|*.ini|*.conf|*.cfg|*.env) printf "$I_CONF" ;;
    *.css|*.scss) printf "$I_CSS" ;;
    *.html)      printf "$I_HTML" ;;
    *.rs)        printf "$I_RS" ;;
    *.go)        printf "$I_GO" ;;
    *)           printf "$I_FILE" ;;
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
