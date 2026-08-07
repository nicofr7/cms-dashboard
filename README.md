# CMS — Crypto, Memecoins & Stocks

Static dashboard (no build step) with Supabase-backed accounts for
cross-device Portfolio/Watchlist sync. Works fully as a guest (localStorage)
if you don't sign in.

## Setup

1. **Database**: In your Supabase project → SQL Editor → run `supabase_schema.sql`.
2. **Auth redirect**: In Supabase → Authentication → URL Configuration, add your
   deployed URL (e.g. `https://your-project.vercel.app`) to Redirect URLs.
   Magic-link sign-in will silently fail until this is set.
3. **Deploy**: push this repo to GitHub, then import it in Vercel
   (Framework Preset: **Other** — it's a static `index.html`, no build command
   needed).

## Notes

- The Supabase URL and publishable (anon) key are already embedded in
  `index.html` — they're safe to expose client-side, protected by the
  row-level security policies in `supabase_schema.sql`.
- Never put the `service_role` key in this file — it bypasses all security
  rules.
