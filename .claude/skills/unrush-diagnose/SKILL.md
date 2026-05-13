---
name: unrush-diagnose
description: Health-check shopunrush.com for the known integration breakages and live-site issues found in the 2026-05-13 audit. Tests GoKwik KwikPass CORS, Cloudflare Managed Challenge presence, console error counts, the Simply OTP login crash, GoKwik iframe load status, checkout fallback, and theme image widths. Use when investigating an incident, after a Shopify app change, when the user reports "something seems broken", or as a recurring health check. Produces a pass/fail summary plus user-facing impact.
---

# unrush-diagnose — shopunrush.com health check

## When to invoke

Run this when the user says any of:
- "is shopunrush healthy" / "is X broken on shopunrush"
- "diagnose shopunrush" / "health check"
- "did the deploy break anything"
- After a Shopify app install/uninstall
- After a GoKwik / theme change
- When investigating a customer complaint about checkout or login

## Prerequisites

- **Playwright MCP** preferred for checks 3, 4, 5 (console errors + interactive cart test).
- **Bash with `curl`** required for checks 1, 2, 6 (works without Playwright).
- If Playwright isn't available, run only the curl checks and tell the user which parts you skipped.

## Checks to run

Read `checks.md` in this skill folder for the full check definitions. The short version:

| # | Check | Tool | Pass criterion |
|---|---|---|---|
| 1 | GoKwik KwikPass CORS headers | curl | All 3 endpoints return `Access-Control-Allow-Origin` |
| 2 | Cloudflare Managed Challenge | curl | Home HTML does not contain "needs to be verified" |
| 3 | Console errors per page | Playwright | < 5 errors per page (baseline was 13) |
| 4 | Simply OTP crash | Playwright | No `Cannot read properties of undefined (reading 'contains')` |
| 5 | Checkout fallback works | Playwright | Add to cart → checkout reaches `/checkouts/cn/...` |
| 6 | Theme image widths | curl | Hero/nav image URLs in HTML have `width=` ≤ 1600 |

Helper scripts in this folder:
- `scripts/check-gokwik-cors.sh` — runs check 1
- `scripts/check-cloudflare-challenge.sh` — runs check 2
- `scripts/check-theme-images.sh` — runs check 6

## Output format

```
shopunrush.com health check — <date>

[ok / FAIL / warn] 1. GoKwik KwikPass CORS         — <one-line detail>
[ok / FAIL / warn] 2. Cloudflare Managed Challenge — <one-line detail>
[ok / FAIL / warn] 3. Console error count          — <one-line detail>
[ok / FAIL / warn] 4. Simply OTP crash             — <one-line detail>
[ok / FAIL / warn] 5. Checkout fallback            — <one-line detail>
[ok / FAIL / warn] 6. Theme image widths           — <one-line detail>

Summary: X passed, Y failed, Z warning
```

For each FAIL, add a **User-facing impact** line — what real customers see when this is broken — so the user can prioritize.

## Save the report

Always write the final report to `runs/<YYYY-MM-DD>-<HHMM>-diagnose.md` at the repo root, using current UTC time. Filename pattern keeps runs sortable chronologically.

Include in the file:
1. Run header (timestamp, tool)
2. Results table (the 6 checks)
3. User-facing impact section
4. Comparison to the 2026-05-13 baseline in `checks.md`
5. Suggested next actions referencing `UNRUSH-action-plan.md`

Do **not** commit automatically — just write the file. The user will commit when they want a checkpoint.

## Rules

- **Read-only by default.** Check 5 adds a product to the cart on the live store — abandon the cart (close the page) before finishing, do not check out.
- Do not log in, do not enter real customer data, do not interact with payment fields.
- If GoKwik CORS is fixed (check 1 passes), look at `known-fixes.md` — there may be follow-up tests (e.g., does the GoKwik iframe now render the OTP UI properly?).
- Compare against the 2026-05-13 baseline in `checks.md` and flag any change in either direction (regression *or* fix).
