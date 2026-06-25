# Hatch (Forum Romanum)

A developer social platform with chat, marketplace, Dev Hub (Launches, Collab, Network, Stacks), and community features — all built on Supabase real-time.

## Run & Operate

- `pnpm --filter @workspace/forum-romanum run dev` — run the frontend (port 19758)
- `pnpm --filter @workspace/api-server run dev` — run the API server (port 8080)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- Required env: `DATABASE_URL` — Postgres connection string

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- Frontend: React 18 + Vite + TanStack Router (file-based)
- Auth + DB: Supabase (hardcoded URL in `src/integrations/supabase/client.ts`)
- Styling: Tailwind v4 + motion/react + sonner toasts
- API: Express 5 (for Replit-side routes)
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)

## Where things live

- Frontend: `artifacts/forum-romanum/src/`
- AppShell / routing: `artifacts/forum-romanum/src/routes/index.tsx`
- Views: `artifacts/forum-romanum/src/views/`
- Components: `artifacts/forum-romanum/src/components/`
- Supabase client: `artifacts/forum-romanum/src/integrations/supabase/client.ts`
- DB schema (API side): `lib/db/src/schema/`
- API routes: `artifacts/api-server/src/routes/`
- OpenAPI spec: `lib/api-spec/openapi.yaml`
- New Supabase tables SQL: `NEW_TABLES.sql` (run in Supabase SQL Editor)

## Architecture decisions

- Supabase handles auth, real-time, and the main DB (not Replit's built-in Postgres)
- TanStack Router with file-based routing; AppShell lives in `src/routes/index.tsx`
- Gold theme: `#C5A059`, cream: `#FAF9F6`, ink: `#202020`, muted: `#7A7A7A`
- `<Icon name="..." size={n} color="..." />` — use `color` prop, NOT `style={{ color }}`
- New panels use Supabase views (e.g. `v_launches`, `v_collab_requests`) for joined data

## Product

- **Home**: Social feed with posts, reactions, bookmarks, reposts, story bar
- **Dev Hub**: Launches (Product Hunt-style), Collab board, Bounties, Snippets, Network map, Stacks, Sponsors, Leaderboard
- **Messages**: Real-time DMs and group chats with media, polls, voice notes
- **Marketplace**: Product listings, purchases, reviews, job pipeline
- **Profile**: Activity heatmap, badges, signals analytics
- **Trending**: Trending posts and topics

## User preferences

_Populate as you build — explicit user instructions worth remembering across sessions._

## Gotchas

- Run `NEW_TABLES.sql` in Supabase SQL Editor to activate Launches/Collab/Network/Stacks features
- Run `public/v3_migration.sql` in Supabase for notifications, badges, heatmap, bookmarks, reposts
- Scaffold may create `src/lib/api/example.functions.ts` which uses `@tanstack/react-start` — delete it if it appears (not in project deps)

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
