-- Migration: introduce placement history + multi-box pickup support
-- This file is handcrafted to align with the updated Drizzle schema.ts.

-- 1) Stand capacity + uniqueness
ALTER TABLE stands
  ADD COLUMN IF NOT EXISTS max_slots integer NOT NULL DEFAULT 1;

DO $$
BEGIN
  ALTER TABLE stands ADD CONSTRAINT stands_identifier_unique UNIQUE (identifier);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Station codes must be globally unique (drop legacy hall+code uniqueness)
DO $$
BEGIN
  ALTER TABLE stations DROP CONSTRAINT IF EXISTS stations_hall_id_code_unique;
EXCEPTION
  WHEN undefined_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE stations ADD CONSTRAINT stations_code_unique UNIQUE (code);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- 2) Placement history for boxes
CREATE TABLE IF NOT EXISTS box_placements (
  id varchar PRIMARY KEY DEFAULT gen_random_uuid(),
  box_id varchar NOT NULL REFERENCES boxes(id),
  stand_id varchar NOT NULL REFERENCES stands(id),
  position_index integer,
  placed_at timestamp NOT NULL DEFAULT now(),
  removed_at timestamp,
  placed_by_user_id varchar REFERENCES users(id),
  removed_by_user_id varchar REFERENCES users(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS box_placements_box_id_active_unique
  ON box_placements (box_id)
  WHERE removed_at IS NULL;

CREATE INDEX IF NOT EXISTS box_placements_stand_id_idx
  ON box_placements (stand_id)
  WHERE removed_at IS NULL;

-- 3) Multi-box pickup tracking
CREATE TABLE IF NOT EXISTS task_pickup_items (
  id varchar PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id varchar NOT NULL REFERENCES tasks(id),
  stand_id varchar NOT NULL REFERENCES stands(id),
  required_count integer NOT NULL DEFAULT 1,
  scanned_count integer NOT NULL DEFAULT 0,
  material_id varchar REFERENCES materials(id),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS task_pickup_items_task_stand_unique
  ON task_pickup_items (task_id, stand_id);

CREATE TABLE IF NOT EXISTS task_pickup_scans (
  id varchar PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id varchar NOT NULL REFERENCES tasks(id),
  stand_id varchar NOT NULL REFERENCES stands(id),
  box_id varchar NOT NULL REFERENCES boxes(id),
  scanned_at timestamp NOT NULL DEFAULT now(),
  scanned_by_user_id varchar REFERENCES users(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS task_pickup_scans_task_box_unique
  ON task_pickup_scans (task_id, box_id);
