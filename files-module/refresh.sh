#!/bin/sh
# refresh.sh — dock FILES : arborescence (2 niveaux) avec icônes Nerd Font + état git par fichier
BIN="${LUVUS_BIN_PATH:-luvus}"
DOCK="pk:files"
CWD="${LUVUS_WORKSPACE_CWD:-$PWD}"
MAX_ROWS=40
PRUNE="-name .git -o -name node_modules -o -name .venv -o -name venv -o -name dist -o -name build -o -name __pycache__ -o -name vendor"

# icônes Nerd Font via octal UTF-8 (les littéraux PUA sont strips par certains outils)
I_DIR='\357\201\273';   I_FILE='\357\205\233'; I_TS='\356\230\250';  I_JS='\356\235\216'
I_REACT='\356\236\272'; I_PY='\356\234\274';   I_JSON='\356\230\213'; I_MD='\357\222\212'
I_IMG='\357\207\205';   I_LOCK='\357\200\243'; I_SH='\357\222\211';   I_YML='\356\230\225'
I_CONF='\357\200\223';  I_CSS='\356\235\211';  I_HTML='\356\234\266'; I_RS='\356\236\250'
I_GO='\356\230\246';    I_DB='\357\207\200'

# icône Nerd Font selon type/extension
icon_of() {
  case "$1" in
    dir)         printf "$I_DIR" ;;
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
    *.sql|*.db|*.sqlite) printf "$I_DB" ;;
    *)           printf "$I_FILE" ;;
  esac
}

# état git (porcelain XY) : working=modifié, done=ajouté, blocked=supprimé, idle=non suivi
dot_of() {
  line=$(printf '%s\n' "$GITOUT" | grep -E "^.?.? +${1}\$" | head -1)
  case "$line" in
    ''|'  ') ;;
    '??'*) printf 'idle' ;;
    '?'*|' ?'*) printf 'idle' ;;
    'D'*|' D'*) printf 'blocked' ;;
    'A'*|' A'*) printf 'done' ;;
    *) printf 'working' ;;
  esac
}

cd "$CWD" || exit 1
GITOUT=$(git status --porcelain 2>/dev/null)

LIST=$({ find . -maxdepth 2 \( $PRUNE \) -prune -o -type d -print; \
         find . -maxdepth 2 \( $PRUNE \) -prune -o -type f -print; } 2>/dev/null \
       | sed 's|^\./||; /^$/d' | awk '!seen[$0]++' | head -"$MAX_ROWS")
TOTAL=$(find . -maxdepth 2 \( $PRUNE \) -prune -o -print 2>/dev/null | sed 's|^\./||; /^$/d' | wc -l | tr -d ' ')

ROWS=""
while IFS= read -r p; do
  [ -n "$p" ] || continue
  depth=$(printf '%s' "$p" | awk -F/ '{print NF-1}')
  indent=""; i=0; while [ "$i" -lt "$depth" ]; do indent="  $indent"; i=$((i+1)); done
  if [ -d "$p" ]; then
    icon=$(icon_of dir); dot=""
  else
    name="${p##*/}"
    icon=$(icon_of "$name"); dot=$(dot_of "$p")
  fi
  if [ -n "$dot" ]; then D=",\"dot\":\"$dot\""; else D=""; fi
  esc=$(printf '%s' "${p##*/}" | sed 's/\\/\\\\/g; s/"/\\"/g')
  ep=$(printf '%s' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
  ROWS="$ROWS{\"text\":\"$indent$icon $esc\"$D,\"action\":\"open\",\"value\":\"$ep\"},"
done <<EOF
$LIST
EOF

[ "$TOTAL" -gt "$MAX_ROWS" ] && ROWS="${ROWS}{\"text\":\"… +$TOTAL entrées\",\"dot\":\"idle\"},"

if [ -n "$ROWS" ]; then
  printf '%s' "$ROWS" | "$BIN" ui dock push --id "$DOCK" --title "FILES · ${CWD##*/}" --rows "[${ROWS%,}]"
else
  "$BIN" ui dock push --id "$DOCK" --title "FILES · ${CWD##*/}" --rows '[{"text":"vide","dot":"idle"}]'
fi
