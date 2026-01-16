# Architecture & Flow Diagrams

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (seller.dart)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐    ┌──────────────────────────────┐  │
│  │  Seller Dashboard   │    │  Add/Edit Product Dialog     │  │
│  ├─────────────────────┤    ├──────────────────────────────┤  │
│  │ • Product List      │    │ • Form Fields                │  │
│  │ • Thumbnails       │    │ • Image Picker               │  │
│  │ • Edit/Delete      │    │ • Upload to Storage          │  │
│  │ • View Sales       │    │ • Save to Database           │  │
│  └─────────────────────┘    └──────────────────────────────┘  │
│           │                           │                        │
│           └───────────────┬───────────┘                        │
│                           │                                    │
│                    ┌──────▼──────┐                            │
│                    │  Supabase   │                            │
│                    │  Client     │                            │
│                    └──────┬──────┘                            │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
        ┌───────▼────┐  ┌────▼────┐  ┌────▼─────────┐
        │  Database  │  │ Storage │  │ Auth Service │
        └────────────┘  └─────────┘  └──────────────┘
```

---

## 🔄 Data Flow - Add Product

```
User Input
    │
    ▼
┌──────────────────────────┐
│  Fill Product Form       │
│  • Name                  │
│  • Description           │
│  • Price                 │
│  • Stock                 │
│  • Select Image          │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Click "Save"            │
│  Validation Check        │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Upload Image to Storage │
│  • Compress (80% quality)│
│  • Generate filename     │
│  • Get public URL        │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Save to Database        │
│  INSERT INTO products    │
│  • Store image URL       │
│  • Store seller_id       │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│  Refresh Product List    │
│  • Show thumbnail        │
│  • Display product card  │
└──────────────────────────┘
```

---

## 📈 Data Flow - View Sales Report

```
User Input
    │
    ▼
┌──────────────────────────┐
│  Click "📊" Button       │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Fetch Sales Data                │
│  SELECT * FROM sales             │
│  WHERE seller_id = auth.uid()    │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Fetch Product Details           │
│  JOIN products ON product_id     │
│  (Get name, image_url, etc)      │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Aggregate by Product            │
│  • Group sales by product_id     │
│  • Sum units sold                │
│  • Sum revenue                   │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Sort by Revenue (Descending)    │
│  Highest revenue first           │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Display Report Dialog           │
│  • Product Name                  │
│  • Product Thumbnail             │
│  • Units Sold                    │
│  • Total Revenue                 │
└──────────────────────────────────┘
```

---

## 🗄️ Database Schema Diagram

```
┌─────────────────────────────────────────┐
│           PRODUCTS TABLE                │
├─────────────────────────────────────────┤
│ id (UUID) ────────────┐                │
│ seller_id (UUID) ◄────┼──┐             │
│ name (VARCHAR)        │  │             │
│ description (TEXT)    │  │             │
│ price (DECIMAL)       │  │             │
│ stock (INTEGER)       │  │             │
│ image_url (TEXT)      │  │             │
│ created_at (TS)       │  │             │
│ updated_at (TS)       │  │             │
└─────────────────────────────────────────┘
                        │  │
                        │  │
                        │  │
                        │  ▼
┌─────────────────────────────────────────┐
│           SALES TABLE                   │
├─────────────────────────────────────────┤
│ id (UUID)                               │
│ product_id (UUID) ──────────────────────┤ FOREIGN KEY
│ seller_id (UUID) ───────────────────────┤
│ quantity (INTEGER)                      │
│ total_amount (DECIMAL)                  │
│ sale_date (TIMESTAMP)                   │
└─────────────────────────────────────────┘
```

---

## 🔐 Security: Row Level Security (RLS)

```
┌─────────────────────────────────┐
│  Database Access Request        │
│  • User: seller_uuid_123        │
└────────────┬────────────────────┘
             │
             ▼
    ┌────────────────────┐
    │ RLS Policy Check   │
    ├────────────────────┤
    │ seller_id =        │
    │ auth.uid() ?       │
    └────────┬───────────┘
             │
        ┌────┴────┐
        │          │
       YES        NO
        │          │
        ▼          ▼
    ┌──────┐  ┌──────────────┐
    │ ALLOW│  │ DENY ACCESS  │
    └──────┘  │ Permission   │
              │ Denied       │
              └──────────────┘
