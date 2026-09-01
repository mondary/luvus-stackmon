#!/bin/sh
# push.sh — calcule RAM/CPU du stack et publie le widget Luvus Bar
cd "$(dirname "$0")" || exit 1
BIN="${LUVUS_BIN_PATH:-luvus}"
ID="${LUVUS_BAR_ID:-stackmon}"

CONTENT=$(ps -axo rss=,pcpu=,comm= | awk '
  function fmt(mb) {
    s = (mb >= 1024) ? sprintf("%.1f Go", mb/1024) : sprintf("%.0f Mo", mb)
    gsub(/\./, ",", s); return s
  }
  function st(mb) { return (mb >= 2048) ? "error" : (mb >= 512) ? "warning" : "success" }
  function seg(t, mb) { printf "{\"type\":\"text\",\"text\":\"%s %s\",\"tone\":\"%s\"},", t, fmt(mb), st(mb) }
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
    seg("Gh", g/1024); seg("OMP", o/1024); seg("OC", e/1024); seg("Lv", l/1024); seg("Hd", h/1024)
    printf "{\"type\":\"text\",\"text\":\"Σ %s\",\"tone\":\"%s\"},", fmt(tm/1024), st(tm/1024)
    printf "{\"type\":\"badge\",\"text\":\"%.0f%%\"}", tc
    printf "]"
  }') || exit 1

exec "$BIN" bar push --id "$ID" --content "$CONTENT"
