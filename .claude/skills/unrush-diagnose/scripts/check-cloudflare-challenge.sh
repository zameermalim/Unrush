#!/usr/bin/env bash
# Check whether shopunrush.com's homepage returns a Cloudflare challenge
# for anonymous requests. This only tests the simplest path; real users
# may still be challenged based on Cloudflare's per-IP bot scoring.
#
# Exit 0 = no challenge for anonymous curl
# Exit 1 = challenge detected

set -u

TMP=$(mktemp)
STATUS=$(curl -sS -o "$TMP" -w "%{http_code}" \
           -A "Mozilla/5.0 (Macintosh) AppleWebKit Chrome/120" \
           "https://shopunrush.com/en-international")

CHALLENGE_HITS=$(grep -ciE "needs to be verified|cdn-cgi/challenge|cf-mitigated|Just a moment" "$TMP" || true)

echo "HTTP status: $STATUS"
echo "Challenge markers in HTML: $CHALLENGE_HITS"

if [ "$STATUS" = "200" ] && [ "$CHALLENGE_HITS" = "0" ]; then
  echo "Result: PASS — anonymous curl reached the storefront"
  echo "Note: this does NOT prove real users are not being challenged."
  echo "      Cloudflare scores each visitor on IP, ASN, browser signals."
  rm -f "$TMP"
  exit 0
else
  echo "Result: FAIL — Cloudflare challenge detected"
  echo "First 20 lines of response body:"
  head -20 "$TMP"
  rm -f "$TMP"
  exit 1
fi
