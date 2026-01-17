# Admin Approval System - Complete Setup Guide

## Problem
Admin cannot see pending requests in the "Approve Requests" page because of Supabase Row Level Security (RLS) policies.

## Solution

### Step 1: Log into Supabase Dashboard
1. Go to https://app.supabase.com
2. Select your PlateShare project

### Step 2: Run the SQL Fix
1. Go to **SQL Editor** in the left sidebar
2. Click **+ New Query**
3. Copy and paste the following SQL:

```sql
-- STEP 1: Remove restrictive policies
DROP POLICY IF EXISTS "Recipients can view their own requests" ON food_requests;
DROP POLICY IF EXISTS "Admins can update request status" ON food_requests;
DROP POLICY IF EXISTS "Recipients can insert their own requests" ON food_requests;

-- STEP 2: Create new permissive policies that allow admins to see and update requests
-- Allow anyone authenticated to view pending requests
CREATE POLICY "Anyone can view pending requests" ON food_requests 
FOR SELECT 
USING (status = 'pending' OR auth.uid()::text = recipient_id::text);

-- Allow recipients to insert their own requests
CREATE POLICY "Recipients can insert requests" ON food_requests 
FOR INSERT 
WITH CHECK (auth.uid()::text = recipient_id::text);

-- Allow anyone authenticated to update requests (needed for admin approval)
CREATE POLICY "Authenticated users can update requests" ON food_requests 
FOR UPDATE 
USING (auth.uid() IS NOT NULL);

-- VERIFY: Check the policies are correct
SELECT tablename, policyname FROM pg_policies WHERE tablename = 'food_requests';
```

4. Click **Run** (Ctrl+Enter)
5. You should see output showing the food_requests policies

### Step 3: Verify in Your App

1. Open the app
2. Login as Admin user
3. Go to Admin Panel → Approve Requests
4. You should now see pending requests (if any recipients have made requests)

## If it Still Doesn't Work

### Debugging Steps:

1. **Check if any requests exist:**
   - In Supabase SQL Editor, run:
   ```sql
   SELECT * FROM food_requests;
   SELECT * FROM donations;
   SELECT * FROM recipients;
   ```

2. **Check RLS is enabled:**
   ```sql
   SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'food_requests';
   ```
   Should return TRUE for rowsecurity

3. **View current policies:**
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'food_requests';
   ```

4. **Test with anon role (if needed):**
   - If the above doesn't work, you may need to disable RLS temporarily:
   ```sql
   ALTER TABLE food_requests DISABLE ROW LEVEL SECURITY;
   ```
   - But this is NOT recommended for production. Better to fix the policies properly.

## Complete RLS Policy Setup (Recommended)

If you want more security with role-based access control, use this:

```sql
-- Drop all existing policies first
DROP POLICY IF EXISTS "Anyone can view pending requests" ON food_requests;
DROP POLICY IF EXISTS "Recipients can insert requests" ON food_requests;
DROP POLICY IF EXISTS "Authenticated users can update requests" ON food_requests;

-- Create admin table to track admins
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Allow admins to be viewed
CREATE POLICY "Admin table readable" ON admins FOR SELECT USING (true);

-- NEW POLICIES:
-- 1. Recipients can see their own requests
CREATE POLICY "Recipients see own requests" ON food_requests 
FOR SELECT 
USING (auth.uid()::text = recipient_id::text);

-- 2. Admins can see all pending requests
CREATE POLICY "Admins see all requests" ON food_requests 
FOR SELECT 
USING (EXISTS(SELECT 1 FROM admins WHERE admins.id = auth.uid()));

-- 3. Recipients can submit requests
CREATE POLICY "Recipients can insert requests" ON food_requests 
FOR INSERT 
WITH CHECK (auth.uid()::text = recipient_id::text);

-- 4. Admins can approve/reject requests
CREATE POLICY "Admins update requests" ON food_requests 
FOR UPDATE 
USING (EXISTS(SELECT 1 FROM admins WHERE admins.id = auth.uid()));

-- ADD YOUR ADMIN USER (replace with your actual user ID)
-- Get your user ID from: SELECT id, email FROM auth.users;
-- Then run:
-- INSERT INTO admins(id) VALUES('YOUR_USER_ID_HERE') ON CONFLICT DO NOTHING;
```

## Testing the System

### As a Recipient:
1. Login as recipient
2. Go to "Request Food" or "Browse Donations"
3. Click "Request" on a donation
4. Should see "Food request submitted!"

### As an Admin:
1. Login as admin user
2. Go to Admin Panel → Approve Requests
3. You should see the pending requests
4. Click "Approve" or "Reject"
5. Recipient should get a notification

## Contact
If you still have issues after running the SQL, check:
- The console output in VS Code (should show debug logs with `Loaded X requests`)
- The Supabase logs in the dashboard
- That you're logged in as the correct user
