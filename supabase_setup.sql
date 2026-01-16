-- Create donors table
CREATE TABLE donors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create donations table
CREATE TABLE donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  source TEXT NOT NULL,
  quantity TEXT NOT NULL,
  ngo TEXT NOT NULL,
  image_urls TEXT[] NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'available',
  donor_id UUID REFERENCES donors(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create recipients table
CREATE TABLE recipients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create food_requests table
CREATE TABLE food_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID REFERENCES donations(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES recipients(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending',
  request_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipients ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_requests ENABLE ROW LEVEL SECURITY;

-- Policies for donors
CREATE POLICY "Users can view all donors" ON donors FOR SELECT USING (true);
CREATE POLICY "Users can insert their own donor profile" ON donors FOR INSERT WITH CHECK (auth.uid()::text = id::text);
CREATE POLICY "Users can update their own donor profile" ON donors FOR UPDATE USING (auth.uid()::text = id::text);

-- Policies for donations
CREATE POLICY "Anyone can view available donations" ON donations FOR SELECT USING (status = 'available');
CREATE POLICY "Donors can view their own donations" ON donations FOR SELECT USING (auth.uid()::text = donor_id::text);
CREATE POLICY "Donors can insert their own donations" ON donations FOR INSERT WITH CHECK (auth.uid()::text = donor_id::text);
CREATE POLICY "Donors can update their own donations" ON donations FOR UPDATE USING (auth.uid()::text = donor_id::text);

-- Policies for recipients
CREATE POLICY "Users can view all recipients" ON recipients FOR SELECT USING (true);
CREATE POLICY "Users can insert their own recipient profile" ON recipients FOR INSERT WITH CHECK (auth.uid()::text = id::text);
CREATE POLICY "Users can update their own recipient profile" ON recipients FOR UPDATE USING (auth.uid()::text = id::text);

-- Policies for food_requests
CREATE POLICY "Recipients can view their own requests" ON food_requests FOR SELECT USING (auth.uid()::text = recipient_id::text);
CREATE POLICY "Recipients can insert their own requests" ON food_requests FOR INSERT WITH CHECK (auth.uid()::text = recipient_id::text);
CREATE POLICY "Admins can update request status" ON food_requests FOR UPDATE USING (true); -- Adjust for admin role