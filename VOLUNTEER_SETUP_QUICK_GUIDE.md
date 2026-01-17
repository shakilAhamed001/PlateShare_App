# Volunteer Assignment Feature - Quick Setup Guide

## 🎯 Feature Summary

When an admin approves a donation request, they can now:
1. Click "Approve" button
2. Select a volunteer from the available list
3. The request is approved AND the volunteer is assigned the delivery task

The volunteer then sees the task in their "My Tasks" dashboard and can track progress.

---

## 📋 Files Created/Modified

| File | Status | Changes |
|------|--------|---------|
| `lib/models/volunteer_model.dart` | ✅ CREATED | New Volunteer & VolunteerTask classes |
| `lib/services/supabase_service.dart` | ✅ MODIFIED | Added 5 volunteer-related methods |
| `lib/services/donation_service.dart` | ✅ MODIFIED | Added 3 wrapper methods |
| `lib/pages/approve_requests.dart` | ✅ MODIFIED | Added volunteer selection dialog |
| `lib/pages/volunteer_tasks.dart` | ✅ REWRITTEN | Displays real tasks from database |

---

## 🗄️ Database Setup Required

### Create these 2 tables in Supabase:

```sql
-- Table 1: Volunteers
CREATE TABLE volunteers (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: Volunteer Tasks
CREATE TABLE volunteer_tasks (
  id TEXT PRIMARY KEY,
  donation_id UUID NOT NULL,
  volunteer_id UUID NOT NULL,
  status TEXT DEFAULT 'assigned',
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  notes TEXT,
  FOREIGN KEY (donation_id) REFERENCES donations(id),
  FOREIGN KEY (volunteer_id) REFERENCES volunteers(id)
);
```

### Enable RLS and add policies:

```sql
ALTER TABLE volunteers ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_tasks ENABLE ROW LEVEL SECURITY;

-- Allow reading volunteers
CREATE POLICY "Volunteers readable" ON volunteers FOR SELECT USING (true);

-- Volunteers can see their tasks
CREATE POLICY "Own tasks" ON volunteer_tasks FOR SELECT USING (auth.uid() = volunteer_id);

-- Volunteers can update their tasks
CREATE POLICY "Update own tasks" ON volunteer_tasks FOR UPDATE USING (auth.uid() = volunteer_id);

-- Allow admin to create tasks
CREATE POLICY "Admin create tasks" ON volunteer_tasks FOR INSERT WITH CHECK (true);
```

---

## 🚀 How It Works

### **Admin Perspective:**
```
View Approval Page → Click Approve → Select Volunteer → Task Auto-Assigned
```

### **Volunteer Perspective:**
```
View My Tasks → See Assigned Donations → Click Start → Update Progress → Complete
```

---

## 📱 User Interface Changes

### **Approve Requests Page**
- Approve button now opens a volunteer selection dialog
- Shows all active volunteers (name + phone)
- Volunteers are sorted alphabetically

### **Volunteer Tasks Page (Completely New)**
- Shows all tasks assigned to logged-in volunteer
- Status badges: Assigned (blue), In Progress (orange), Completed (green), Cancelled (grey)
- Action buttons based on current status:
  - **Assigned** → Click "Start" to begin
  - **In Progress** → Click "Complete" when done
  - **Any status** → Click "Cancel" to cancel task

---

## 🔄 Task Status Flow

```
┌─────────────┐
│  ASSIGNED   │  ← Initial status when volunteer is assigned
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  IN_PROGRESS    │  ← Volunteer clicks "Start"
└──────┬──────────┘
       │
       ▼
┌─────────────┐
│ COMPLETED   │  ← Volunteer clicks "Complete"
└─────────────┘
```

Plus: Can be cancelled at any time.

---

## 🧪 Testing Steps

1. **Create test volunteer:**
   - Run SQL: `INSERT INTO volunteers VALUES (uuid_generate_v4(), 'John Volunteer', '1234567890', 'john@example.com', 'active', NOW());`

2. **Create test donation:**
   - Use the app to create a donation

3. **Request the donation:**
   - As recipient, request the donation

4. **Approve with volunteer:**
   - As admin, go to Approve Requests
   - Click Approve
   - Select the volunteer
   - Request should be approved

5. **View task as volunteer:**
   - Login as the volunteer
   - Go to Volunteer Dashboard → My Tasks
   - You should see the assigned task

6. **Update task status:**
   - Click "Start" to begin
   - Click "Complete" when done

---

## 🔧 Key Methods

### **DonationService**
```dart
// Get all active volunteers
List<Volunteer> volunteers = await DonationService.getAvailableVolunteers();

// Approve request AND assign volunteer (combined operation)
await DonationService.approveRequestWithVolunteer(requestId, volunteerId);

// Assign volunteer to a task
await DonationService.assignVolunteerToTask(donationId, volunteerId);
```

### **SupabaseService**
```dart
// Get volunteers
await SupabaseService.getAvailableVolunteers();

// Manage tasks
await SupabaseService.assignTaskToVolunteer(donationId, volunteerId);
await SupabaseService.getTasksForVolunteer(volunteerId);
await SupabaseService.updateTaskStatus(taskId, newStatus);
```

---

## ⚠️ Important Notes

1. **Volunteer records** must exist in the database before they can be assigned
2. **RLS policies** must be configured correctly or volunteers won't see their tasks
3. **Only active volunteers** (status = 'active') appear in the selection dialog
4. **Notifications** are automatically sent to recipients when request is approved

---

## 🎓 What Changed

### Old Flow (Before)
- Admin clicks Approve
- Request is immediately approved
- No volunteer assignment

### New Flow (After)
- Admin clicks Approve
- Dialog appears with volunteer list
- Admin selects volunteer
- Request is approved + Volunteer is assigned + Notification sent

---

## 💡 Future Enhancements

- Add ability for admins to manually create/manage volunteers
- Add volunteer availability/scheduling
- Add task notes and delivery proof (photos)
- Add performance ratings for volunteers
- Add volunteer management dashboard for admins

---

## 📞 Support

If you encounter issues:
1. Check database tables exist with correct schema
2. Verify RLS policies are enabled
3. Check browser console for Supabase errors
4. Ensure you're logged in with correct user role

See `VOLUNTEER_ASSIGNMENT_FEATURE.md` for detailed documentation.
