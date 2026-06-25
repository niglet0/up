---
name: Forum Romanum Network Expansion
description: What was added in the neurological network expansion — new panels, SQL, routing changes
---

## New panels created
- `src/views/dev/LaunchesPanel.tsx` — Product Hunt-style daily launches with upvote, time tabs, compose form
- `src/views/dev/CollabPanel.tsx` — Collab request board with role/stage filters, compose form
- `src/views/dev/NetworkPanel.tsx` — Network discovery: people/companies to follow, followers, activity pulse, animated network map
- `src/views/dev/StacksPanel.tsx` — Share + discover tech stacks with category tool picker and upvotes
- `src/components/SignalsPanel.tsx` — Profile analytics: post sparkline, metric cards, top post, engagement rates

## Where they're wired
- Dev Hub (CodersHub.tsx): new default tab order is Launches → Collab → Showcase → Bounties → Network → Stacks → Sponsors → Snippets → Leaderboard; opens on "Launches" by default
- Home.tsx feed: "Launches" and "Collab" tabs added before Companies/Bounties
- Profile.tsx: "signals" tab added at end of tab list
- Plus menu (routes/index.tsx): "Launch Product" → hub/launch_product, "Post Collab" → hub/post_collab

## SQL tables added (NEW_TABLES.sql at repo root)
- product_launches, launch_upvotes → v_launches view
- collab_requests, collab_upvotes → v_collab_requests view
- dev_stacks, stack_upvotes → v_dev_stacks view
- follows (user→user and user→company)

**Why:** The existing DB views (v_repos, v_bounties, v_snippets) use the same join pattern — always create a view for panels that need joined data.

**How to apply:** Any new panel that needs multiple tables should create a Supabase view and query it, not do multi-step fetches in component code.
