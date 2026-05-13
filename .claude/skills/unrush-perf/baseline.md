# Baseline metrics

Captured **2026-05-13** during the initial audit. Use these to spot regressions when re-running `unrush-perf`.

## Desktop viewport (1280×800)

| Page | TTFB | FCP | DCL | Load | Requests |
|---|---|---|---|---|---|
| Home            | 121 ms | 744 ms |  957 ms | 2287 ms | 697 |
| Last Chance     |  48 ms | 424 ms |  523 ms | 1722 ms | 776 |
| Dresses         |  34 ms | 448 ms |  502 ms | 1645 ms | 745 |
| Bestsellers     | 103 ms | 480 ms |  498 ms | 1677 ms | 763 |
| New             | 170 ms | 644 ms |  664 ms | 1875 ms | 744 |
| Product (Sola Co-ord Mint) | 35 ms | 364 ms | 372 ms | 1536 ms | 674 |
| Cart            | 338 ms | 416 ms |  503 ms | 1586 ms | 209 |
| Celebrity Looks |  31 ms | 380 ms | 1087 ms | 1477 ms | 646 |

## Mobile viewport (390×844 — iPhone 14 sized)

| Page | Requests | Total weight |
|---|---|---|
| Home | 506 | **126 MB** |

The mobile weight is catastrophic. The fix lives in the Prestige theme — the templates request image widths up to 5760 px regardless of viewport.

## What "good" looks like for shopunrush

A reasonable target post-fix:

| Metric | Target |
|---|---|
| Mobile total weight (home) | < 6 MB |
| Resource count (any page) | < 150 |
| Load complete (any page) | < 2500 ms |
| TTFB | < 200 ms |

Hitting all four = healthy site. Any one over = open a follow-up.
