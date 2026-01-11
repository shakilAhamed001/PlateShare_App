import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Helper widget for cross-platform image display
Widget buildProductImage(String? imagePath, {double width = 56, double height = 56}) {
  if (imagePath == null || imagePath.isEmpty) {
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

  if (kIsWeb) {
    // On web, show placeholder since web can't use Image.file()
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
      File(imagePath),
      width: width,
      height: height,
      fit: BoxFit.cover,
    ),
  );
}

// Simple Product Model
class Product {
  String id;
  String name;
  String description;
  double price;
  int stock;
  String? imagePath; // optional local path or URL

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imagePath,
  });
} 

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  List<Product> products = [
    Product(
      id: '1',
      name: 'Rice',
      description: 'Premium quality rice',
      price: 50.0,
      stock: 100,
    ),
    Product(
      id: '2',
      name: 'Wheat Flour',
      description: 'Whole wheat flour',
      price: 30.0,
      stock: 50,
    ),
  ];

  List<Map<String, dynamic>> sales = [
    {'product': 'Rice', 'quantity': 10, 'total': 500.0, 'date': '2024-01-01'},
    {
      'product': 'Wheat Flour',
      'quantity': 5,
      'total': 150.0,
      'date': '2024-01-02',
    },
  ];

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        onSave: (product) {
          setState(() {
            products.add(
              Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: product['name'],
                description: product['description'],
                price: product['price'],
                stock: product['stock'],
                imagePath: product['imagePath'],
              ),
            );
          });
        },
      ),
    );
  }

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        product: product,
        onSave: (updatedProduct) {
          setState(() {
            product.name = updatedProduct['name'];
            product.description = updatedProduct['description'];
            product.price = updatedProduct['price'];
            product.stock = updatedProduct['stock'];
            product.imagePath = updatedProduct['imagePath'];
          });
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
            onPressed: () {
              setState(() {
                products.remove(product);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewSales() {
    // Aggregate sales by product
    final Map<String, Map<String, dynamic>> agg = {};
    for (final sale in sales) {
      final name = sale['product'] as String;
      final qty = sale['quantity'] as int;
      final total = (sale['total'] as num).toDouble();
      if (!agg.containsKey(name)) {
        agg[name] = {
          'quantity': qty,
          'total': total,
        };
      } else {
        agg[name]!['quantity'] += qty;
        agg[name]!['total'] += total;
      }
    }

    final entries = agg.entries.toList();
    entries.sort((a, b) => (b.value['total'] as double).compareTo(a.value['total'] as double));

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
                    final pname = entry.key;
                    final qty = entry.value['quantity'];
                    final total = entry.value['total'];
                    // find product image if available
                    final prod = products.firstWhere(
                      (p) => p.name == pname,
                      orElse: () => Product(id: '', name: pname, description: '', price: 0, stock: 0),
                    );

                    return ListTile(
                      leading: buildProductImage(prod.imagePath, width: 48, height: 48),
                      title: Text(pname),
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
      body: products.isEmpty
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
                    leading: buildProductImage(product.imagePath),
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
  XFile? _pickedImage;

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
    if (widget.product?.imagePath != null) {
      _pickedImage = XFile(widget.product!.imagePath!);
    }
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

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'imagePath': _pickedImage?.path ?? widget.product?.imagePath,
      });
      Navigator.pop(context);
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
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // Image picker
              Row(
                children: [
                  buildProductImage(_pickedImage?.path, width: 72, height: 72),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose Image'),
                    ),
                  ),
                ],
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
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
