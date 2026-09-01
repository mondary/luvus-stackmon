#!/bin/sh
# push.sh — publie le stack selon le réglage Affichage : barre (bas/haut droite) ou dock latéral
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"
ID="${LUVUS_BAR_ID:-stackmon}"
DOCK_ID="pk:stackmon"

# réglage lu en direct à chaque push : appliqué au tick suivant, sans réactiver le module
# ponytail: sed sur la sortie JSON de la CLI — casse si la valeur contenait une quote
DISPLAY=$("$BIN" module settings pk.stackmon display 2>/dev/null | sed -n 's/.*"value": *"\([^"]*\)".*/\1/p')
DISPLAY=${DISPLAY:-${LUVUS_SETTING_DISPLAY:-bottom-right}}
case "$DISPLAY" in bottom-right|top-right|dock) ;; *) DISPLAY="bottom-right" ;; esac

# 3 lignes : content | compact | rows dock
METRICS=$(ps -axo rss=,pcpu=,comm= | awk '
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
    printf "]"
  }') || exit 1

CONTENT=$(printf '%s\n' "$METRICS" | sed -n 1p)
COMPACT=$(printf '%s\n' "$METRICS" | sed -n 2p)
ROWS=$(printf '%s\n' "$METRICS" | sed -n 3p | sed 's/,]/]/')

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
