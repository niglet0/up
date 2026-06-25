-- ===================================================================
-- v4: Bounty milestones, watchers, disputes + Hiring pipeline stages
-- Run this in the Supabase SQL Editor
-- ===================================================================

-- Bounty Milestones
create table if not exists bounty_milestones (
  id            uuid primary key default gen_random_uuid(),
  bounty_id     uuid references dev_bounties(id) on delete cascade not null,
  title         text not null,
  description   text,
  sort_order    integer not null default 0,
  completed     boolean not null default false,
  completed_at  timestamptz,
  created_at    timestamptz not null default now()
);

alter table bounty_milestones enable row level security;

create policy "anyone can read bounty milestones"
  on bounty_milestones for select using (true);

create policy "poster can insert milestones"
  on bounty_milestones for insert
  with check (
    auth.uid() = (select poster_id from dev_bounties where id = bounty_id)
  );

create policy "poster can update milestones"
  on bounty_milestones for update
  using (
    auth.uid() = (select poster_id from dev_bounties where id = bounty_id)
  );

create policy "poster can delete milestones"
  on bounty_milestones for delete
  using (
    auth.uid() = (select poster_id from dev_bounties where id = bounty_id)
  );

-- Bounty Watchers
create table if not exists bounty_watchers (
  bounty_id  uuid references dev_bounties(id) on delete cascade not null,
  user_id    uuid references auth.users(id) on delete cascade not null,
  created_at timestamptz not null default now(),
  primary key (bounty_id, user_id)
);

alter table bounty_watchers enable row level security;

create policy "anyone can read watchers"
  on bounty_watchers for select using (true);

create policy "authenticated users can watch"
  on bounty_watchers for insert
  with check (auth.uid() = user_id);

create policy "users can unwatch"
  on bounty_watchers for delete
  using (auth.uid() = user_id);

-- Bounty Disputes
create table if not exists bounty_disputes (
  id          uuid primary key default gen_random_uuid(),
  bounty_id   uuid references dev_bounties(id) on delete cascade not null,
  filer_id    uuid references auth.users(id) on delete cascade not null,
  reason      text not null,
  details     text,
  status      text not null default 'open'
              check (status in ('open','under_review','resolved','dismissed')),
  created_at  timestamptz not null default now()
);

alter table bounty_disputes enable row level security;

create policy "parties can read disputes"
  on bounty_disputes for select
  using (
    auth.uid() = filer_id
    or auth.uid() = (select poster_id   from dev_bounties where id = bounty_id)
    or auth.uid() = (select claimant_id from dev_bounties where id = bounty_id)
  );

create policy "parties can file dispute"
  on bounty_disputes for insert
  with check (
    auth.uid() = user_id
    or auth.uid() = (select poster_id   from dev_bounties where id = bounty_id)
    or auth.uid() = (select claimant_id from dev_bounties where id = bounty_id)
  );

-- Hiring pipeline: ensure job_applications.stage is a known value
-- (If job_applications doesn't have a stage column yet, add it)
alter table job_applications
  add column if not exists stage text not null default 'applied'
    check (stage in ('applied','review','interview','offer','hired','rejected'));

-- Company Ops Log (lightweight activity ledger)
create table if not exists company_ops_log (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid references company_profiles(id) on delete cascade not null,
  actor_id    uuid references auth.users(id) on delete set null,
  kind        text not null,   -- 'hire','fire','sale','announcement','member_join','member_leave'
  payload     jsonb not null default '{}',
  created_at  timestamptz not null default now()
);

alter table company_ops_log enable row level security;

create policy "members can read ops log"
  on company_ops_log for select
  using (
    auth.uid() = (select owner_id from company_profiles where id = company_id)
    or exists (
      select 1 from company_members
      where company_members.company_id = company_ops_log.company_id
        and company_members.user_id = auth.uid()
    )
  );

create policy "owner can insert ops log"
  on company_ops_log for insert
  with check (
    auth.uid() = (select owner_id from company_profiles where id = company_id)
  );
