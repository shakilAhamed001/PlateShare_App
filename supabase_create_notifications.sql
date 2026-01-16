-- Migration: create notifications table
-- Run this in the Supabase SQL editor or via psql against your database.

BEGIN;

-- If you prefer gen_random_uuid(), ensure the pgcrypto extension is enabled.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id uuid NOT NULL REFERENCES recipients(id) ON DELETE CASCADE,
  message text NOT NULL,
  donation_id uuid REFERENCES donations(id) ON DELETE SET NULL,
  read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

COMMIT;

-- Notes:
-- 1) If your DB uses uuid-ossp, replace `gen_random_uuid()` with `uuid_generate_v4()` and
--    create the extension: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`
-- 2) Run this file in the Supabase SQL editor or with psql:
--    psql "postgresql://<user>:<pass>@<host>:<port>/<db>" -f supabase_create_notifications.sql
