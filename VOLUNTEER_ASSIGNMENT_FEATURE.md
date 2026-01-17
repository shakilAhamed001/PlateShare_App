# Volunteer Assignment Feature - Implementation Complete

## Overview
This feature allows admins to assign volunteers to donation deliveries when approving donation requests.

## What's Implemented

### 1. **Models** (`lib/models/volunteer_model.dart`)
- `Volunteer` class: Stores volunteer information (id, name, phone, email, status)
- `VolunteerTask` class: Represents assigned delivery tasks with status tracking

### 2. **Supabase Service** (`lib/services/supabase_service.dart`)
Added methods:
- `getAvailableVolunteers()` - Fetch all active volunteers
- `createVolunteer()` - Register a new volunteer
- `assignTaskToVolunteer()` - Create a task assignment
- `getTasksForVolunteer()` - Fetch tasks for a specific volunteer
- `updateTaskStatus()` - Update task status (assigned, in_progress, completed, cancelled)

### 3. **Donation Service** (`lib/services/donation_service.dart`)
Added methods:
- `getAvailableVolunteers()` - Wrapper to get volunteers
- `assignVolunteerToTask()` - Assign volunteer to task
- `approveRequestWithVolunteer()` - Approve request AND assign volunteer in one operation

### 4. **Admin Approval Flow** (`lib/pages/approve_requests.dart`)
- Modified approve button to open volunteer selection dialog
- Dialog shows list of available volunteers
- When volunteer is selected, request is approved AND volunteer is assigned
- Recipient notification includes volunteer assignment info

### 5. **Volunteer Dashboard** (`lib/pages/volunteer_tasks.dart`)
Complete rewrite:
- Displays tasks assigned to the logged-in volunteer
- Shows task status with color-coded badges
- Allows volunteer to update task status:
  - `assigned` → Start task
  - `in_progress` → Mark as completed
  - Cancel tasks at any time
- Refresh button to reload tasks

## Database Schema Required

You need to create these tables in your Supabase database:

### Table: `volunteers`
```sql
CREATE TABLE volunteers (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  status TEXT DEFAULT 'active', -- 'active', 'inactive', 'on_leave'
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: `volunteer_tasks`
```sql
CREATE TABLE volunteer_tasks (
  id TEXT PRIMARY KEY,
  donation_id UUID NOT NULL,
  volunteer_id UUID NOT NULL,
  status TEXT DEFAULT 'assigned', -- 'assigned', 'in_progress', 'completed', 'cancelled'
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  notes TEXT,
  FOREIGN KEY (donation_id) REFERENCES donations(id),
  FOREIGN KEY (volunteer_id) REFERENCES volunteers(id)
);
```

## Row Level Security (RLS)

Apply these RLS policies:

### For `volunteers` table:
```sql
-- Allow anyone to read volunteers
CREATE POLICY "Volunteers are viewable by everyone" ON volunteers
  FOR SELECT USING (true);

-- Allow volunteers to update their own status
CREATE POLICY "Volunteers can update themselves" ON volunteers
  FOR UPDATE USING (auth.uid() = id);
```

### For `volunteer_tasks` table:
```sql
-- Allow volunteers to see their assigned tasks
CREATE POLICY "Volunteers can view own tasks" ON volunteer_tasks
  FOR SELECT USING (auth.uid() = volunteer_id);

-- Allow volunteers to update their tasks
CREATE POLICY "Volunteers can update own tasks" ON volunteer_tasks
  FOR UPDATE USING (auth.uid() = volunteer_id);

-- Allow admins to insert tasks
CREATE POLICY "Admins can create tasks" ON volunteer_tasks
  FOR INSERT WITH CHECK (true);
```

## How to Use

### For Admins:
1. Go to "Approve Requests" page
2. View pending donation requests
3. Click "Approve" button
4. Select a volunteer from the dialog
5. The request is approved and volunteer is assigned

### For Volunteers:
1. Go to "My Tasks" from volunteer dashboard
2. See all assigned delivery tasks
3. Click "Start" to mark task as in_progress
4. Click "Complete" when delivery is done
5. Can cancel tasks if needed

## Task Status Flow

```
assigned → in_progress → completed
   ↓
cancelled (at any point)
```

## Files Modified/Created

- ✅ `lib/models/volunteer_model.dart` - **CREATED**
- ✅ `lib/services/supabase_service.dart` - **MODIFIED** (added volunteer methods)
- ✅ `lib/services/donation_service.dart` - **MODIFIED** (added volunteer methods)
- ✅ `lib/pages/approve_requests.dart` - **MODIFIED** (added volunteer selection dialog)
- ✅ `lib/pages/volunteer_tasks.dart` - **COMPLETELY REWRITTEN**

## Next Steps

1. **Create the database tables** using the SQL schema provided above
2. **Set up RLS policies** as shown above
3. **Add volunteers** to the database (test data or through admin panel)
4. **Test the feature**:
   - Create a donation request
   - Go to Approve Requests
   - Click Approve and select a volunteer
   - Login as volunteer to see the assigned task
   - Update task status

## Notifications

When a request is approved with volunteer assignment:
- Recipient gets notified: "Your request has been approved. A volunteer has been assigned to help with delivery."

## Error Handling

The app handles:
- No volunteers available (shows message)
- Database connection errors
- Missing volunteer/task data
- RLS policy violations (graceful fallback)
