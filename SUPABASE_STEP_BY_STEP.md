# Step-by-Step Supabase Configuration

## 🎯 Follow These Steps Exactly

---

## Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Click **"New Project"**
3. Fill in:
   - Organization: Create new or select
   - Project name: `PlateShare`
   - Database password: (save this!)
   - Region: Select closest to you
   - Pricing: Free tier is fine
4. Click **"Create new project"**
5. Wait 2-3 minutes for project creation

---

## Step 2: Get Your Credentials

1. In Supabase Dashboard, go to **Settings → API**
2. You'll see:
   - **Project URL** (looks like: `https://xyzabc.supabase.co`)
   - **Anon Key** (long string of characters)
3. Copy both values and save them

**Example:**
```
Project URL: https://abcd1234.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Step 3: Update Flutter Code

In your `lib/main.dart`, add Supabase initialization:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_URL.supabase.co',
    anonKey: 'YOUR_ANON_KEY_HERE',
  );
  
  runApp(const MyApp());
}
```

Replace:
- `YOUR_PROJECT_URL` with your actual Project URL
- `YOUR_ANON_KEY_HERE` with your actual Anon Key

---

## Step 4: Create Database Tables

1. Go to Supabase Dashboard
2. Click **SQL Editor** on the left
3. Click **New query**
4. Paste this code:

```sql
-- Create Products Table
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock INTEGER DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create Sales Table
CREATE TABLE sales (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  sale_date TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
```

5. Click **Run** button (play icon)
6. Wait for completion ✓

---

## Step 5: Create RLS Policies - Part 1

1. Click **New query** again
2. Paste this code:

```sql
-- Products Policies
CREATE POLICY "Sellers can view their own products"
  ON products FOR SELECT
  USING (seller_id = auth.uid());

CREATE POLICY "Sellers can insert their own products"
  ON products FOR INSERT
  WITH CHECK (seller_id = auth.uid());

CREATE POLICY "Sellers can update their own products"
  ON products FOR UPDATE
  USING (seller_id = auth.uid());

CREATE POLICY "Sellers can delete their own products"
  ON products FOR DELETE
  USING (seller_id = auth.uid());
```

3. Click **Run**
4. Wait for completion ✓

---

## Step 6: Create RLS Policies - Part 2

1. Click **New query** again
2. Paste this code:

```sql
-- Sales Policies
CREATE POLICY "Sellers can view their own sales"
  ON sales FOR SELECT
  USING (seller_id = auth.uid());

CREATE POLICY "Sellers can insert their own sales"
  ON sales FOR INSERT
  WITH CHECK (seller_id = auth.uid());
```

3. Click **Run**
4. Wait for completion ✓

---

## Step 7: Create Storage Bucket

1. Go to **Storage** on the left menu
2. Click **Create a new bucket**
3. Fill in:
   - Bucket name: `product_images`
   - **Make Public: ON** (toggle it on!)
4. Click **Create bucket**

---

## Step 8: Verify Database Setup

1. Go to **SQL Editor**
2. Click **New query**
3. Run this to verify:

```sql
-- Check tables exist
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check policies exist
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('products', 'sales');
```

You should see:
- 2 tables: `products` and `sales`
- 6 policies: SELECT, INSERT, UPDATE, DELETE for each

---

## Step 9: Test the App

Now try in your Flutter app:

1. **Run your app:**
   ```bash
   flutter run
   ```

2. **Log in as a seller**

3. **Go to Seller Dashboard**

4. **Click "+" button**

5. **Fill in product details:**
   - Name: "Rice"
   - Description: "Premium Rice"
   - Price: 50
   - Stock: 100
   - Image: Pick any image

6. **Click Save**

7. **Check Supabase:**
   - Go to SQL Editor
   - Run: `SELECT * FROM products;`
   - You should see your product!

8. **Check Storage:**
   - Go to Storage → product_images
   - You should see a folder with your product ID
   - Inside should be your image file

---

## Step 10: Test Sales Report

1. **Add a test sale via SQL:**
   - Go to SQL Editor
   - Run:
   ```sql
   INSERT INTO sales (product_id, seller_id, quantity, total_amount)
   SELECT id, seller_id, 5, (5 * price)
   FROM products 
   LIMIT 1;
   ```

2. **In app, click "📊" button**

3. **You should see:**
   - Product name
   - Product image
   - "Units sold: 5 • Revenue: $250"

---

## 🎉 If Everything Works:

✅ Products show in list with thumbnails
✅ Images upload to Supabase Storage
✅ Products saved in database
✅ Sales report shows aggregated data
✅ Only your data visible (RLS working)

---

## ❌ Troubleshooting

### Products don't appear in list:
```
1. Check you're logged in
2. Run: SELECT * FROM products WHERE seller_id = auth.uid();
3. If empty, check RLS policies executed correctly
```

### Image upload fails:
```
1. Verify bucket name is exactly: product_images
2. Check bucket is PUBLIC (blue toggle)
3. Check image file size < 5MB
```

### "Permission denied" error:
```
1. Make sure you're logged in
2. Check auth.uid() is set
3. Verify RLS policies are created
```

### Can't connect to Supabase:
```
1. Check URL is correct (copy from Settings → API)
2. Check Anon Key is correct
3. Check internet connection
4. Verify Supabase project is active
```

---

## 📋 Checklist

- [ ] Supabase project created
- [ ] Project URL saved
- [ ] Anon Key saved
- [ ] main.dart updated with credentials
- [ ] Tables created (products + sales)
- [ ] RLS enabled on both tables
- [ ] All 6 policies created
- [ ] Storage bucket created (product_images)
- [ ] Bucket set to PUBLIC
- [ ] App runs without errors
- [ ] Can add products
- [ ] Images upload successfully
- [ ] Can view sales report

---

## 🔗 Useful Links

- Supabase Console: https://app.supabase.com
- SQL Editor: https://app.supabase.com/project/{project-id}/sql
- Storage: https://app.supabase.com/project/{project-id}/storage/buckets
- Authentication: https://app.supabase.com/project/{project-id}/auth

---

**Questions? Check PRODUCT_FEATURES_GUIDE.md or SQL_COMMANDS.sql for more info!**
