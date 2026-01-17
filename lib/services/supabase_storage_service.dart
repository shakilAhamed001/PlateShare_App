import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SupabaseStorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final bytes = await image.readAsBytes();

      await _supabase.storage
          .from('donation-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${image.name.split('.').last}',
            ),
          );

      final url = _supabase.storage
          .from('donation-images')
          .getPublicUrl(fileName);
      downloadUrls.add(url);
    }
    return downloadUrls;
  }
}
