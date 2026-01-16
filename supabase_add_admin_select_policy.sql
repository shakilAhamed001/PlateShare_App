-- Migration: allow admin users to SELECT food_requests
-- Run this in the Supabase SQL editor with a service role or via psql.

BEGIN;

-- Drop existing policy if present
DROP POLICY IF EXISTS "Admins can view pending requests" ON food_requests;

-- Allow recipients to view their own requests or allow users whose JWT contains {"role":"admin"}
CREATE POLICY "Admins can view pending requests" ON food_requests
  FOR SELECT
  USING (
    auth.uid()::text = recipient_id::text
    OR (auth.jwt() ->> 'role') = 'admin'
  );

COMMIT;

-- Notes:
-- 1) Supabase does not set a 'role' claim by default. You must add a custom claim
--    to the user's JWT (for example by updating `raw_user_meta_data` in `auth.users`),
--    or use your own admins table/logic and adjust the policy accordingly.
-- 2) To make a user an admin via SQL (requires service_role key):
--    UPDATE auth.users
--    SET raw_user_meta_data = jsonb_set(coalesce(raw_user_meta_data,'{}'), '{role}', '"admin"')
--    WHERE id = '<USER_UUID>';
-- 3) Alternatively set metadata in the Supabase Dashboard -> Authentication -> Users -> Edit User.
