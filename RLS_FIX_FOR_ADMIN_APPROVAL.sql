-- ============================================
-- FIX FOR ADMIN APPROVAL SYSTEM
-- Run these SQL commands in Supabase SQL Editor
-- ============================================

-- Step 1: Drop existing restrictive policies on food_requests table
DROP POLICY IF EXISTS "Recipients can view their own requests" ON food_requests;
DROP POLICY IF EXISTS "Admins can view all pending requests" ON food_requests;

-- Step 2: Create new more permissive policies for food_requests
-- Allow recipients to see their own requests
CREATE POLICY "Recipients can view their own requests" ON food_requests 
FOR SELECT USING (auth.uid()::text = recipient_id::text);

-- Allow ANYONE authenticated to view pending requests (admins need this)
CREATE POLICY "Anyone can view pending requests" ON food_requests 
FOR SELECT USING (status = 'pending');

-- Step 3: Update policy to allow recipient to insert
DROP POLICY IF EXISTS "Recipients can insert their own requests" ON food_requests;
CREATE POLICY "Recipients can insert their own requests" ON food_requests 
FOR INSERT WITH CHECK (auth.uid()::text = recipient_id::text);

-- Step 4: Update policy to allow anyone authenticated to update (needed for admin)
DROP POLICY IF EXISTS "Admins can update request status" ON food_requests;
CREATE POLICY "Anyone authenticated can update request status" ON food_requests 
FOR UPDATE USING (true);

-- Step 5: Verify the policies are correct
-- Run this to see current policies:
SELECT * FROM pg_policies WHERE tablename = 'food_requests';

-- Step 6: Also ensure donations table has proper policies for viewing
DROP POLICY IF EXISTS "Donors can view their own donations" ON donations;
CREATE POLICY "Anyone can view all donations" ON donations 
FOR SELECT USING (true);

-- ============================================
-- If you want stricter security with admin table:
-- ============================================

-- Create admin table if not exists
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- After adding admins to the table, use these policies:
-- DROP existing policies first
DROP POLICY IF EXISTS "Anyone can view pending requests" ON food_requests;
DROP POLICY IF EXISTS "Anyone authenticated can update request status" ON food_requests;

-- Then create admin-specific policies:
CREATE POLICY "Recipients can view their own requests v2" ON food_requests 
FOR SELECT USING (auth.uid()::text = recipient_id::text);

CREATE POLICY "Admins can view all requests v2" ON food_requests 
FOR SELECT USING (EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid()));

CREATE POLICY "Admins can update request status v2" ON food_requests 
FOR UPDATE USING (EXISTS (SELECT 1 FROM admins WHERE admins.id = auth.uid()));

-- To add your admin user to the admins table, run:
-- INSERT INTO admins(id) VALUES('YOUR_AUTH_USER_ID_HERE') ON CONFLICT DO NOTHING;

-- You can find your auth user ID by:
-- SELECT id, email FROM auth.users;
