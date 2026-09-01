#!/bin/sh
# startup.sh — ouvre automatiquement le pane si l'option est activée
[ "${LUVUS_SETTING_SHOW_PANE:-true}" = "true" ] || exit 0
exec sh open.sh
