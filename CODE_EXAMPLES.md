# Code Examples & Snippets

## 🔧 Setup Examples

### Initialize Supabase in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlateShare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
```

---

## 📊 Database Operations

### Get all products for current seller

```dart
Future<List<Product>> getMyProducts() async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) throw Exception('Not logged in');
    
    final response = await supabase
        .from('products')
        .select()
        .eq('seller_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((item) => Product.fromJson(item))
        .toList();
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

### Add a new product

```dart
Future<void> addProduct({
  required String name,
  required String description,
  required double price,
  required int stock,
  required String? imageUrl,
}) async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) throw Exception('Not logged in');
    
    await supabase.from('products').insert({
      'seller_id': userId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    });
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

### Update product

```dart
Future<void> updateProduct({
  required String productId,
  required String name,
  required String description,
  required double price,
  required int stock,
  required String? imageUrl,
}) async {
  try {
    final supabase = Supabase.instance.client;
    
    await supabase.from('products').update({
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', productId);
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

### Delete product

```dart
Future<void> deleteProduct(String productId) async {
  try {
    final supabase = Supabase.instance.client;
    
    await supabase
        .from('products')
        .delete()
        .eq('id', productId);
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

---

## 📸 Image Upload

### Upload image to Storage

```dart
Future<String?> uploadProductImage(
  String productId,
  File imageFile,
) async {
  try {
    final supabase = Supabase.instance.client;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$productId/$filename';
    
    // Upload file
    await supabase.storage.from('product_images').upload(path, imageFile);
    
    // Get public URL
    final imageUrl = 
        supabase.storage.from('product_images').getPublicUrl(path);
    
    return imageUrl;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}
```

### Pick image from gallery

```dart
Future<File?> pickImageFromGallery() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      return File(image.path);
    }
    return null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

---

## 💰 Sales Operations

### Record a sale

```dart
Future<void> recordSale({
  required String productId,
  required int quantity,
  required double totalAmount,
}) async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) throw Exception('Not logged in');
    
    await supabase.from('sales').insert({
      'product_id': productId,
      'seller_id': userId,
      'quantity': quantity,
      'total_amount': totalAmount,
    });
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

### Get sales aggregated by product

```dart
Future<List<SalesReport>> getSalesReport() async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) throw Exception('Not logged in');
    
    final response = await supabase
        .from('sales')
        .select('*, products:product_id(*)')
        .eq('seller_id', userId)
        .order('sale_date', ascending: false);
    
    // Group by product_id
    final Map<String, SalesReport> grouped = {};
    
    for (final sale in response as List) {
      final productId = sale['product_id'];
      final product = sale['products'];
      final quantity = sale['quantity'] as int;
      final totalAmount = (sale['total_amount'] as num).toDouble();
      
      if (!grouped.containsKey(productId)) {
        grouped[productId] = SalesReport(
          productId: productId,
          productName: product['name'],
          productImage: product['image_url'],
          totalUnits: quantity,
          totalRevenue: totalAmount,
        );
      } else {
        grouped[productId]!.totalUnits += quantity;
        grouped[productId]!.totalRevenue += totalAmount;
      }
    }
    
    return grouped.values.toList()
        ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

---

## 🎨 UI Components

### Product image display widget

```dart
Widget buildProductImage(
  String? imageUrl, {
  double width = 56,
  double height = 56,
}) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.photo, color: Colors.grey),
    );
  }

  // Handle HTTP URLs (from Supabase Storage)
  if (imageUrl.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  // Handle local files (during editing)
  if (!kIsWeb) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  // Web fallback
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Icon(Icons.cloud_upload, color: Colors.blue),
  );
}
```

### Product card

```dart
Widget buildProductCard({
  required Product product,
  required Function() onEdit,
  required Function() onDelete,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      leading: buildProductImage(product.imageUrl, width: 56, height: 56),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.description),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price: \$${product.price.toStringAsFixed(2)}'),
              Text('Stock: ${product.stock}'),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text('Edit'),
            onTap: onEdit,
          ),
          PopupMenuItem(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: onDelete,
          ),
        ],
      ),
    ),
  );
}
```

---

## 📈 Analytics Examples

### Top selling products

```dart
Future<List<Map<String, dynamic>>> getTopSellingProducts({
  int limit = 5,
}) async {
  try {
    final supabase = Supabase.instance.client;
    
    final response = await supabase.rpc(
      'get_top_products',
      params: {'user_id': supabase.auth.currentUser!.id, 'limit': limit},
    );
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
```

### Revenue by date range

```dart
Future<double> getRevenueByDateRange({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    final supabase = Supabase.instance.client;
    
    final response = await supabase
        .from('sales')
        .select('total_amount')
        .eq('seller_id', supabase.auth.currentUser!.id)
        .gte('sale_date', startDate.toIso8601String())
        .lte('sale_date', endDate.toIso8601String());
    
    double total = 0;
    for (final sale in response as List) {
      total += (sale['total_amount'] as num).toDouble();
    }
    
    return total;
  } catch (e) {
    print('Error: $e');
    return 0;
  }
}
```

---

## 🔐 Error Handling

### Generic error handler

```dart
void handleSupabaseError(dynamic error) {
  String message = 'An error occurred';
  
  if (error is PostgrestException) {
    message = error.message;
  } else if (error is AuthException) {
    message = 'Authentication error: ${error.message}';
  } else if (error is StorageException) {
    message = 'Storage error: ${error.message}';
  } else {
    message = error.toString();
  }
  
  print('Error: $message');
  
  // Show to user
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(content: Text(message)),
  // );
}
```

---

## 🧪 Testing Examples

### Unit test for product service

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Service', () {
    test('Product.fromJson creates correct instance', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Product',
        'description': 'Test Description',
        'price': 50.0,
        'stock': 100,
        'image_url': 'https://example.com/image.jpg',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.id, 'test-id');
      expect(product.name, 'Test Product');
      expect(product.price, 50.0);
      expect(product.stock, 100);
    });
    
    test('Product.toJson returns correct map', () {
      final product = Product(
        id: 'test-id',
        name: 'Test Product',
        description: 'Test',
        price: 50.0,
        stock: 100,
        imageUrl: 'https://example.com/image.jpg',
      );
      
      final json = product.toJson();
      
      expect(json['name'], 'Test Product');
      expect(json['price'], 50.0);
      expect(json['image_url'], 'https://example.com/image.jpg');
    });
  });
}
```

---

## 📱 Widget Examples

### Loading state

```dart
if (isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Empty state

```dart
if (products.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'No products yet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Text(
          'Tap + to add your first product',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}
```

### Error state

```dart
if (error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text('Error: $error'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Retry logic
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

---

## 🚀 Helper Functions

### Format currency

```dart
String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}
```

### Format date

```dart
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
```

### Check if URL is valid

```dart
bool isValidImageUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  return url.startsWith('http') || url.startsWith('https');
}
```

---

**These code snippets can be copy-pasted into your project!**
