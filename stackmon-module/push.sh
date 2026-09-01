#!/bin/sh
# push.sh — publie les surfaces du module selon les réglages : widget barre, dock latéral, alertes
# Réglages arrivent en env (LUVUS_SETTING_*) ; appliquer un changement = réactiver le module
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"
ID="${LUVUS_BAR_ID:-stackmon}"
DOCK_ID="pk:stackmon"

# affichage exclusif : barre en bas/droite, dock latéral, ou notifications seules
DISPLAY="${LUVUS_SETTING_DISPLAY:-bottom-right}"
case "$DISPLAY" in bottom-right|top-right|dock|notifications) ;; *) DISPLAY="bottom-right" ;; esac
NOTIF="${LUVUS_SETTING_NOTIFICATIONS:-true}"
SEUIL="${LUVUS_SETTING_RAM_THRESHOLD:-2}"
case "$SEUIL" in ''|*[!0-9]*) SEUIL=2 ;; esac
SEUIL_MB=$((SEUIL * 1024))

# 4 lignes : content | compact | rows dock | "totalMo totalHumain cpu%"
METRICS=$(ps -axo rss=,pcpu=,comm= | awk -v seuil="$SEUIL_MB" '
  function fmt(mb) {
    s = (mb >= 1024) ? sprintf("%.1f Go", mb/1024) : sprintf("%.0f Mo", mb)
    gsub(/\./, ",", s); return s
  }
  function cs(c) {
    s = sprintf("%.1f", c); gsub(/\./, ",", s); return s
  }
  function st(mb)  { return (mb >= 2048) ? "error" : (mb >= 512) ? "warning" : "success" }
  function dot(mb) { return (mb >= 2048) ? "blocked" : (mb >= 512) ? "working" : "done" }
  function seg(t, mb)  { printf "{\"type\":\"text\",\"text\":\"%s %s\",\"tone\":\"%s\"},", t, fmt(mb), st(mb) }
  function sep()       { printf "{\"type\":\"separator\",\"tone\":\"muted\"}," }
  function sum()       { printf "{\"type\":\"text\",\"text\":\"Σ %s\",\"tone\":\"%s\"},", fmt(tm/1024), st(tm/1024) }
  function cpu()       { printf "{\"type\":\"badge\",\"text\":\"%.0f%%\"}", tc }
  function row(t, mb, c) { printf "{\"text\":\"%-9s %8s  %6s %%\",\"dot\":\"%s\"},", t, fmt(mb), cs(c), dot(mb) }
  function totalrow(mb, c) { printf "{\"text\":\"%-9s %8s  %6s %%\",\"dot\":\"%s\",\"action\":\"open-tui\"},", "TOTAL", fmt(mb), cs(c), dot(mb) }
  {
    n = split($3, p, "/"); b = tolower(p[n]); sub(/[ (].*/, "", b)
    if (b == "ghostty")       { g += $1; gc += $2 }
    else if (b == "omp")      { o += $1; oc += $2 }
    else if (b == "opencode") { e += $1; ec += $2 }
    else if (b == "luvus")    { l += $1; lc += $2 }
    else if (b == "herdr")    { h += $1; hc += $2 }
  }
  END {
    tm = g+o+e+l+h; tc = gc+oc+ec+lc+hc
    printf "["
    seg("Gh", g/1024); sep(); seg("OMP", o/1024); sep(); seg("OC", e/1024); sep()
    seg("Lv", l/1024); sep(); seg("Hd", h/1024); sep(); sum(); cpu()
    printf "]\n["
    sum(); sep(); cpu()
    printf "]\n["
    if (g > 0) row("Ghostty", g/1024, gc)
    if (o > 0) row("OMP", o/1024, oc)
    if (e > 0) row("OpenCode", e/1024, ec)
    if (l > 0) row("Luvus", l/1024, lc)
    if (h > 0) row("Herdr", h/1024, hc)
    totalrow(tm/1024, tc)
    printf "]\n"
    printf "%d %s %.0f\n", tm, fmt(tm/1024), tc
  }') || exit 1

CONTENT=$(printf '%s\n' "$METRICS" | sed -n 1p)
COMPACT=$(printf '%s\n' "$METRICS" | sed -n 2p)
ROWS=$(printf '%s\n' "$METRICS" | sed -n 3p | sed 's/,]/]/')
TOTALS=$(printf '%s\n' "$METRICS" | sed -n 4p)
TOTAL_MB=${TOTALS%% *}
REST=${TOTALS#* }
TOTAL_HUM=${REST%% *}
TOTAL_CPU=${REST##* }

# widget barre : le push (re)crée le widget ; le move applique la région (push --region ne repositionne pas)
case "$DISPLAY" in
  bottom-right|top-right)
    "$BIN" bar push --id "$ID" --content "$CONTENT" --compact-content "$COMPACT" || exit 1
    "$BIN" bar move --id "$ID" --region "$DISPLAY" ;;
  *)
    "$BIN" bar move --id "$ID" --region off 2>/dev/null ;;
esac

# dock latéral — côté choisi dans Settings → Layout ; vide sauf en mode dock
if [ "$DISPLAY" = "dock" ]; then
  "$BIN" ui dock push --id "$DOCK_ID" --title STACK --rows "$ROWS"
else
  "$BIN" ui dock push --id "$DOCK_ID" --title STACK --rows '[]'
fi

# alerte RAM : notification bornée quand le seuil est dépassé, nettoyage sinon
if [ "$NOTIF" = "true" ] && [ "${TOTAL_MB:-0}" -ge "$SEUIL_MB" ]; then
  "$BIN" ui notification push --level error --dedupe-key stackmon-ram --ttl-ms 8000 \
    --text "Stack Monitor : RAM ${TOTAL_HUM} (seuil ${SEUIL} Go)"
else
  "$BIN" ui notification clear --dedupe-key stackmon-ram 2>/dev/null
fi
