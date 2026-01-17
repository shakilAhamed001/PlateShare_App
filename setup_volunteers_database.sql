-- ============================================================================
-- VOLUNTEER ASSIGNMENT FEATURE - DATABASE SETUP SCRIPT
-- ============================================================================
-- Run this script in your Supabase SQL Editor to set up the volunteer system
-- ============================================================================

-- ============================================================================
-- 1. CREATE VOLUNTEERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.volunteers (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'on_leave')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on status for faster queries
CREATE INDEX IF NOT EXISTS idx_volunteers_status ON public.volunteers(status);

-- ============================================================================
-- 2. CREATE VOLUNTEER TASKS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.volunteer_tasks (
  id TEXT PRIMARY KEY,
  donation_id UUID NOT NULL,
  volunteer_id UUID NOT NULL,
  status TEXT DEFAULT 'assigned' CHECK (status IN ('assigned', 'in_progress', 'completed', 'cancelled')),
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_volunteer_tasks_donation FOREIGN KEY (donation_id) 
    REFERENCES public.donations(id) ON DELETE CASCADE,
  CONSTRAINT fk_volunteer_tasks_volunteer FOREIGN KEY (volunteer_id) 
    REFERENCES public.volunteers(id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_volunteer_tasks_volunteer_id ON public.volunteer_tasks(volunteer_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_tasks_donation_id ON public.volunteer_tasks(donation_id);
CREATE INDEX IF NOT EXISTS idx_volunteer_tasks_status ON public.volunteer_tasks(status);

-- ============================================================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE public.volunteers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.volunteer_tasks ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 4. CREATE RLS POLICIES FOR VOLUNTEERS TABLE
-- ============================================================================

-- Policy 1: Anyone can read volunteers (for displaying in admin panel)
CREATE POLICY "Volunteers are viewable by everyone"
  ON public.volunteers
  FOR SELECT
  USING (true);

-- Policy 2: Only volunteers can update themselves
CREATE POLICY "Volunteers can update themselves"
  ON public.volunteers
  FOR UPDATE
  USING (auth.uid() = id);

-- Policy 3: Admins can insert volunteers (optional - restrict as needed)
CREATE POLICY "Authorized users can create volunteers"
  ON public.volunteers
  FOR INSERT
  WITH CHECK (true); -- Restrict this if you want only admins to create volunteers

-- ============================================================================
-- 5. CREATE RLS POLICIES FOR VOLUNTEER TASKS TABLE
-- ============================================================================

-- Policy 1: Volunteers can view their own tasks
CREATE POLICY "Volunteers can view own tasks"
  ON public.volunteer_tasks
  FOR SELECT
  USING (auth.uid() = volunteer_id);

-- Policy 2: Volunteers can update their own tasks (status, notes, etc.)
CREATE POLICY "Volunteers can update own tasks"
  ON public.volunteer_tasks
  FOR UPDATE
  USING (auth.uid() = volunteer_id)
  WITH CHECK (auth.uid() = volunteer_id);

-- Policy 3: System/Admin can insert tasks
CREATE POLICY "Admins can create tasks"
  ON public.volunteer_tasks
  FOR INSERT
  WITH CHECK (true); -- Restrict this if you want only specific admins to create tasks

-- ============================================================================
-- 6. SAMPLE DATA (OPTIONAL - Comment out if not needed)
-- ============================================================================
-- Uncomment to add sample volunteers for testing

/*
INSERT INTO public.volunteers (id, name, phone, email, status)
VALUES
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'Ahmed Hassan', '01700000001', 'ahmed@example.com', 'active'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'Fatima Khan', '01700000002', 'fatima@example.com', 'active'),
  ('550e8400-e29b-41d4-a716-446655440003'::uuid, 'Karim Ali', '01700000003', 'karim@example.com', 'active'),
  ('550e8400-e29b-41d4-a716-446655440004'::uuid, 'Aisha Rahim', '01700000004', 'aisha@example.com', 'active'),
  ('550e8400-e29b-41d4-a716-446655440005'::uuid, 'Mohammad Hossain', '01700000005', 'mohammad@example.com', 'inactive');

-- Sample task (use real donation_id from your donations table)
-- INSERT INTO public.volunteer_tasks (id, donation_id, volunteer_id, status, notes)
-- VALUES
--   ('task-001', '123e4567-e89b-12d3-a456-426614174000'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'assigned', 'Deliver to 123 Main Street');
*/

-- ============================================================================
-- 7. VERIFY SETUP
-- ============================================================================
-- Run these queries to verify everything is set up correctly:

-- Check volunteers table
-- SELECT * FROM public.volunteers;

-- Check volunteer_tasks table
-- SELECT * FROM public.volunteer_tasks;

-- Check RLS is enabled
-- SELECT tablename, rowsecurity FROM pg_tables 
-- WHERE schemaname = 'public' AND tablename IN ('volunteers', 'volunteer_tasks');

-- ============================================================================
-- 8. NOTES
-- ============================================================================
/*
1. Volunteer Status Values:
   - 'active': Volunteer is available for tasks
   - 'inactive': Volunteer is not available
   - 'on_leave': Volunteer is temporarily unavailable

2. Task Status Values:
   - 'assigned': Task just assigned, not started
   - 'in_progress': Volunteer is working on the task
   - 'completed': Task completed successfully
   - 'cancelled': Task was cancelled

3. Foreign Keys:
   - volunteer_tasks.donation_id → donations.id (CASCADE DELETE)
   - volunteer_tasks.volunteer_id → volunteers.id (CASCADE DELETE)
   - This means deleting a donation or volunteer will delete their tasks

4. RLS Policies Explanation:
   - Any user can read the volunteers list
   - Only a volunteer can update their own profile
   - Only a volunteer can see and update their own tasks
   - Anyone can create tasks (but typically only admins should)

5. To Restrict Task Creation to Admins:
   Change the INSERT policy to:
   
   CREATE POLICY "Only admins can create tasks"
     ON public.volunteer_tasks
     FOR INSERT
     WITH CHECK (
       auth.jwt() ->> 'user_role' = 'admin' OR
       auth.jwt() ->> 'custom_claim' = 'admin_user'
     );
   
   (This assumes your JWT token includes a user_role or custom_claim field)
*/

-- ============================================================================
-- END OF SETUP SCRIPT
-- ============================================================================
