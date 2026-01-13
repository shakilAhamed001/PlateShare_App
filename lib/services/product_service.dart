import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  // Add a sale record when product is purchased
  Future<void> recordSale({
    required String productId,
    required int quantity,
    required double totalAmount,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      await supabase.from('sales').insert({
        'product_id': productId,
        'seller_id': userId,
        'quantity': quantity,
        'total_amount': totalAmount,
      });
    } catch (e) {
      throw Exception('Failed to record sale: $e');
    }
  }

  // Get sales report for seller
  Future<List<Map<String, dynamic>>> getSalesReport() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final response = await supabase
          .from('sales')
          .select()
          .eq('seller_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get sales report: $e');
    }
  }

  // Delete old images from storage when updating product
  Future<void> deleteOldImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      
      final path = Uri.parse(imageUrl).path;
      final filename = path.split('/').last;
      
      await supabase.storage
          .from('product_images')
          .remove([filename]);
    } catch (e) {
      // Silently fail - image might not exist
    }
  }
}
