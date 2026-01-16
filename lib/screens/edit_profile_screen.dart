import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _imageFile;
  String? _imageBase64;
  bool _isLoading = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final user = AppStateProvider.read(context).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _imageBase64 = user?.imageBase64;
    
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Increased for better quality, compression will handle size
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        
        // Check size (500KB limit)
        if (bytes.lengthInBytes > 500 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image is too large. Please select an image under 500KB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBase64 = base64Encode(bytes);
          _isDirty = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateProvider.read(context);
      
      // In a real app, we would upload the image to Firebase Storage first
      // and get a download URL. For now, we'll just use the local path as a placeholder
      // or keep the existing photoUrl if no new image is selected.
      String? photoUrl = appState.currentUser?.photoUrl;
      if (_imageFile != null) {
        // Placeholder: in a real app, this would be the Firebase Storage URL
        photoUrl = _imageFile!.path; 
      }

      await appState.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        photoUrl: photoUrl,
        imageBase64: _imageBase64,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = appState.currentUser;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Photo
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.file(
                                  _imageFile!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                                : (_imageBase64 != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.memory(
                                          base64Decode(_imageBase64!),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                        ),
                                      )
                                    : (user?.photoUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(60),
                                            child: user!.photoUrl!.startsWith('http') 
                                              ? Image.network(
                                                  user.photoUrl!,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(user.photoUrl!),
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                ),
                                          )
                                        : Text(
                                            user?.initials ?? 'U',
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : const Color(0xFF0D9488),
                                            ),
                                          ))),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D9488),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Name Field
                _buildTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Phone Field
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
                      if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0D9488), size: 22),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
