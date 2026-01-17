-- IMMEDIATE FIX: Run this SQL in Supabase SQL Editor to fix admin approval

-- ========== FOOD_REQUESTS TABLE FIXES ==========

-- Step 1: Remove the restrictive policies that block admins
DROP POLICY IF EXISTS "Recipients can view their own requests" ON food_requests;
DROP POLICY IF EXISTS "Admins can update request status" ON food_requests;
DROP POLICY IF EXISTS "Recipients can insert their own requests" ON food_requests;
DROP POLICY IF EXISTS "Anyone can view pending requests" ON food_requests;
DROP POLICY IF EXISTS "Authenticated users can update requests" ON food_requests;

-- Step 2: Add new policies that allow admins to see ALL requests
-- Policy 1: Anyone can see pending requests (needed for admin)
CREATE POLICY "Anyone can view pending requests" ON food_requests 
FOR SELECT 
USING (status = 'pending');

-- Policy 2: Recipients can still see their own requests
CREATE POLICY "Recipients can view their own requests" ON food_requests 
FOR SELECT 
USING (auth.uid()::text = recipient_id::text);

-- Policy 3: Recipients can insert requests
CREATE POLICY "Recipients can insert requests" ON food_requests 
FOR INSERT 
WITH CHECK (auth.uid()::text = recipient_id::text);

-- Policy 4: Anyone authenticated can update (needed for admin approval)
CREATE POLICY "Authenticated users can update requests" ON food_requests 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

-- ========== DONATIONS TABLE FIXES ==========
-- Make sure admins can see all donations for approval context

DROP POLICY IF EXISTS "Anyone can view all donations" ON donations;
DROP POLICY IF EXISTS "Donors can view their own donations" ON donations;

-- Only create if it doesn't exist
CREATE POLICY "Anyone can view all donations" ON donations 
FOR SELECT 
USING (true);

-- Only create if it doesn't exist  
CREATE POLICY "Donors can update their own donations" ON donations 
FOR UPDATE 
USING (auth.uid()::text = donor_id::text);

-- ========== VERIFY ==========
-- Check food_requests policies
SELECT tablename, policyname FROM pg_policies WHERE tablename = 'food_requests' ORDER BY policyname;


