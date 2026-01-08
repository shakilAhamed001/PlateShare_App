import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform, File;
import 'package:flutter_application_2/models/donation_model.dart';
import 'package:flutter_application_2/services/donation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Shared Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color darkGreen = Color(0xFF388E3C);

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String address = '';
  String source = '';
  String quantity = '';
  String ngo = '';
  final List<XFile> _imageFiles = [];

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty && mounted) {
          setState(() {
            _imageFiles.addAll(images);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${images.length} images selected')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No images selected')));
        }
      } else {
        final XFile? image = await picker.pickImage(source: source);
        if (image != null && mounted) {
          setState(() {
            _imageFiles.add(image);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Image captured')));
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image captured')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS))
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Camera not supported on this platform.'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Donation'),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF0F0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryGreen, darkGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Help Feed the Community!\nShare your surplus food with those in need.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Form Fields
                _buildTextField(
                  label: 'Name',
                  icon: Icons.person,
                  onSaved: (value) => name = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => phone = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Food Receive Address',
                  icon: Icons.location_on,
                  onSaved: (value) => address = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Address is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Source of Food',
                  icon: Icons.description,
                  maxLines: 3,
                  onSaved: (value) => source = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Source is required'
                      : null,
                ),
                const SizedBox(height: 16),
                // Upload Image Button
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: _showImageSourceDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt, color: primaryGreen),
                          const SizedBox(width: 12),
                          Text(
                            _imageFiles.isEmpty
                                ? 'Upload Food Image'
                                : '${_imageFiles.length} image(s) selected',
                            style: const TextStyle(
                              fontSize: 16,
                              color: primaryGreen,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: primaryGreen,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Display selected images
                if (_imageFiles.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Images:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _imageFiles.map((file) {
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryGreen),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      !kIsWeb &&
                                          file.path.isNotEmpty &&
                                          File(file.path).existsSync()
                                      ? Image.file(
                                          File(file.path),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                );
                                              },
                                        )
                                      : kIsWeb
                                      ? Image.network(
                                          file.path,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                );
                                              },
                                        )
                                      : const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFiles.remove(file);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Quantity of Food',
                  icon: Icons.scale,
                  onSaved: (value) => quantity = value ?? '',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Quantity is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Preferred Location/NGO (Optional)',
                  icon: Icons.business,
                  onSaved: (value) => ngo = value ?? '',
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Get donor name from prefs
                      final prefs = await SharedPreferences.getInstance();
                      String donorName =
                          prefs.getString('userName') ?? 'Unknown';
                      // Create donation
                      Donation donation = Donation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        phone: phone,
                        address: address,
                        source: source,
                        quantity: quantity,
                        ngo: ngo,
                        imagePaths: _imageFiles
                            .map((file) => file.path)
                            .toList(),
                        donorId: donorName,
                      );
                      DonationService.addDonation(donation);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Donation submitted successfully!'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send),
                      SizedBox(width: 8),
                      Text('Submit Donation', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
