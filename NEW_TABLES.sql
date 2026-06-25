-- ============================================================
-- Forum Romanum — Neurological Network Expansion
-- Run this in Supabase SQL Editor
-- ============================================================

-- ─── Product Launches ────────────────────────────────────────

create table if not exists product_launches (
  id           uuid primary key default gen_random_uuid(),
  listing_id   uuid references marketplace_listings(id) on delete set null,
  launcher_id  uuid references users(id) on delete cascade not null,
  headline     text not null,
  tagline      text,
  launch_date  date not null default current_date,
  upvotes_count int not null default 0,
  comments_count int not null default 0,
  is_featured  boolean not null default false,
  created_at   timestamptz not null default now()
);

create table if not exists launch_upvotes (
  launch_id  uuid references product_launches(id) on delete cascade,
  user_id    uuid references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (launch_id, user_id)
);

create index if not exists product_launches_date_idx on product_launches(launch_date desc);
create index if not exists product_launches_upvotes_idx on product_launches(upvotes_count desc);

-- View: launches joined with listing + launcher
create or replace view v_launches as
select
  pl.id,
  pl.listing_id,
  pl.launcher_id,
  pl.headline,
  pl.tagline,
  pl.launch_date,
  pl.upvotes_count,
  pl.comments_count,
  pl.is_featured,
  pl.created_at,
  ml.cover_url,
  ml.title          as product_title,
  ml.summary        as product_summary,
  ml.demo_url,
  ml.pricing_model,
  ml.price_cents,
  ml.tech_stack,
  ml.tags,
  u.display_name    as launcher_name,
  u.avatar_url      as launcher_avatar,
  u.username        as launcher_username
from product_launches pl
join users u on u.id = pl.launcher_id
left join marketplace_listings ml on ml.id = pl.listing_id;


-- ─── Collab Requests ─────────────────────────────────────────

create table if not exists collab_requests (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references users(id) on delete cascade not null,
  company_id      uuid references company_profiles(id) on delete set null,
  title           text not null,
  description     text,
  project_stage   text check (project_stage in ('idea','mvp','growth','scale')) default 'mvp',
  roles_needed    text[] default '{}',
  tech_stack      text[] default '{}',
  equity_offered  boolean not null default false,
  paid            boolean not null default false,
  tags            text[] default '{}',
  status          text not null default 'open' check (status in ('open','closed','filled')),
  upvotes_count   int not null default 0,
  created_at      timestamptz not null default now()
);

create table if not exists collab_upvotes (
  request_id uuid references collab_requests(id) on delete cascade,
  user_id    uuid references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (request_id, user_id)
);

create index if not exists collab_requests_status_idx on collab_requests(status);
create index if not exists collab_requests_upvotes_idx on collab_requests(upvotes_count desc);

-- View: collab requests joined with creator + company
create or replace view v_collab_requests as
select
  cr.id,
  cr.user_id,
  cr.company_id,
  cr.title,
  cr.description,
  cr.project_stage,
  cr.roles_needed,
  cr.tech_stack,
  cr.equity_offered,
  cr.paid,
  cr.tags,
  cr.status,
  cr.upvotes_count,
  cr.created_at,
  u.display_name  as creator_name,
  u.avatar_url    as creator_avatar,
  u.username      as creator_username,
  cp.name         as company_name,
  cp.logo_url     as company_logo
from collab_requests cr
join users u on u.id = cr.user_id
left join company_profiles cp on cp.id = cr.company_id;


-- ─── Developer Tech Stacks ───────────────────────────────────

create table if not exists dev_stacks (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references users(id) on delete cascade not null,
  name          text not null,
  description   text,
  tools         jsonb not null default '{}',
  upvotes_count int not null default 0,
  created_at    timestamptz not null default now()
);

create table if not exists stack_upvotes (
  stack_id   uuid references dev_stacks(id) on delete cascade,
  user_id    uuid references users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (stack_id, user_id)
);

create index if not exists dev_stacks_upvotes_idx on dev_stacks(upvotes_count desc);

-- View: stacks joined with creator
create or replace view v_dev_stacks as
select
  ds.id,
  ds.user_id,
  ds.name,
  ds.description,
  ds.tools,
  ds.upvotes_count,
  ds.created_at,
  u.display_name  as creator_name,
  u.avatar_url    as creator_avatar,
  u.username      as creator_username
from dev_stacks ds
join users u on u.id = ds.user_id;


-- ─── Follows (generic user → user / user → company) ─────────
-- Only create if it doesn't already exist

create table if not exists follows (
  id            uuid primary key default gen_random_uuid(),
  follower_id   uuid references users(id) on delete cascade not null,
  following_id  uuid not null,
  entity_type   text not null default 'user' check (entity_type in ('user','company')),
  created_at    timestamptz not null default now(),
  unique (follower_id, following_id, entity_type)
);

create index if not exists follows_follower_idx  on follows(follower_id);
create index if not exists follows_following_idx on follows(following_id);


-- ─── Row Level Security ───────────────────────────────────────

alter table product_launches  enable row level security;
alter table launch_upvotes    enable row level security;
alter table collab_requests   enable row level security;
alter table collab_upvotes    enable row level security;
alter table dev_stacks        enable row level security;
alter table stack_upvotes     enable row level security;
alter table follows           enable row level security;

-- product_launches
create policy "Launches readable by all"
  on product_launches for select using (true);
create policy "Launchers can insert"
  on product_launches for insert with check (auth.uid() = launcher_id);
create policy "Launchers can update own"
  on product_launches for update using (auth.uid() = launcher_id);

-- launch_upvotes
create policy "Upvotes readable by all"
  on launch_upvotes for select using (true);
create policy "Users can insert own upvotes"
  on launch_upvotes for insert with check (auth.uid() = user_id);
create policy "Users can delete own upvotes"
  on launch_upvotes for delete using (auth.uid() = user_id);

-- collab_requests
create policy "Collab requests readable by all"
  on collab_requests for select using (true);
create policy "Users can post collab requests"
  on collab_requests for insert with check (auth.uid() = user_id);
create policy "Users can update own collab requests"
  on collab_requests for update using (auth.uid() = user_id);

-- collab_upvotes
create policy "Collab upvotes readable by all"
  on collab_upvotes for select using (true);
create policy "Users can insert own collab upvotes"
  on collab_upvotes for insert with check (auth.uid() = user_id);
create policy "Users can delete own collab upvotes"
  on collab_upvotes for delete using (auth.uid() = user_id);

-- dev_stacks
create policy "Stacks readable by all"
  on dev_stacks for select using (true);
create policy "Users can create stacks"
  on dev_stacks for insert with check (auth.uid() = user_id);
create policy "Users can update own stacks"
  on dev_stacks for update using (auth.uid() = user_id);

-- stack_upvotes
create policy "Stack upvotes readable by all"
  on stack_upvotes for select using (true);
create policy "Users can insert own stack upvotes"
  on stack_upvotes for insert with check (auth.uid() = user_id);
create policy "Users can delete own stack upvotes"
  on stack_upvotes for delete using (auth.uid() = user_id);

-- follows
create policy "Follows readable by all"
  on follows for select using (true);
create policy "Users can follow"
  on follows for insert with check (auth.uid() = follower_id);
create policy "Users can unfollow"
  on follows for delete using (auth.uid() = follower_id);
