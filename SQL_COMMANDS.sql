-- ============================================
-- PRODUCT MANAGEMENT - SQL COMMANDS
-- ============================================

-- 1. CREATE TABLES
-- Run these first to set up database

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

CREATE TABLE sales (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  sale_date TIMESTAMP DEFAULT NOW()
);

-- 2. ENABLE ROW LEVEL SECURITY (RLS)

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- 3. CREATE RLS POLICIES

-- Products: Sellers can only see their own products
CREATE POLICY "SELECT own products"
  ON products FOR SELECT
  USING (seller_id = auth.uid());

CREATE POLICY "INSERT own products"
  ON products FOR INSERT
  WITH CHECK (seller_id = auth.uid());

CREATE POLICY "UPDATE own products"
  ON products FOR UPDATE
  USING (seller_id = auth.uid());

CREATE POLICY "DELETE own products"
  ON products FOR DELETE
  USING (seller_id = auth.uid());

-- Sales: Sellers can only see their own sales
CREATE POLICY "SELECT own sales"
  ON sales FOR SELECT
  USING (seller_id = auth.uid());

-- 4. COMMON QUERIES

-- Get all products for current seller
SELECT * FROM products 
WHERE seller_id = auth.uid()
ORDER BY created_at DESC;

-- Get single product by ID
SELECT * FROM products 
WHERE id = 'UUID_HERE' AND seller_id = auth.uid();

-- Search products by name
SELECT * FROM products 
WHERE seller_id = auth.uid() 
AND name ILIKE '%SEARCH_TERM%'
ORDER BY name;

-- Get product with low stock
SELECT name, stock, price FROM products
WHERE seller_id = auth.uid() AND stock < 10
ORDER BY stock ASC;

-- 5. SALES QUERIES

-- Get all sales for seller
SELECT s.*, p.name as product_name
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = auth.uid()
ORDER BY s.sale_date DESC;

-- Sales summary by product
SELECT 
  p.id,
  p.name,
  p.image_url,
  COUNT(*) as total_transactions,
  SUM(s.quantity) as total_units_sold,
  SUM(s.total_amount) as total_revenue,
  AVG(s.total_amount) as avg_sale_value
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = auth.uid()
GROUP BY p.id, p.name, p.image_url
ORDER BY total_revenue DESC;

-- Sales by date
SELECT 
  DATE(s.sale_date) as date,
  COUNT(*) as transactions,
  SUM(s.quantity) as units,
  SUM(s.total_amount) as revenue
FROM sales s
WHERE s.seller_id = auth.uid()
GROUP BY DATE(s.sale_date)
ORDER BY date DESC;

-- Top 5 products by revenue
SELECT 
  p.name,
  SUM(s.quantity) as units_sold,
  SUM(s.total_amount) as total_revenue
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = auth.uid()
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5;

-- Monthly sales report
SELECT 
  TO_CHAR(s.sale_date, 'YYYY-MM') as month,
  COUNT(DISTINCT s.product_id) as products_sold,
  SUM(s.quantity) as total_units,
  SUM(s.total_amount) as total_revenue
FROM sales s
WHERE s.seller_id = auth.uid()
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY month DESC;

-- 6. UPDATE/DELETE OPERATIONS

-- Update product details
UPDATE products
SET 
  name = 'New Name',
  description = 'New Description',
  price = 99.99,
  stock = 50,
  updated_at = NOW()
WHERE id = 'PRODUCT_UUID' AND seller_id = auth.uid();

-- Update only image URL
UPDATE products
SET image_url = 'NEW_IMAGE_URL'
WHERE id = 'PRODUCT_UUID' AND seller_id = auth.uid();

-- Update stock after sale
UPDATE products
SET stock = stock - 5
WHERE id = 'PRODUCT_UUID' AND seller_id = auth.uid();

-- Delete a product (will cascade delete related sales records)
DELETE FROM products 
WHERE id = 'PRODUCT_UUID' AND seller_id = auth.uid();

-- 7. INDEXES FOR PERFORMANCE

-- Create indexes for faster queries
CREATE INDEX idx_products_seller_id ON products(seller_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_sales_seller_id ON sales(seller_id);
CREATE INDEX idx_sales_product_id ON sales(product_id);
CREATE INDEX idx_sales_date ON sales(sale_date);

-- 8. TEST DATA (Optional - for development)

-- Insert test product (replace SELLER_UUID)
INSERT INTO products (seller_id, name, description, price, stock)
VALUES 
  ('SELLER_UUID', 'Rice', 'Premium Basmati Rice', 50.00, 100),
  ('SELLER_UUID', 'Wheat Flour', 'Whole Wheat Flour', 30.00, 50);

-- Insert test sale (replace values)
INSERT INTO sales (product_id, seller_id, quantity, total_amount)
VALUES 
  ('PRODUCT_UUID', 'SELLER_UUID', 5, 250.00);

-- 9. ANALYTICS QUERIES

-- Revenue by day of week
SELECT 
  TO_CHAR(s.sale_date, 'Day') as day_of_week,
  COUNT(*) as transactions,
  SUM(s.total_amount) as revenue
FROM sales s
WHERE s.seller_id = auth.uid()
GROUP BY TO_CHAR(s.sale_date, 'Day')
ORDER BY revenue DESC;

-- Product performance (ranked)
SELECT 
  ROW_NUMBER() OVER (ORDER BY SUM(s.total_amount) DESC) as rank,
  p.name,
  SUM(s.quantity) as units,
  SUM(s.total_amount) as revenue,
  COUNT(DISTINCT DATE(s.sale_date)) as days_sold
FROM sales s
JOIN products p ON s.product_id = p.id
WHERE s.seller_id = auth.uid()
GROUP BY p.name;

-- Customer spending pattern (if you have customer tracking)
SELECT 
  COUNT(*) as purchases,
  SUM(s.total_amount) as total_spent,
  AVG(s.total_amount) as avg_purchase
FROM sales s
WHERE s.seller_id = auth.uid();

-- 10. UTILITY COMMANDS

-- View table structure
\d products
\d sales

-- View all data
SELECT * FROM products;
SELECT * FROM sales;

-- Count records
SELECT COUNT(*) FROM products WHERE seller_id = auth.uid();
SELECT COUNT(*) FROM sales WHERE seller_id = auth.uid();

-- Check row level security policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('products', 'sales');
