#!/bin/sh
# loop.sh — republie le widget toutes les N secondes; meurt si le socket luvus disparaît
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"

while :; do
  # intervalle lu à chaque tick pour appliquer les réglages sans relink (sortie JSON -> sed)
  INT=$("$BIN" module settings pk.stackmon interval 2>/dev/null | sed -n 's/.*"value": *\([0-9][0-9]*\).*/\1/p')
  case "$INT" in ''|*[!0-9]*) INT=10 ;; esac
  [ "$INT" -lt 2 ] && INT=2

  sh push.sh || exit 0
  sleep "$INT"
done
