#!/bin/sh
# refresh.sh — dock FILES : arborescence (2 niveaux) avec icônes Nerd Font + état git par fichier
BIN="${LUVUS_BIN_PATH:-luvus}"
DOCK="pk:files"
CWD="${LUVUS_WORKSPACE_CWD:-$PWD}"
MAX_ROWS=40
PRUNE="-name .git -o -name node_modules -o -name .venv -o -name venv -o -name dist -o -name build -o -name __pycache__ -o -name vendor"

# icône Nerd Font selon type/extension
icon_of() {
  case "$1" in
    dir)         printf '' ;;
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
    *.sql|*.db|*.sqlite) printf '' ;;
    *)           printf '' ;;
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
