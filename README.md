# CMS — Crypto, Memecoins & Stocks

A live market dashboard: ~955 crypto assets (top coins + memecoins), 110
stocks, real technical indicators, a transparent momentum/risk scoring
system, a market heatmap, and a portfolio/watchlist that syncs across
devices via Supabase-backed accounts. Works fully as a guest (browser
localStorage) if you don't sign in.

Live at: https://cms-tracker.netlify.app

## How data works

- **Crypto & memecoins**: fetched live from the CoinGecko public API
  directly in the visitor's browser on every page load (market data,
  sparklines, the trending feed). Candlestick/OHLC history for the
  Analytics tab is fetched live per-coin, on demand, when you select an
  asset — only a curated ~25-coin list supports this (CoinGecko rate-limits
  per-coin OHLC calls heavily).
- **Stocks**: fetched live from Yahoo Finance, but routed through a Netlify
  serverless function (`netlify/functions/stock-proxy.mjs`). Yahoo's
  endpoint answers fine server-to-server but never sends CORS headers, so a
  direct browser `fetch()` gets silently blocked — the proxy exists purely
  to work around that.
- **Fallback**: if either live fetch fails (rate limit, network issue), the
  page falls back to the snapshot baked into `index.html` at whatever point
  it was last regenerated, and shows a visible "live data unavailable"
  notice instead of failing silently. The status line under the header
  always tells you which parts are live right now.

## Project structure

```
index.html                        — the entire app: markup, styles, and
                                     client-side JS in one file, no build step
netlify.toml                      — tells Netlify where the functions live
netlify/functions/stock-proxy.mjs — CORS proxy for Yahoo Finance
supabase_schema.sql               — DB schema + row-level security policies
og-image.png                      — social share preview image
```

## Setup (from scratch)

1. **Database**: in your Supabase project → SQL Editor → run
   `supabase_schema.sql`. Creates `portfolio_holdings` and `watchlist_items`
   tables, both with row-level security so each user only ever sees their
   own rows.
2. **Auth email**: Supabase's free built-in mailer has a very low send
   limit. Set up a free SMTP provider (e.g. Resend) under Authentication →
   Emails → SMTP Settings to avoid hitting it. Also edit the "Magic Link"
   email template to include `{{ .Token }}` in the body — sign-in uses an
   emailed code, not the clickable link, since Gmail's link-prefetching
   silently consumes one-time magic links before the user can click them.
3. **Auth redirect**: Authentication → URL Configuration — set **Site URL**
   and add to **Redirect URLs** whatever domain this ends up deployed at.
   Sign-in fails silently (falls back to guest mode) until this matches
   exactly.
4. **Deploy**: push this repo to GitHub, then in Netlify link the project to
   it (Project configuration → Build & deploy → Link repository). Build
   command: none. Publish directory: `.`. Netlify auto-detects
   `netlify/functions/` from `netlify.toml`.
5. From then on, deploying is just `git push` — Netlify rebuilds
   automatically.

## Notes

- The Supabase URL and publishable (anon-equivalent) key are embedded
  directly in `index.html` — that's intentional and safe, they're designed
  to be public, protected by the row-level security policies in
  `supabase_schema.sql`. **Never** put a Supabase `service_role`/secret key
  in this file — that one bypasses all security rules.
- There's no build tooling on purpose. If this ever needs a real framework
  or TypeScript, that's a rewrite, not a refactor — the whole point right
  now is zero build step.
