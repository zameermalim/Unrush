# Check definitions

Detailed procedure for each of the 6 diagnostic checks. Run from `SKILL.md`.

---

## Check 1 — GoKwik KwikPass CORS headers

**Why it matters:** When the merchant script's CORS headers are missing, the browser blocks GoKwik from loading. KwikPass (fast OTP login + one-tap checkout) is dead. Customers fall through to Shopify native checkout — orders still go through, but conversion drops.

**How to test:**
Run `scripts/check-gokwik-cors.sh` from this skill folder, or inline:

```bash
for url in \
  "https://pdp.gokwik.co/kwikpass/kwikpass-core-functions-min.js" \
  "https://pdp.gokwik.co/kwikpass/plugin/build/kp-merchant-v2.js" \
  "https://account.shopunrush.com/?locale=en&region_country=US"; do
  hdr=$(curl -sS -I -H "Origin: https://shopunrush.com" "$url" | grep -i "^access-control-allow-origin:")
  if [ -z "$hdr" ]; then echo "FAIL: no ACAO header on $url"; else echo "OK: $hdr"; fi
done
```

**Pass:** All three URLs return an `Access-Control-Allow-Origin` header (value should be `*` or `https://shopunrush.com`).
**Fail:** Any URL returns no ACAO header.
**Baseline (2026-05-13):** All three fail.

**User-facing impact when failing:** GoKwik checkout button missing; OTP login dialog never loads; customers see standard Shopify checkout instead of one-tap.

---

## Check 2 — Cloudflare Managed Challenge

**Why it matters:** Shopify's Cloudflare can challenge legitimate visitors. Confirmed firing on real users 2026-05-13 (screenshot from Pragya). The merchant cannot configure this — only Shopify support can.

**How to test:**
```bash
curl -sS "https://shopunrush.com/en-international" -o /tmp/sr.html -w "Status: %{http_code}\n"
grep -ci "needs to be verified\|cdn-cgi/challenge\|cf-mitigated" /tmp/sr.html
```

**Pass:** Status 200, no challenge markers in HTML.
**Warn:** Status 200, no markers — but this only tests anonymous curl; real users may still see challenges based on IP scoring.
**Fail:** Status 403, or HTML contains challenge markers.

**User-facing impact when failing:** Full-page "Your connection needs to be verified" block. Some users stuck on "Verification successful. Waiting for shopunrush.com to respond." Bounce.

---

## Check 3 — Console error count per page

**Why it matters:** A surging error count usually indicates a new broken integration. Stable count means the same baseline failures.

**How to test:** Using Playwright MCP:

1. `mcp__playwright__browser_navigate` to `https://shopunrush.com/en-international`
2. `mcp__playwright__browser_console_messages` with `level: error`
3. Count errors. Compare to baseline.

**Pass:** Error count is ≤ baseline.
**Warn:** Significantly fewer (something was fixed — verify it's intentional).
**Fail:** More than baseline.
**Baseline (2026-05-13):** 13 errors per page. All originate from GoKwik CORS + Simply OTP crash.

---

## Check 4 — Simply OTP login crash

**Why it matters:** The `simply-otp-login` Shopify app crashes silently when initializing its country-selector dropdown. Customers using "Login with phone" see a broken UI.

**How to test:**
Look for this string in the console messages from Check 3:
```
Cannot read properties of undefined (reading 'contains')
```
Originates from `otp-login.js:1` inside `cdn.shopify.com/s/files/.../simply-otp-login-87/`.

**Pass:** String absent.
**Fail:** String present.
**Baseline (2026-05-13):** Present on every page.

---

## Check 5 — Checkout fallback works

**Why it matters:** Even with KwikPass broken, Shopify's native checkout should accept orders. If this is broken too, the store is *down* — not just degraded.

**How to test:** Using Playwright MCP:

1. Navigate to a product page (e.g., `/en-international/products/sola-co-ord-set-in-mint-green`).
2. `mcp__playwright__browser_evaluate` to click the visible "Add to cart" button:
   ```js
   () => { [...document.querySelectorAll('button')].find(b => b.textContent.trim() === 'Add to cart' && b.offsetParent !== null)?.click(); return 'clicked'; }
   ```
3. Wait 2 seconds, navigate to `/en-international/cart`.
4. Click the "Checkout" button.
5. Inspect the resulting URL.

**Pass:** Final URL contains `/checkouts/cn/` (Shopify native checkout).
**Fail:** URL hangs, errors, or returns a Cloudflare block page.

**Cleanup:** Do not actually complete checkout. Close the page or navigate away.

---

## Check 6 — Theme image widths

**Why it matters:** The Prestige theme requests images at 3K–5K resolution for thumbnails, blowing up mobile page weight to ~126 MB. Fix is theme-level. This check confirms whether the fix has landed.

**How to test:**
```bash
curl -sS "https://shopunrush.com/en-international" > /tmp/sr.html
# Find the largest width values in image URLs
grep -oE 'width=[0-9]+' /tmp/sr.html | sort -t= -k2 -n -r | head -5
```

**Pass:** All requested widths ≤ 1600.
**Warn:** Some widths between 1600–2500 (acceptable for hero/banner only).
**Fail:** Any width > 2500 (especially in nav menu / thumbnail contexts).
**Baseline (2026-05-13):** Hero requested at width=5760, NAV menu PNGs at width=3349.
