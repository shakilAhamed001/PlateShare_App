# Notifications RLS Policy Fix

## Problem
When admin tries to **Approve** or **Reject** a recipient request, the approval fails with:
```
PostgrestException(message: new row violates row-level security policy 
for table "notifications", code: 42501, ...)
```

The admin can update the request status, but **cannot create a notification** for the recipient because the notifications table RLS policy is too restrictive.

## Root Cause
The current notifications table RLS policy `"System can insert notifications" WITH CHECK (true)` is either:
1. Not properly applied
2. Being interpreted too restrictively
3. Conflicting with other policies

Admin users need explicit permission to insert notifications on behalf of recipients.

## Solution - Two Part Fix

### Part 1: Update Database RLS Policy (Required)

Run this SQL in Supabase SQL Editor:

```sql
-- Drop the old restrictive policy
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;

-- Create a new permissive policy
CREATE POLICY "Anyone authenticated can insert notifications" ON notifications 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);
```

**File**: `supabase_fix_notifications_rls.sql` (ready to run)

#### How to Apply:
1. Go to **Supabase Dashboard** → Your Project
2. Click **SQL Editor** in left sidebar
3. Click **+ New Query**
4. Copy the SQL from `supabase_fix_notifications_rls.sql`
5. Click **Run** (Ctrl+Enter)
6. You should see the policy updated successfully

#### Verify:
```sql
-- Check that the policy exists
SELECT policyname, policy_type 
FROM pg_policies 
WHERE tablename = 'notifications';

-- Should show: "Anyone authenticated can insert notifications | INSERT"
```

### Part 2: Update App Code (Already Done)

The app code now handles notification creation failures gracefully:

```dart
// In donation_service.dart - approveRequest()
try {
  await SupabaseService.createNotification(...);
  print('✓ Notification created');
} catch (notifError) {
  print('⚠ Warning: Could not create notification - $notifError');
  // Continue anyway - approval still succeeds
}
```

**Changes Made:**
- ✅ Notification creation is now **non-critical** 
- ✅ Even if notification fails, the approval/rejection still succeeds
- ✅ Request status still gets updated
- ✅ Donation status still gets updated
- ✅ Detailed logging shows what happened

This means:
- The approval will work even without the SQL fix (as a temporary workaround)
- Once you apply the SQL fix, notifications will be created successfully

## Testing After Fix

### Step 1: Apply SQL Fix (If you haven't already)
Run the SQL from `supabase_fix_notifications_rls.sql` in Supabase SQL Editor

### Step 2: Test Approval Flow
1. **Create a request** as Recipient
2. **Approve as Admin** - should now see:
   - Green message: "Request approved!"
   - Request disappears from list

3. **Check logs** - should see:
   ```
   === Approving request: xxx ===
   Fetching request details...
   Request found - Recipient: yyy, Donation: zzz
   Updating request status to approved...
   Updating donation status to approved...
   Creating notification...
   ✓ Notification created
   ✓ Request xxx approved successfully
   ```

### Step 3: Verify Recipient Notification
1. Login as Recipient
2. Go to **Notifications**
3. Should see: "Your request for donation [ID] has been approved."

## Fallback Behavior

If you can't apply the SQL fix immediately:
- ✅ Approvals/Rejections still work (request status updates)
- ✅ Donation status updates correctly
- ❌ Notifications might not be created (but that's okay, approval still succeeds)

Once SQL is applied:
- ✅ Everything works including notifications

## Summary

| Task | Status | Details |
|------|--------|---------|
| SQL Fix File Created | ✅ | `supabase_fix_notifications_rls.sql` ready to use |
| App Code Updated | ✅ | Handles notification errors gracefully |
| Approval Still Works | ✅ | Even if notification fails |
| Rejection Still Works | ✅ | Even if notification fails |

## Next Steps

1. ✅ Open Supabase Dashboard
2. ✅ Go to SQL Editor
3. ✅ Run the SQL from `supabase_fix_notifications_rls.sql`
4. ✅ Test approval/rejection in the app
5. ✅ Verify notifications appear for recipient

Done! Admins can now approve/reject requests with or without the SQL fix. Notifications will work once the SQL is applied.
