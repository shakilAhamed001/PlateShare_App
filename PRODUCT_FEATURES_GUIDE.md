# Product Image & Sales - Quick Reference

## 🎯 What's Implemented

### ✅ Features Added:
1. **Product Image Upload** - Upload to Supabase Storage
2. **Product Thumbnails** - Show in product list & sales report
3. **Sales Aggregation** - Group by product, show units & revenue
4. **Cross-Platform Support** - Works on Android, iOS, Web

---

## 📋 Database Structure

```
PRODUCTS TABLE
├── id (UUID) - Unique product ID
├── seller_id (UUID) - Who owns this product
├── name (String) - Product name
├── description (String) - Product details
├── price (Decimal) - Product price
├── stock (Integer) - Quantity available
├── image_url (String) - URL to image in Storage
├── created_at (Timestamp)
└── updated_at (Timestamp)

SALES TABLE
├── id (UUID) - Unique sale ID
├── product_id (UUID) - Which product was sold
├── seller_id (UUID) - Seller info
├── quantity (Integer) - Units sold
├── total_amount (Decimal) - Money earned
└── sale_date (Timestamp) - When it happened
```

---

## 💾 SQL Commands Cheatsheet

### View all products:
```sql
SELECT * FROM products WHERE seller_id = auth.uid();
```

### View sales summary:
```sql
SELECT p.name, SUM(s.quantity) as units, SUM(s.total_amount) as revenue
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = auth.uid()
GROUP BY p.name
ORDER BY revenue DESC;
```

### Add a sale (from your app or manually):
```sql
INSERT INTO sales (product_id, seller_id, quantity, total_amount)
VALUES ('PRODUCT_UUID', 'SELLER_UUID', 5, 250.00);
```

### Delete a product (with image):
```sql
DELETE FROM products WHERE id = 'PRODUCT_UUID' AND seller_id = auth.uid();
```

### Update product image:
```sql
UPDATE products 
SET image_url = 'https://...' 
WHERE id = 'PRODUCT_UUID';
```

---

## 🔐 Storage Bucket Setup

**Bucket Name:** `product_images`
**Access:** Public (read), Private (write)
**File Path Format:** `{product_id}/{timestamp}.jpg`

Example URL after upload:
```
https://YOUR_PROJECT.supabase.co/storage/v1/object/public/product_images/abc-123/1704744000000.jpg
```

---

## 🚀 App Usage Flow

### Add Product Flow:
```
User Clicks "+" 
  → Dialog Opens
  → Enter Product Details
  → Select Image (optional)
  → Click Save
  → Image Uploads to Storage
  → Product Saved to Database
  → Products List Refreshes
```

### View Sales Flow:
```
User Clicks "📊"
  → App Fetches All Sales
  → Fetches Product Details
  → Groups by Product
  → Shows: Units Sold + Revenue
  → Displays Product Image
```

---

## 🛠️ Code References

### Product Model:
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  // ... methods for JSON conversion
}
```

### Key Methods:
- `_loadProducts()` - Fetch from database
- `_addProduct()` - Create new product
- `_editProduct()` - Update product
- `_deleteProduct()` - Remove product
- `_viewSales()` - Show sales aggregation
- `_uploadImage()` - Upload to Storage
- `_pickImage()` - Select image from gallery

---

## ⚠️ Important Notes

1. **Row Level Security (RLS)** - Sellers only see their own data
2. **Images** - Deleted when product is deleted
3. **Sales** - Manual entry via database or connected to order system
4. **Authentication** - User must be logged in to use features
5. **Storage** - Images are public URLs but database access controlled by RLS

---

## 📞 Common Tasks

### How to add a test sale?
1. Go to Supabase Dashboard
2. SQL Editor → Run:
```sql
INSERT INTO sales (product_id, seller_id, quantity, total_amount)
SELECT id, seller_id, 5, (5 * price)
FROM products 
LIMIT 1;
```

### How to check image uploads?
1. Supabase → Storage → product_images
2. Look for folders matching product IDs
3. Images stored as `{timestamp}.jpg`

### How to query sales by date range?
```sql
SELECT * FROM sales 
WHERE seller_id = auth.uid()
AND sale_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY sale_date DESC;
```

---

## 📈 Performance Tips

1. **Index** product columns for faster queries:
```sql
CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_sales_seller ON sales(seller_id);
CREATE INDEX idx_sales_product ON sales(product_id);
```

2. **Compress** images before upload (80% quality)

3. **Cache** product images in app for offline access

4. **Paginate** sales report if many records exist
