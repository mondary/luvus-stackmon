#!/bin/sh
# icon.sh — affiche l'image de la racine du workspace dans un pane Luvus
set -eu

root="${LUVUS_WORKSPACE_CWD:-}"
[ -n "$root" ] || root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root" || exit 1

icon=''
for candidate in icon.png icon.jpg icon.jpeg ICON.PNG ICON.JPG ICON.JPEG; do
  if [ -f "$candidate" ]; then
    icon="$candidate"
    break
  fi
done

printf '\033[2J\033[H'

if [ -z "$icon" ]; then
  printf 'Aucune image trouvée à la racine.\n\n'
  printf 'Fichiers acceptés : icon.png, icon.jpg, icon.jpeg\n'
else
  printf 'Image : %s\n\n' "$icon"
  if command -v chafa >/dev/null 2>&1; then
    chafa --format symbols --colors truecolor --size 48x20 --animate off "$icon"
  else
    printf 'chafa est nécessaire pour afficher cette image dans le terminal.\n'
  fi
fi

printf '\nPane ouvert — fermez-le avec la commande Luvus de fermeture du pane.\n'
trap 'exit 0' INT TERM HUP
while :; do sleep 3600; done