```

---

## 📱 App Navigation

```
┌─────────────────────────────────────────┐
│          Login/Auth                     │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│          Home Page                      │
│  • Select User Type (Seller/Buyer/etc)  │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│     Seller Dashboard                    │
├─────────────────────────────────────────┤
│  • Product List (with thumbnails)       │
│  • [+] Add Product Button               │
│  • [📊] View Sales Button               │
└────┬─────────────┬─────────────┬────────┘
     │             │             │
     ▼             ▼             ▼
┌─────────────┐ ┌──────────┐ ┌──────────┐
│ Add/Edit    │ │ Delete   │ │ Sales    │
│ Product     │ │ Product  │ │ Report   │
│ Dialog      │ │ Confirm  │ │ Dialog   │
└─────────────┘ └──────────┘ └──────────┘
```

---

## 📸 Image Upload Flow

```
┌─────────────────────────────────┐
│  Pick Image from Gallery        │
│  image_picker package           │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Read File from Device          │
│  File(imagePath)                │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Compress (80% quality)         │
│  Reduce file size               │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Upload to Supabase Storage          │
│  POST /storage/v1/object/upload      │
│  Bucket: product_images              │
│  Path: {product_id}/{timestamp}.jpg  │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Get Public URL                      │
│  https://xxx.supabase.co/storage/... │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Store URL in Database               │
│  UPDATE products SET image_url = ... │
└──────────────────────────────────────┘
```

---

## 🔄 Real-time Updates (Future Enhancement)

```
User 1 Adds Product      User 2 (Seller 2)
         │                      │
         ▼                      ▼
    ┌────────────┐          ┌────────────┐
    │  Updates   │          │  Real-time │
    │  Database  │◄────────►│  Sync      │
    └────────────┘          └────────────┘
         │                      │
         ▼                      ▼
    Product List           Other Seller's
    Updates                   List
    (Seller 1)            (Stays unchanged)
```

---

## 📊 Reporting Query Example

```
Products              Sales
┌──────────┐         ┌──────────┐
│ Rice     │         │ Rice x5  │ ─┐
│ $50      │◄────────┤ $250     │  │
│ img_url1 │         └──────────┘  │
└──────────┘                       │
                                   │
                                   ▼
                          ┌─────────────────┐
                          │ Report Output:  │
                          │ Rice - 5 units  │
                          │ Revenue: $250   │
                          └─────────────────┘
```

---

## 🌐 Cross-Platform Image Handling

```
Web Platform          Native Platform
     │                      │
     ▼                      ▼
┌─────────────┐         ┌────────────┐
│ Image.file()│         │Image.file()│
│ NOT         │         │ ✓ Works    │
│ supported   │         │            │
└──────┬──────┘         └─────┬──────┘
       │                      │
       ▼                      ▼
┌──────────────┐         ┌────────────┐
│ Show         │         │ Show       │
│ Placeholder  │         │ Actual     │
│ Icon         │         │ Image      │
└──────────────┘         └────────────┘
```

---

## 🚀 Deployment Checklist

```
┌─────────────────────────────────────────┐
│ DEV Environment                         │
├─────────────────────────────────────────┤
│ ✓ Local testing                         │
│ ✓ Supabase staging project             │
│ ✓ RLS policies verified                │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ PRODUCTION Environment                  │
├─────────────────────────────────────────┤
│ ✓ Supabase production project          │
│ ✓ Credentials updated in main.dart     │
│ ✓ Storage bucket set to public         │
│ ✓ Backup policies created              │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ LAUNCH                                  │
├─────────────────────────────────────────┤
│ ✓ App released to stores               │
│ ✓ Monitoring & logging setup           │
│ ✓ Support documentation ready          │
└─────────────────────────────────────────┘
```

---

**These diagrams help visualize how all components work together!**
