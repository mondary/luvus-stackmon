#!/bin/sh
# loop.sh — republie le widget toutes les N secondes; meurt si le socket luvus disparaît
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"

# intervalle : réglage injecté en env au démarrage du hook (min 2s)
INT="${LUVUS_SETTING_INTERVAL:-10}"
case "$INT" in ''|*[!0-9]*) INT=10 ;; esac
[ "$INT" -lt 2 ] && INT=2

while :; do
  sh push.sh || exit 0
  sleep "$INT"
done
