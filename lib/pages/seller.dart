import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Helper widget for cross-platform image display
Widget buildProductImage(String? imageUrl, {double width = 56, double height = 56}) {
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

  // Display image from Supabase URL or local file
  if (imageUrl.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  if (kIsWeb) {
    // On web, show placeholder
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.cloud_upload, color: Colors.blue),
      ),
    );
  }

  // On native platforms, show the actual image
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

// Simple Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    };
  }
} 

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final supabase = Supabase.instance.client;
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final response = await supabase
          .from('products')
          .select()
          .eq('seller_id', userId);

      setState(() {
        products = (response as List)
            .map((item) => Product.fromJson(item))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        onSave: (productData) async {
          try {
            final userId = supabase.auth.currentUser?.id;
            if (userId == null) return;

            final imageUrl = productData['imageUrl'] as String?;

            await supabase.from('products').insert({
              'seller_id': userId,
              'name': productData['name'],
              'description': productData['description'],
              'price': productData['price'],
              'stock': productData['stock'],
              'image_url': imageUrl,
            });

            _loadProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  }

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        product: product,
        onSave: (updatedData) async {
          try {
            final imageUrl = updatedData['imageUrl'] as String?;

            await supabase.from('products').update({
              'name': updatedData['name'],
              'description': updatedData['description'],
              'price': updatedData['price'],
              'stock': updatedData['stock'],
              'image_url': imageUrl,
            }).eq('id', product.id);

            _loadProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete image from storage if exists
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
                  try {
                    final filename = product.imageUrl!.split('/').last;
                    await supabase.storage
                        .from('product_images')
                        .remove(['${product.id}/$filename']);
                  } catch (e) {
                    // Image might not exist, continue
                  }
                }

                // Delete product from database
                await supabase
                    .from('products')
                    .delete()
                    .eq('id', product.id);

                _loadProducts();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewSales() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('sales')
          .select()
          .eq('seller_id', userId);

      // Aggregate sales by product
      final Map<String, Map<String, dynamic>> agg = {};
      for (final sale in response as List) {
        final productId = sale['product_id'];
        final qty = sale['quantity'] as int;
        final total = (sale['total_amount'] as num).toDouble();

        // Find product name
        final product = products.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(id: productId, name: 'Unknown', description: '', price: 0, stock: 0),
        );

        if (!agg.containsKey(productId)) {
          agg[productId] = {
            'name': product.name,
            'quantity': qty,
            'total': total,
            'product': product,
          };
        } else {
          agg[productId]!['quantity'] += qty;
          agg[productId]!['total'] += total;
        }
      }

      final entries = agg.entries.toList();
      entries.sort((a, b) => (b.value['total'] as double).compareTo(a.value['total'] as double));

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sales Report'),
            content: SizedBox(
              width: double.maxFinite,
              child: entries.isEmpty
                  ? const Text('No sales yet')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final product = entry.value['product'] as Product;
                        final qty = entry.value['quantity'];
                        final total = entry.value['total'];

                        return ListTile(
                          leading: buildProductImage(product.imageUrl, width: 48, height: 48),
                          title: Text(product.name),
                          subtitle: Text('Units sold: $qty  •  Revenue: \$$total'),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sales: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProduct,
            tooltip: 'Add Product',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _viewSales,
            tooltip: 'View Sales',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    'No products yet. Tap + to add your first product!',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: buildProductImage(product.imageUrl),
                        title: Text(product.name),
                        subtitle: Text(
                          '${product.description}\nPrice: \$${product.price} | Stock: ${product.stock}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editProduct(product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AddEditProductDialog extends StatefulWidget {
  final Product? product;
  final Function(Map<String, dynamic>) onSave;

  const AddEditProductDialog({super.key, this.product, required this.onSave});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;
  XFile? _pickedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<String?> _uploadImage(String productId) async {
    if (_pickedImage == null) {
      return widget.product?.imageUrl;
    }

    try {
      setState(() => _isUploading = true);

      final file = File(_pickedImage!.path);
      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$productId/$filename';

      await supabase.storage.from('product_images').upload(path, file);

      final imageUrl = supabase.storage.from('product_images').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      try {
        String? imageUrl;
        if (_pickedImage != null) {
          final productId = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
          imageUrl = await _uploadImage(productId);
        } else {
          imageUrl = widget.product?.imageUrl;
        }

        widget.onSave({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'stock': int.parse(_stockController.text),
          'imageUrl': imageUrl,
        });
        Navigator.pop(context);
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                enabled: !_isUploading,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                enabled: !_isUploading,
              ),
              const SizedBox(height: 12),
              // Image picker
              Row(
                children: [
                  _pickedImage != null
                      ? buildProductImage(_pickedImage!.path, width: 72, height: 72)
                      : buildProductImage(widget.product?.imageUrl, width: 72, height: 72),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose Image'),
                    ),
                  ),
                ],
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid price';
                  return null;
                },
                enabled: !_isUploading,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid stock';
                  return null;
                },
                enabled: !_isUploading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _save,
          child: _isUploading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
