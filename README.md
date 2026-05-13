# Unrush — diagnostics

Tools and findings for diagnosing performance, checkout, and Cloudflare-challenge issues on [shopunrush.com](https://shopunrush.com).

## What's in here

| File | Purpose |
|---|---|
| `UNRUSH-action-plan.md` | Plain-English audit + action plan for the store owner. Covers the Cloudflare challenge, broken GoKwik integration, ~126 MB mobile page weight, and duplicate apps. Includes copy-paste support emails. |
| `bot-check.html` | Self-contained browser-based diagnostic. When a customer is hit by the Cloudflare "verify you're human" challenge, they open this file to capture their network identity, IP reputation, browser environment, and a live reachability test of shopunrush.com — producing a copyable report for Shopify support. |

## How to use `bot-check.html`

1. Download the file (right-click → Save link as…).
2. Double-click to open in any modern browser.
3. Wait ~5 seconds for all checks to complete.
4. Click **Copy report** and paste into your email to Shopify support.

The tool runs entirely client-side. The only external requests are to public IP-lookup APIs (`ipwho.is`, `ipapi.co`) which only see the visitor's IP — same as visiting any normal website.

## Status of the live site (as of 2026-05-13)

- **Checkout works.** Orders go through Shopify's native checkout.
- **GoKwik / KwikPass is broken.** Fast OTP login and one-tap checkout do not work — CORS misconfiguration on GoKwik's CDN.
- **Cloudflare challenges fire on normal traffic.** Shopify-side issue; only Shopify support can investigate.
- **Mobile page weight is ~126 MB.** Theme is requesting 3K–5K-wide images for thumbnails. Theme-level fix.

See `UNRUSH-action-plan.md` for details and what to do.
