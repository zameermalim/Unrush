#!/usr/bin/env bash
# Check whether GoKwik KwikPass CDN endpoints return CORS headers
# allowing shopunrush.com to load them via fetch().
#
# Exit code 0 = all 3 endpoints OK
# Exit code 1 = at least one endpoint missing ACAO header

set -u

URLS=(
  "https://pdp.gokwik.co/kwikpass/kwikpass-core-functions-min.js"
  "https://pdp.gokwik.co/kwikpass/plugin/build/kp-merchant-v2.js"
  "https://account.shopunrush.com/?locale=en&region_country=US"
)

fail=0
for url in "${URLS[@]}"; do
  hdr=$(curl -sS -I -H "Origin: https://shopunrush.com" "$url" 2>/dev/null \
        | tr -d '\r' \
        | awk -F': ' 'tolower($1)=="access-control-allow-origin"{print $2}')
  if [ -z "$hdr" ]; then
    echo "FAIL  $url"
    echo "      (no Access-Control-Allow-Origin header)"
    fail=1
  else
    echo "OK    $url"
    echo "      ACAO: $hdr"
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "Result: PASS — GoKwik CDN allows shopunrush.com origin"
  exit 0
else
  echo "Result: FAIL — KwikPass cannot load. GoKwik must add CORS headers."
  exit 1
fi
