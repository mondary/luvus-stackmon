#!/bin/sh
# loop.sh — republie toutes les 10 s ; meurt si le socket luvus disparaît
cd "$(dirname "$0")" || exit 1
while :; do
  sh push.sh || exit 0
  sleep 10
done
