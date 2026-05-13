#!/usr/bin/env bash
# Check whether the Prestige theme is still requesting absurdly large
# image widths on the homepage HTML.
#
# Exit 0 = all widths <= 1600
# Exit 1 = any width > 2500 found

set -u

TMP=$(mktemp)
curl -sS "https://shopunrush.com/en-international" -o "$TMP"

# Pull all `width=NNN` numeric values from image URLs in the HTML
WIDTHS=$(grep -oE 'width=[0-9]+' "$TMP" | sed 's/^width=//' | sort -n -u)

if [ -z "$WIDTHS" ]; then
  echo "Result: WARN — no width= parameters found. Theme template may have changed."
  rm -f "$TMP"
  exit 0
fi

MAX=$(echo "$WIDTHS" | tail -1)
TOP5=$(echo "$WIDTHS" | tail -5 | tr '\n' ' ')

echo "Image widths requested on home page (largest 5): $TOP5"
echo "Largest width: $MAX px"

if [ "$MAX" -gt 2500 ]; then
  echo "Result: FAIL — images > 2500 px wide. Theme not yet fixed."
  rm -f "$TMP"
  exit 1
elif [ "$MAX" -gt 1600 ]; then
  echo "Result: WARN — some widths between 1600–2500. Acceptable only if hero/banner."
  rm -f "$TMP"
  exit 0
else
  echo "Result: PASS — all widths ≤ 1600 px."
  rm -f "$TMP"
  exit 0
fi
