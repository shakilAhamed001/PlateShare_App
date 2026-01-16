# Supabase Setup Guide - Product Management System

## 📱 Step 1: Supabase Project Setup

1. Go to [supabase.com](https://supabase.com) and create a project
2. Get your **Project URL** and **Anon Key** from Project Settings → API
3. In your Flutter app `main.dart`, initialize Supabase:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_PROJECT_URL',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

---

## 🗄️ Step 2: Create Database Tables

Go to **Supabase Dashboard → SQL Editor** and run these commands:

### Create Products Table
```sql
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
```

### Create Sales Table
```sql
CREATE TABLE sales (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  sale_date TIMESTAMP DEFAULT NOW()
);
```

### Enable Row Level Security (RLS)
```sql
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
```

### Create RLS Policies
```sql
-- Sellers can view their own products
CREATE POLICY "Sellers can view their own products"
  ON products FOR SELECT
  USING (seller_id = auth.uid());

-- Sellers can insert their own products
CREATE POLICY "Sellers can insert their own products"
  ON products FOR INSERT
  WITH CHECK (seller_id = auth.uid());

-- Sellers can update their own products
CREATE POLICY "Sellers can update their own products"
  ON products FOR UPDATE
  USING (seller_id = auth.uid());

-- Sellers can delete their own products
CREATE POLICY "Sellers can delete their own products"
  ON products FOR DELETE
  USING (seller_id = auth.uid());

-- Sellers can view their own sales
CREATE POLICY "Sellers can view their own sales"
  ON sales FOR SELECT
  USING (seller_id = auth.uid());
```

---

## 📁 Step 3: Setup Storage for Images

1. Go to **Supabase Dashboard → Storage**
2. Create a new bucket named **product_images**
3. Set bucket policy to **Public** (anyone can view)
4. Go to **Storage → Policies** and add this policy:

```sql
CREATE POLICY "Users can upload their own product images"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'product_images' AND auth.uid() = owner);
```

---

## 🔐 Step 4: Authentication Setup

Make sure your app has authentication working. Users must be logged in before they can:
- Add/edit products
- View sales reports

---

## 💾 Step 5: Database Schema Summary

### Products Table Columns:
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Product ID (auto-generated) |
| seller_id | UUID | ID of seller who created product |
| name | VARCHAR | Product name |
| description | TEXT | Product description |
| price | DECIMAL | Product price |
| stock | INTEGER | Quantity in stock |
| image_url | TEXT | URL to product image in Storage |
| created_at | TIMESTAMP | When product was created |
| updated_at | TIMESTAMP | Last update time |

### Sales Table Columns:
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Sale ID (auto-generated) |
| product_id | UUID | Foreign key to products |
| seller_id | UUID | ID of seller |
| quantity | INTEGER | Units sold |
| total_amount | DECIMAL | Total sale amount |
| sale_date | TIMESTAMP | When sale occurred |

---

## 🚀 Step 6: Test the App

1. Log in as a seller
2. Go to Seller Dashboard
3. Click **+** to add a product
4. Fill details and upload an image
5. Image automatically uploads to `product_images` bucket
6. Product is saved to `products` table
7. View Sales shows aggregated sales by product

---

## 📊 SQL Queries for Analytics

### Get all products for a seller:
```sql
SELECT * FROM products 
WHERE seller_id = 'USER_ID'
ORDER BY created_at DESC;
```

### Get sales summary:
```sql
SELECT 
  p.name,
  COUNT(*) as total_sales,
  SUM(s.quantity) as total_units_sold,
  SUM(s.total_amount) as total_revenue
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = 'USER_ID'
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;
```

### Get sales by date:
```sql
SELECT 
  DATE(s.sale_date) as sale_date,
  SUM(s.total_amount) as daily_revenue,
  COUNT(*) as transactions
FROM sales s
WHERE s.seller_id = 'USER_ID'
GROUP BY DATE(s.sale_date)
ORDER BY sale_date DESC;
```

---

## 🔧 Troubleshooting

**Q: Upload fails - "bucket not found"**
A: Make sure bucket name is exactly `product_images` (lowercase, no spaces)

**Q: Can't see products**
A: Check RLS policies are set correctly and seller_id matches auth.uid()

**Q: Image doesn't display**
A: Check bucket is Public, and image_url is correctly stored

**Q: Permission denied error**
A: Make sure user is authenticated before making database operations
