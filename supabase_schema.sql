-- CMS dashboard: portfolio + watchlist tables with per-user row-level security.
-- Run this once in the Supabase SQL Editor (Project -> SQL Editor -> New query -> paste -> Run).

create table if not exists portfolio_holdings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  asset_type text not null check (asset_type in ('crypto','stock')),
  item_id text not null,          -- coin id (e.g. "bitcoin") or stock symbol (e.g. "AAPL")
  qty numeric not null check (qty > 0),
  buy_price numeric not null check (buy_price >= 0),
  buy_date date,
  created_at timestamptz not null default now()
);

create table if not exists watchlist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  type text not null check (type in ('crypto','stock')),
  item_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, type, item_id)
);

alter table portfolio_holdings enable row level security;
alter table watchlist_items enable row level security;

-- Each user can only ever see/modify their own rows.
create policy "portfolio: owner read" on portfolio_holdings
  for select using (auth.uid() = user_id);
create policy "portfolio: owner insert" on portfolio_holdings
  for insert with check (auth.uid() = user_id);
create policy "portfolio: owner delete" on portfolio_holdings
  for delete using (auth.uid() = user_id);

create policy "watchlist: owner read" on watchlist_items
  for select using (auth.uid() = user_id);
create policy "watchlist: owner insert" on watchlist_items
  for insert with check (auth.uid() = user_id);
create policy "watchlist: owner delete" on watchlist_items
  for delete using (auth.uid() = user_id);

create index if not exists portfolio_holdings_user_idx on portfolio_holdings(user_id);
create index if not exists watchlist_items_user_idx on watchlist_items(user_id);
