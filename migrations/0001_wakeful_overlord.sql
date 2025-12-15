CREATE TYPE "public"."task_schedule_rule_type" AS ENUM('DAILY', 'WEEKLY', 'INTERVAL');--> statement-breakpoint
CREATE TYPE "public"."task_source" AS ENUM('SCHEDULED', 'MANUAL', 'ADHOC', 'LEGACY');--> statement-breakpoint
CREATE TABLE "box_placements" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"box_id" varchar NOT NULL,
	"stand_id" varchar NOT NULL,
	"position_index" integer,
	"placed_at" timestamp DEFAULT now() NOT NULL,
	"removed_at" timestamp,
	"placed_by_user_id" varchar,
	"removed_by_user_id" varchar
);
--> statement-breakpoint
CREATE TABLE "task_pickup_items" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"task_id" varchar NOT NULL,
	"stand_id" varchar NOT NULL,
	"required_count" integer DEFAULT 1 NOT NULL,
	"scanned_count" integer DEFAULT 0 NOT NULL,
	"material_id" varchar,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "task_pickup_scans" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"task_id" varchar NOT NULL,
	"stand_id" varchar NOT NULL,
	"box_id" varchar NOT NULL,
	"scanned_at" timestamp DEFAULT now() NOT NULL,
	"scanned_by_user_id" varchar
);
--> statement-breakpoint
CREATE TABLE "task_schedules" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"stand_id" varchar NOT NULL,
	"station_id" varchar,
	"rule_type" text NOT NULL,
	"time_local" text NOT NULL,
	"weekdays" integer[],
	"every_n_days" integer,
	"start_date" timestamp,
	"timezone" text DEFAULT 'Europe/Berlin' NOT NULL,
	"create_days_ahead" integer DEFAULT 7 NOT NULL,
	"created_by_id" varchar,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "tasks" ALTER COLUMN "container_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "halls" ADD COLUMN "position_meta" jsonb;--> statement-breakpoint
ALTER TABLE "halls" ADD COLUMN "qr_code" text;--> statement-breakpoint
ALTER TABLE "stands" ADD COLUMN "max_slots" integer DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE "stations" ADD COLUMN "position_meta" jsonb;--> statement-breakpoint
ALTER TABLE "stations" ADD COLUMN "qr_code" text;--> statement-breakpoint
ALTER TABLE "tasks" ADD COLUMN "source" text DEFAULT 'LEGACY' NOT NULL;--> statement-breakpoint
ALTER TABLE "tasks" ADD COLUMN "schedule_id" varchar;--> statement-breakpoint
ALTER TABLE "warehouse_containers" ADD COLUMN "notes" text;--> statement-breakpoint
ALTER TABLE "box_placements" ADD CONSTRAINT "box_placements_box_id_boxes_id_fk" FOREIGN KEY ("box_id") REFERENCES "public"."boxes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "box_placements" ADD CONSTRAINT "box_placements_stand_id_stands_id_fk" FOREIGN KEY ("stand_id") REFERENCES "public"."stands"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "box_placements" ADD CONSTRAINT "box_placements_placed_by_user_id_users_id_fk" FOREIGN KEY ("placed_by_user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "box_placements" ADD CONSTRAINT "box_placements_removed_by_user_id_users_id_fk" FOREIGN KEY ("removed_by_user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_items" ADD CONSTRAINT "task_pickup_items_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_items" ADD CONSTRAINT "task_pickup_items_stand_id_stands_id_fk" FOREIGN KEY ("stand_id") REFERENCES "public"."stands"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_items" ADD CONSTRAINT "task_pickup_items_material_id_materials_id_fk" FOREIGN KEY ("material_id") REFERENCES "public"."materials"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_scans" ADD CONSTRAINT "task_pickup_scans_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_scans" ADD CONSTRAINT "task_pickup_scans_stand_id_stands_id_fk" FOREIGN KEY ("stand_id") REFERENCES "public"."stands"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_scans" ADD CONSTRAINT "task_pickup_scans_box_id_boxes_id_fk" FOREIGN KEY ("box_id") REFERENCES "public"."boxes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_pickup_scans" ADD CONSTRAINT "task_pickup_scans_scanned_by_user_id_users_id_fk" FOREIGN KEY ("scanned_by_user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_schedules" ADD CONSTRAINT "task_schedules_stand_id_stands_id_fk" FOREIGN KEY ("stand_id") REFERENCES "public"."stands"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_schedules" ADD CONSTRAINT "task_schedules_station_id_stations_id_fk" FOREIGN KEY ("station_id") REFERENCES "public"."stations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_schedules" ADD CONSTRAINT "task_schedules_created_by_id_users_id_fk" FOREIGN KEY ("created_by_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "uq_box_active" ON "box_placements" USING btree ("box_id") WHERE "box_placements"."removed_at" IS NULL;--> statement-breakpoint
CREATE INDEX "idx_box" ON "box_placements" USING btree ("box_id");--> statement-breakpoint
CREATE INDEX "idx_stand" ON "box_placements" USING btree ("stand_id");--> statement-breakpoint
CREATE UNIQUE INDEX "task_pickup_items_task_stand_unique" ON "task_pickup_items" USING btree ("task_id","stand_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uq_task_box" ON "task_pickup_scans" USING btree ("task_id","box_id");--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_schedule_id_task_schedules_id_fk" FOREIGN KEY ("schedule_id") REFERENCES "public"."task_schedules"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "halls" ADD CONSTRAINT "halls_qr_code_unique" UNIQUE("qr_code");--> statement-breakpoint
ALTER TABLE "stands" ADD CONSTRAINT "stands_identifier_unique" UNIQUE("identifier");--> statement-breakpoint
ALTER TABLE "stations" ADD CONSTRAINT "stations_code_unique" UNIQUE("code");--> statement-breakpoint
ALTER TABLE "stations" ADD CONSTRAINT "stations_qr_code_unique" UNIQUE("qr_code");