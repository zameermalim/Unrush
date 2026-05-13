# shopunrush.com — What's Going On & What To Do

*Plain-English audit for the store owner. Date: 13 May 2026.*

---

## TL;DR — The 60-second version

Your store works. People can still buy things. But the site is **heavy, slow, and several things are quietly broken**. The biggest issue: the homepage downloads **126 MB of images on a phone** — that's like watching a short Netflix episode just to look at your store. Indian shoppers on data plans bounce.

Your "Cloudflare verification" issue is probably **not** something you can fix yourself — it's from Shopify's side, not yours.

The three things to act on, in order of impact:
1. **Fix the giant images** (theme developer, half a day of work) → biggest win for everyone
2. **Fix GoKwik** (contact GoKwik support today) → their scripts are broken, your fast checkout is dead
3. **Clean up duplicate tracking apps** (yourself in Shopify admin, 30 min) → small win

---

## 1. The Cloudflare "verification" your customers see

### What it looks like
A full-page block that says:
> **Your connection needs to be verified before you can proceed**
> *Verification successful. Waiting for shopunrush.com to respond*

(Confirmed from Pragya's screenshot, 13 May 2026.)

### What it actually is
This is **Cloudflare's "Managed Challenge"** — a full-page interstitial Cloudflare shows when its bot management decides a visitor is suspicious. **It is not Turnstile** (the little checkbox widget); it's a full block.

Your store is on Shopify. **Shopify runs its own Cloudflare** in front of every Shopify store. You don't have access to it. You can't change its settings. Only Shopify support can.

### Two separate problems in that one screenshot
1. **The challenge fires.** Cloudflare's bot protection thinks Pragya/the visitor is suspicious. This is the primary issue.
2. **It hangs on "Verification successful. Waiting for shopunrush.com to respond."** The challenge already cleared but the site never finished loading. That's a *separate* failure — either Shopify's origin server didn't respond in time, or there's a redirect loop. Usually this resolves in 1–2 seconds; if it sits there forever, something downstream is broken too.

### Why this matters: it's happening on a normal browser
Pragya hit this on a **regular browser on a normal connection** — no VPN, no incognito, no unusual setup. That rules out the "she has weird browser settings" explanation. If Cloudflare is challenging *normal* Indian visitors on *normal* connections, that means one of:

1. **Shopify's bot management threshold was raised store-wide** — possibly auto-triggered by a recent traffic spike, scraping wave, or one of your apps generating suspicious patterns. This affects everyone equally and would explain a wide traffic drop.
2. **A Shopify app is making your store look bot-flagged.** Apps that do client-side instrumentation — Microsoft Clarity (session recording), VWO (A/B testing), Glood AI recommendations (the `config-security.com` calls), even GoKwik's broken script retries — can generate request patterns that trip bot detection.
3. **Her home IP specifically is flagged** — possible if she's been refreshing her own store a lot for testing/posting/QA recently (which owners often do). Cloudflare flags repeat-visitors from the same IP as crawlers.

You won't know which until Shopify tells you. Hence the support ticket below.

### What to do — this exact email to Shopify support

> Hi Shopify support,
> 
> I'm the owner of **shopunrush.com**. Multiple customers are being blocked by a Cloudflare "Managed Challenge" page that says *"Your connection needs to be verified before you can proceed."*
> 
> Even when the challenge clears, the page hangs on *"Verification successful. Waiting for shopunrush.com to respond."* and never loads.
> 
> **I had a significant traffic drop on 12 May 2026 evening** which I believe is connected.
> 
> Please can you:
> 1. Check the Cloudflare logs / Verdict flags for my store on 12–13 May 2026
> 2. Tell me what is triggering the challenges (rate limits? IP reputation? bot scores?)
> 3. Tell me whether your bot management threshold was raised for my store
> 4. Investigate the "Waiting for origin to respond" hang — this suggests an origin-side failure even after the challenge clears
> 5. Tell me what *I* can do, if anything (e.g., remove a specific app that's flagging my store)
> 
> Attached: screenshot of the challenge page from a customer (Pragya).
> 
> My store: shopunrush.com  
> Plan: [whichever — Basic / Shopify / Advanced / Plus]  
> Issue first noticed: 12 May 2026 evening

Attach Pragya's screenshot. That screenshot is genuinely useful evidence — they can match the exact challenge page version to internal logs.

### Was last night's traffic drop because of this?
**Almost certainly partly.** A managed challenge plus a hanging page is a guaranteed bounce. Combined with the GoKwik failure (Issue #2), you have two simultaneous problems and either alone would explain a traffic dip.

---

## 2. Your fast-checkout (GoKwik / KwikPass) is broken right now

### What's broken
You're paying GoKwik for KwikPass — the fast OTP-login + one-tap checkout. **It's not working today.** I tested it. Here's what's happening:

- Every page on your store tries to load 3 GoKwik files. **All 3 fail with errors** because GoKwik's servers are sending them wrong.
- Your customers see a normal cart with a normal "Checkout" button. They go through Shopify's regular 4-step form instead of GoKwik's one-tap.
- They CAN still pay. But the experience is slower, asks for more info, and Indian shoppers are used to one-tap checkout from other stores. **You will lose conversions you don't even know you're losing.**

### Why it's broken (the technical bit)
GoKwik's files are missing a small piece of configuration called a **"CORS header"** (specifically `Access-Control-Allow-Origin`). Without it, modern browsers refuse to use the files for security reasons. This is **GoKwik's mistake**, not yours.

### What to do
Send GoKwik support **this exact message** (copy-paste it):

> Hi GoKwik team,
> 
> KwikPass is not loading on our store **shopunrush.com**. Browser console shows CORS errors on these files:
> 
> 1. `https://pdp.gokwik.co/kwikpass/kwikpass-core-functions-min.js`
> 2. `https://pdp.gokwik.co/kwikpass/plugin/build/kp-merchant-v2.js`
> 3. `https://account.shopunrush.com/?locale=en&region_country=US&buyer_flags=…`
> 
> Error verbatim: *"Access to fetch at '…' from origin 'https://shopunrush.com' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource."*
> 
> Please add the missing CORS response header to your CDN (S3 bucket at pdp.gokwik.co serves these files via AmazonS3). This is breaking our fast checkout for all customers.
> 
> Also ask: did you change anything yesterday (12 May)? Our traffic dropped last night.

### How urgent
**Today.** Every hour KwikPass is broken, you're losing the fast-checkout conversion lift you pay them for.

---

## 3. The page weight problem — your biggest fix

### What I measured
On a phone, **your homepage loads 126 MB of data.** A healthy clothing store should be 5–10 MB. You are **12–25× over.**

### Why
The theme is asking your images to be served at insane resolutions. Examples:
- The "Indian Summer" hero image is being requested at **5760 pixels wide**. Your phone screen is 390 pixels wide. That image alone is 1.2 MB.
- The little **navigation menu thumbnails** (the small pictures in your menu when you hover "Categories") are being requested at **3349 pixels wide** — they only display at maybe 200px. Each one is 400 KB instead of 17 KB.
- Total NAV menu images alone: ~40 MB on every page load.

The good news: **Shopify's image servers do the right thing** when asked properly. They automatically convert to WebP (a more efficient format) and resize. The problem is purely the theme telling them "give me 5K resolution please."

### What to do
You use the **Prestige** Shopify theme (version 9.3.0). Have your theme developer:

1. **Edit the nav menu section** to request images at a sane width (400px max — about a quarter of what's now being asked).
2. **Edit the homepage hero section** to request a max of 1600px wide (good enough for retina laptops).
3. **Edit collection page images** (the product grid) to request widths matching the actual thumbnail size.

It's a 2–4 hour theme tweak. If you don't have a developer, post the task on Fiverr or **Upwork — search "Shopify theme image optimization Prestige" and budget USD 100–200.**

### Impact estimate
This single change should cut your mobile page weight from **126 MB to ~6 MB** — a 20× reduction. Bounce rate on slow connections will drop significantly. This is your biggest lever.

---

## 4. Duplicate apps and overloaded page

### What I found
Your homepage triggers **506 separate network downloads** on mobile (a healthy store is under 100). Many are duplicates:

- The same data file is downloaded **30 times** on one page load (Shopify's product API)
- Google Tag Manager script is loaded **7 times** (should be once)
- Theme CSS file is loaded **4 times** (should be once)
- Your logo is downloaded **4 times** (should be once)

This is caused by multiple Shopify apps each doing their own setup, plus the theme firing things off again.

### Apps installed (that I could detect from outside)
1. **simply-otp-login** — your phone-number login app (this one is also crashing — see below)
2. **variant-image-swatch** — the colour/size swatches on product pages
3. **wishlist-engine** — the heart/wishlist feature
4. **beast-currency-converter** — the currency dropdown (the INR/USD selector)
5. **peppyduck-restock-whatsapp** — the WhatsApp "notify when restocked" button
6. **judgeme** — review stars
7. **GoKwik / KwikPass** — fast checkout (broken, see Issue #2)

Plus tracking pixels: Facebook Pixel, Google Tag Manager, Google Ads, Microsoft Clarity (session recording), VWO (A/B testing), Google Merchant Center.

### What to do
**In Shopify Admin → Apps:**
- Ask yourself: *"Do I actually look at the data from Microsoft Clarity and VWO?"* If no, uninstall them. Each tracking app adds weight and complexity.
- The **currency converter app** is heavy (each currency = an entry in a dropdown of ~150 currencies). If you only sell in INR + a couple of currencies, consider switching to Shopify's built-in markets feature.
- The **OTP login app** is broken in your current theme (see below). You may already get this from GoKwik — talk to your developer about removing the duplicate.

---

## 5. The OTP login dropdown is silently broken

The "Simply OTP Login" app crashes every time someone tries to use it. Error in the browser:

> `TypeError: Cannot read properties of undefined (reading 'contains')`
> *at simplyOtp.initializeSimplyOtp (otp-login.js:1)*

This means: when a customer clicks the login icon (the little person at the top right), the country-selector dropdown breaks. They probably can't log in properly.

### What to do
You have **two phone-OTP login systems** running at the same time:
- **Simply OTP** (Shopify app — broken)
- **KwikPass** (GoKwik — also broken right now, but should be your real one)

Pick one. KwikPass is what you're paying for. Once it's working again (Issue #2), **uninstall Simply OTP**. They're conflicting.

---

## 6. Server performance — actually fine

Good news: the basics are healthy.
- Time to first response: 30–170ms (fast, Cloudflare doing its job from Mumbai edge)
- HTML page builds in 200–300ms on Shopify's side
- Server-side rendering is not the issue

This means **all your problems are in the browser** (images, scripts, apps) — which means they're all fixable in the theme and apps. You don't need to switch hosts.

---

## Priority Action Plan (in order)

| When | Who | What |
|---|---|---|
| **Today** | You | Email GoKwik support with the exact text in section #2 |
| **Today** | You | Open Shopify support ticket asking about Cloudflare challenges last night |
| **This week** | A theme developer | Fix image widths in Prestige theme (see section #3) |
| **This week** | You | Audit installed Shopify apps; uninstall ones you don't use (section #4) |
| **After GoKwik works** | You + developer | Remove Simply OTP login app (section #5) |
| **Optional** | Theme developer | Consolidate Google Tag Manager / theme.css loading duplicates |

---

## What I tested

Pages I checked, all on shopunrush.com/en-international:
- Home (`/`)
- New (`/collections/new-2025`)
- Categories: Dresses (`/collections/dresses-nov-2024`)
- Bestsellers (`/collections/bestsellers-nov-2024`)
- Last Chance (`/collections/last-chance`)
- Celebrity Looks (`/pages/celebrity-looks`)
- A product page (Sola Co-ord Set in Mint Green)
- Cart (empty + with one item)
- Checkout (verified it works, falls back to Shopify native because GoKwik is broken)
- Mobile viewport (iPhone 14 sized) homepage

Every page has the **same 13 JavaScript errors** in the browser — all from GoKwik and Simply OTP. They're not isolated to one page.
