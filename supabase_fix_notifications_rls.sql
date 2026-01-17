-- ============================================
-- FIX FOR NOTIFICATIONS RLS POLICY
-- Admin Approval System - Notifications Permission
-- ============================================

-- IMPORTANT: Run this in Supabase SQL Editor with Service Role or psql

BEGIN;

-- Drop ALL existing notification policies to start fresh
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;
DROP POLICY IF EXISTS "Anyone authenticated can insert notifications" ON notifications;
DROP POLICY IF EXISTS "Recipients can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Recipients can update their own notifications" ON notifications;

-- Create fresh policies for notifications
-- Allow ANY authenticated user to insert notifications
-- (This is needed so admins can create notifications when approving requests)
CREATE POLICY "Anyone authenticated can insert notifications" ON notifications 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

-- Recipients can view their own notifications
CREATE POLICY "Recipients can view their own notifications" ON notifications 
FOR SELECT 
USING (auth.uid()::text = recipient_id::text);

-- Allow recipients to update their own notifications (mark as read)
CREATE POLICY "Recipients can update their own notifications" ON notifications 
FOR UPDATE 
USING (auth.uid()::text = recipient_id::text);

COMMIT;

-- Verify the policies
SELECT policyname, cmd as operation
FROM pg_policies 
WHERE tablename = 'notifications'
ORDER BY policyname;

-- Expected output should show:
-- Anyone authenticated can insert notifications     | *
-- Recipients can update their own notifications    | UPDATE
-- Recipients can view their own notifications      | SELECT
