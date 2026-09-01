#!/bin/sh
# agent-notify.sh — notification quand un agent passe en "blocked"
# Hook sur pane.agent_status_changed ; payload JSON en LUVUS_MODULE_EVENT_JSON
BIN="${LUVUS_BIN_PATH:-luvus}"
[ "${LUVUS_MODULE_EVENT:-}" = "pane.agent_status_changed" ] || exit 0

# ponytail: extraction sed du JSON — casse si un champ contient une virgule/quote
JSON="${LUVUS_MODULE_EVENT_JSON:-}"
STATUS=$(printf '%s' "$JSON" | sed -n 's/.*"status": *"\([^"]*\)".*/\1/p')
AGENT=$(printf '%s' "$JSON" | sed -n 's/.*"agent": *"\([^"]*\)".*/\1/p')
PANE=$(printf '%s' "$JSON" | sed -n 's/.*"pane": *"\([^"]*\)".*/\1/p')

[ "$STATUS" = "blocked" ] || exit 0

"$BIN" ui notification push --level warning --ttl-ms 8000 \
  --dedupe-key "stackmon-agent-${PANE:-?}" \
  --text "${AGENT:-Un agent} est bloqué — action requise"
