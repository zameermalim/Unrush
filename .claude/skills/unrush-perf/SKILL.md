---
name: unrush-perf
description: Performance audit for shopunrush.com — measures TTFB, FCP, DOM-ready, load, resource count, and page weight across every key page (home, category, product, cart). Use this when comparing before/after a theme change, after installing/removing a Shopify app, investigating "is the site slower now?", or producing a baseline. Drives a real browser via Playwright MCP and produces a markdown comparison table. Requires the playwright MCP server to be connected.
---

# unrush-perf — shopunrush.com performance audit

## When to invoke
Run this when the user says any of:
- "audit shopunrush perf" / "check perf"
- "is the site faster/slower"
- "compare to baseline"
- "how slow is mobile"
- After any change to the Prestige theme or installed apps

## Prerequisite

Playwright MCP must be connected. If not, tell the user:
```
claude mcp add playwright npx @playwright/mcp@latest
```
…and to restart Claude Code. Don't try to fall back to curl-only — perf measurements need a real browser.

## Pages to test

Read `pages.json` in this skill folder. Each entry has a `url` and a `label`.

For a product-page test, navigate to a collection first and pick the first `/products/...` link returned by:
```js
[...document.querySelectorAll('a[href*="/products/"]')]
  .map(a => a.href)[0]
```

## Procedure

For each page:

1. `mcp__playwright__browser_navigate` with the URL.
2. `mcp__playwright__browser_evaluate` with the function in `perf-capture.js` (copy-paste its contents into the `function` arg).
3. Record the returned object.

After all pages:

4. (Optional, ask user first) Resize viewport to mobile via `mcp__playwright__browser_resize` width=390 height=844 and re-test the home page only. Mobile weight is the single most useful number for an Indian e-commerce store.

## Output

Render a markdown table:

| Page | TTFB | FCP | DCL | Load | Requests | Weight |
|---|---|---|---|---|---|---|

Then a **Findings** section flagging:
- Any page where mobile total weight > **20 MB** → catastrophic
- Any page where `resourceCount` > **200** → likely duplicate apps/scripts
- Any page where `loadComplete` > **3000 ms** → slow
- Any page where `ttfb` > **400 ms** → origin slow (rare for Shopify)

Compare against `baseline.md` if it exists. Call out regressions explicitly: "Home requests up from 697 → 820 (+18%) — likely a new app added".

## Rules

- Test against the live site only — never modify state (no clicking add-to-cart unless the user asks)
- Do not log in — perf should be measured anonymously, matching real visitor experience
- If a page returns a Cloudflare challenge, capture that fact and skip its metrics. Report it in Findings.
- Update `baseline.md` only when the user explicitly asks ("save this as the new baseline")
