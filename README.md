# ContainerFlow Backend/App

- Install & run
  - `npm install`
  - Backend dev: `npm run server:dev`
  - Expo dev: `npm run expo:dev`
  - Type check: `npm run check:types`

- Environment
  - `DATABASE_URL` must point to Postgres/Supabase.
  - Mobile API base uses `EXPO_PUBLIC_API_URL` (full https://host:port) or falls back to `EXPO_PUBLIC_DOMAIN`.

- Migrations
  - New placement + multi-pickup schema lives in `migrations/0002_placements_and_pickups.sql`.
  - Apply after existing schema (adds `box_placements`, `task_pickup_items`, `task_pickup_scans`, `stands.max_slots`, global uniqueness for station/stand codes).

- Naming generator
  - `npx tsx scripts/generate-names.ts --boxes --count 300 --sql` (BOX-001..300 SQL)
  - `npx tsx scripts/generate-names.ts --stands --hall H-E15 --station 07 --count 8 --prefix E`
  - `npx tsx scripts/generate-names.ts --warehouses --material CU --count 2 --sql`
