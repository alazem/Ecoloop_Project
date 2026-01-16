import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  int _currentStep = 0;
  RecyclableMaterial? _selectedMaterial;
  String _quantityUnit = 'kg';
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String? _quantityError;
  String? _locationError;
  String? _timeError;

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    setState(() {
      _quantityError = null;
      _locationError = null;
      _timeError = null;
    });

    switch (_currentStep) {
      case 0:
        if (_selectedMaterial == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a material type'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        return true;
      case 1:
        if (_selectedImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please upload at least one image'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
          return false;
        }
        return true;
      case 2:
        bool isValid = true;
        if (_quantityController.text.isEmpty) {
          setState(() => _quantityError = 'Quantity is required');
          isValid = false;
        }
        if (_locationController.text.isEmpty) {
          setState(() => _locationError = 'Location is required');
          isValid = false;
        }
        if (_timeController.text.isEmpty) {
          setState(() => _timeError = 'Pickup time is required');
          isValid = false;
        }
        return isValid;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  int _calculateEstimatedPoints() {
    if (_selectedMaterial == null) return 0;
    double quantity = double.tryParse(_quantityController.text) ?? 0;
    return Listing.calculatePoints(_selectedMaterial!, quantity);
  }

  void _publishListing() {
    final appState = AppStateProvider.of(context);
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to publish listings'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final newListing = Listing(
      id: 'l_${DateTime.now().millisecondsSinceEpoch}',
      materialType: _selectedMaterial!,
      quantity: quantity,
      unit: _quantityUnit,
      location: _locationController.text,
      area: 'Downtown',
      pickupTime: _timeController.text,
      notes: _notesController.text,
      estimatedPoints: _calculateEstimatedPoints(),
      ownerName: currentUser.name,
      ownerId: currentUser.id,
      createdAt: DateTime.now(),
      status: PickupStatus.pending,
      imageUrls: _selectedImages.map((image) => image.path).toList(),
    );

    appState.addListing(newListing);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listing published successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isGuest = appState.isGuest;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: _previousStep,
        ),
        title: Text(
          'Add Listing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Guest Warning
          if (isGuest)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.3)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Login to publish listings',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Progress Indicator
          _buildProgressIndicator(theme, isDark),
          // Step Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildStepContent(theme, isDark),
              ),
            ),
          ),
          // Bottom Buttons
          _buildBottomButtons(isGuest, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? const Color(0xFF0D9488)
                    : (isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildMaterialSelection(theme, isDark);
      case 1:
        return _buildImageUpload(theme, isDark);
      case 2:
        return _buildDetailsForm(theme, isDark);
      case 3:
        return _buildReviewAndPublish(theme, isDark);
      default:
        return _buildMaterialSelection(theme, isDark);
    }
  }

  // Step 1: Material Selection
  Widget _buildMaterialSelection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Material Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildMaterialCard(
                Icons.recycling,
                'Plastic',
                const Color(0xFF10B981),
                RecyclableMaterial.plastic,
                theme,
                isDark),
            _buildMaterialCard(
                Icons.local_drink_outlined,
                'Glass',
                const Color(0xFF3B82F6),
                RecyclableMaterial.glass,
                theme,
                isDark),
            _buildMaterialCard(
                Icons.description_outlined,
                'Paper',
                const Color(0xFF8B5CF6),
                RecyclableMaterial.paper,
                theme,
                isDark),
            _buildMaterialCard(
                Icons.coffee_outlined,
                'Metal',
                const Color(0xFFEF4444),
                RecyclableMaterial.metal,
                theme,
                isDark),
            _buildMaterialCard(
                Icons.computer_outlined,
                'E-waste',
                const Color(0xFF06B6D4),
                RecyclableMaterial.ewaste,
                theme,
                isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialCard(IconData icon, String label, Color color,
      RecyclableMaterial type, ThemeData theme, bool isDark) {
    final isSelected = _selectedMaterial == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedMaterial = type),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  // Step 2: Image Upload
  Widget _buildImageUpload(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Images',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 8),
        Text('Add photos of your recyclable materials',
            style: TextStyle(
                fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: List.generate(6, (index) {
            if (index < _selectedImages.length) {
              return _buildUploadedImageCard(index, isDark);
            } else if (index == _selectedImages.length) {
              return _buildAddImageCard(isDark);
            } else {
              return _buildEmptyImageCard(isDark);
            }
          }),
        ),
        const SizedBox(height: 16),
        Text('${_selectedImages.length}/6 images uploaded',
            style: TextStyle(
                fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 6) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Widget _buildAddImageCard(bool isDark) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D9488), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 32, color: Color(0xFF0D9488)),
            SizedBox(height: 4),
            Text('Add',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9488))),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedImageCard(int index, bool isDark) {
    return Container(
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImages[index].path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImages.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImageCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
      ),
    );
  }

  // Step 3: Details Form
  Widget _buildDetailsForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantity',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: _quantityError != null
                      ? Border.all(color: Colors.red)
                      : null,
                ),
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildUnitToggle('kg', theme, isDark),
            const SizedBox(width: 8),
            _buildUnitToggle('bags', theme, isDark),
          ],
        ),
        if (_quantityError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_quantityError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 24),
        Text('Pickup Location',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border:
                _locationError != null ? Border.all(color: Colors.red) : null,
          ),
          child: TextField(
            controller: _locationController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Select location',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
              prefixIcon: Icon(Icons.location_on_outlined,
                  color: theme.colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (_locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_locationError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        const SizedBox(height: 24),
        Text('Pickup Time',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: _timeError != null ? Border.all(color: Colors.red) : null,
          ),
          child: TextField(
            controller: _timeController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'mm/dd/yyyy --:-- --',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
              prefixIcon: Icon(Icons.access_time,
                  color: theme.colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (_timeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_timeError!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildUnitToggle(String unit, ThemeData theme, bool isDark) {
    final isSelected = _quantityUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _quantityUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.cardColor
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0D9488)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // Step 4: Review and Publish
  Widget _buildReviewAndPublish(ThemeData theme, bool isDark) {
    final estimatedPoints = _calculateEstimatedPoints();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Notes (Optional)',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _notesController,
            maxLines: 5,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'e.g., Items are clean and sorted...',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 8),
                  Text('Estimated Reward',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280))),
                ],
              ),
              Text('$estimatedPoints points',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildChecklistItem(
            'Material: ${_selectedMaterial != null ? _getMaterialName(_selectedMaterial!) : 'Not selected'}',
            _selectedMaterial != null,
            theme),
        _buildChecklistItem(
            'Quantity: ${_quantityController.text.isEmpty ? '0' : _quantityController.text} $_quantityUnit',
            _quantityController.text.isNotEmpty,
            theme),
        _buildChecklistItem(
            'Images uploaded', _selectedImages.isNotEmpty, theme),
        _buildChecklistItem(
            'Location & time set',
            _locationController.text.isNotEmpty &&
                _timeController.text.isNotEmpty,
            theme),
      ],
    );
  }

  String _getMaterialName(RecyclableMaterial type) {
    switch (type) {
      case RecyclableMaterial.plastic:
        return 'Plastic';
      case RecyclableMaterial.glass:
        return 'Glass';
      case RecyclableMaterial.paper:
        return 'Paper';
      case RecyclableMaterial.metal:
        return 'Metal';
      case RecyclableMaterial.ewaste:
        return 'E-waste';
    }
  }

  Widget _buildChecklistItem(String text, bool isComplete, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check,
              size: 18,
              color: isComplete
                  ? const Color(0xFF10B981)
                  : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 14,
                  color: isComplete
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isGuest, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                    width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Back',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isGuest && _currentStep == 3
                  ? null
                  : () {
                      if (_currentStep == 3) {
                        _publishListing();
                      } else {
                        _nextStep();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep == 3 ? 'Publish Listing' : 'Next',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
