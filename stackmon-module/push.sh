#!/bin/sh
# push.sh — calcule RAM/CPU du stack et publie le widget Luvus Bar
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"
ID="${LUVUS_BAR_ID:-stackmon}"

# région lue à chaque push : bottom-right (défaut), top-right, ou off
# ponytail: extraction sed du JSON (pas de flag raw côté luvus) — casserait si la valeur contenait une virgule
REGION=$("$BIN" module settings pk.stackmon region 2>/dev/null | sed -n 's/.*"value": *"\([^"]*\)".*/\1/p')
case "$REGION" in
  top-right)    ;;
  off)          "$BIN" bar move --id "$ID" --region off >/dev/null 2>&1; exit 0 ;;
  *)            REGION="bottom-right" ;;
esac

# deux lignes : content (détaillé, avec séparateurs) puis compact (Σ + cpu)
METRICS=$(ps -axo rss=,pcpu=,comm= | awk '
  function fmt(mb) {
    s = (mb >= 1024) ? sprintf("%.1f Go", mb/1024) : sprintf("%.0f Mo", mb)
    gsub(/\./, ",", s); return s
  }
  function st(mb) { return (mb >= 2048) ? "error" : (mb >= 512) ? "warning" : "success" }
  function seg(t, mb) { printf "{\"type\":\"text\",\"text\":\"%s %s\",\"tone\":\"%s\"},", t, fmt(mb), st(mb) }
  function sep()     { printf "{\"type\":\"separator\",\"tone\":\"muted\"}," }
  function sum()     { printf "{\"type\":\"text\",\"text\":\"Σ %s\",\"tone\":\"%s\"},", fmt(tm/1024), st(tm/1024) }
  function cpu()     { printf "{\"type\":\"badge\",\"text\":\"%.0f%%\"}", tc }
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
    printf "]"
  }') || exit 1
CONTENT=$(printf '%s\n' "$METRICS" | sed -n 1p)
COMPACT=$(printf '%s\n' "$METRICS" | sed -n 2p)

"$BIN" bar push --id "$ID" --content "$CONTENT" --compact-content "$COMPACT"
# le push (re)crée le widget ; le move applique la région (push --region ne repositionne pas)
"$BIN" bar move --id "$ID" --region "$REGION"
