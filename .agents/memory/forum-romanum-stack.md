---
name: Forum Romanum Stack
description: Core stack facts and architecture decisions for the Forum Romanum / Hatch social platform.
---

## Stack
- React 18 + Vite + TanStack Router (file-based, `src/routes/index.tsx` is the AppShell)
- Supabase (hardcoded URL in `src/integrations/supabase/client.ts`, anon key there too)
- Tailwind v4 + motion/react + sonner toasts
- Theme: `#C5A059` gold, `#FAF9F6` cream, `#202020` ink, `#7A7A7A` muted
- Artifact: `artifacts/forum-romanum`, port from `PORT` env, previewPath `/`

## Icon component
`<Icon name="..." size={n} color="..." className="..." />` — does NOT accept `style` prop.
Use `color` prop for color, not `style={{ color: ... }}`.

## New tables added (v3)
Run `public/v3_migration.sql` against Supabase to activate:
- `notifications` — in-app notification dispatches with RLS
- `user_badges` — earned achievement badges
- `activity_log` — per-day activity counts for heatmap (auto-triggered on post insert + bounty approve)
- `post_bookmarks` — persistent saved posts (replaces localStorage-only)
- `post_reposts` — repost tracking

## Key component locations
- AppShell: `src/routes/index.tsx` — Bell now opens `NotificationsDrawer`
- Home feed: `src/views/Home.tsx` — bookmarks persist to DB, repost button added
- Profile: `src/views/Profile.tsx` — ActivityHeatmap + badges tab added
- CodersHub: `src/views/CodersHub.tsx` — Leaderboard tab added

**Why:** These tables were planned in the original spec but never implemented. The SQL migration file is idempotent (`IF NOT EXISTS`) so safe to run on a populated DB.
