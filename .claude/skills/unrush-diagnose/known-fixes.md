# Follow-up tests when a baseline failure starts passing

When a check that was failing in the 2026-05-13 baseline starts passing, the integration may have *partially* recovered. Run these follow-ups before declaring the issue closed.

---

## Check 1 (GoKwik CORS) now passes → follow-up

GoKwik fixed CORS. Now verify the integration actually works end-to-end:

1. Load `https://shopunrush.com/en-international` in Playwright.
2. Look at console messages — confirm zero GoKwik errors remain.
3. Add a product to cart.
4. On the cart page, verify the GoKwik OTP iframe is reachable:
   ```js
   () => [...document.querySelectorAll('iframe')].some(i => i.src.includes('pdp.gokwik.co/kwikpass/kwikpass.html'))
   ```
5. Click "Checkout" and confirm the page transitions into GoKwik's OTP flow (not Shopify native).
   - GoKwik success: URL stays on shopunrush.com and an OTP input appears
   - Still broken: URL jumps to `/checkouts/cn/...` (Shopify fallback)

If step 5 still falls through, GoKwik has more than a CORS bug — escalate again.

---

## Check 2 (Cloudflare challenge) now passes → follow-up

Anonymous curl no longer hits a challenge. But Cloudflare scores per-IP, so real users may still be challenged. Ask the user to:

1. Visit `https://zameermalim.github.io/Unrush/bot-check.html` from a few real customer-style devices/networks.
2. Save the diagnostic reports.
3. Cross-reference IPs/ISPs of complaining customers against the reports.

If multiple genuine customers still get challenged, the Shopify-side bot management threshold is still too aggressive — re-open the Shopify support ticket.

---

## Check 6 (theme images) now passes → follow-up

Theme widths look reasonable. Verify the actual served weight has dropped:

1. Run the `unrush-perf` skill against home (desktop + mobile).
2. Compare mobile total weight to baseline (126 MB → target < 6 MB).
3. If weight is still > 20 MB despite small widths, check for *new* heavy assets — videos, embedded fonts, oversized SVGs.
