import 'package:flutter/material.dart';
import '../models/models.dart';

class FilterScreen extends StatefulWidget {
  final List<RecyclableMaterial> selectedMaterials;
  final double distance;
  final RangeValues quantityRange;
  final List<String> selectedTimes;

  const FilterScreen({
    Key? key,
    this.selectedMaterials = const [],
    this.distance = 5.0,
    this.quantityRange = const RangeValues(1, 10),
    this.selectedTimes = const [],
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late List<RecyclableMaterial> _selectedMaterials;
  late double _distance;
  late RangeValues _quantityRange;
  late List<String> _selectedTimes;

  @override
  void initState() {
    super.initState();
    _selectedMaterials = List.from(widget.selectedMaterials);
    _distance = widget.distance;
    _quantityRange = widget.quantityRange;
    _selectedTimes = List.from(widget.selectedTimes);
  }

  void _resetFilters() {
    setState(() {
      _selectedMaterials = [];
      _distance = 5.0;
      _quantityRange = const RangeValues(1, 10);
      _selectedTimes = [];
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'materials': _selectedMaterials,
      'distance': _distance,
      'quantityRange': _quantityRange,
      'times': _selectedTimes,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Filters',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle('Material Type'),
                const SizedBox(height: 12),
                _buildCheckbox('Plastic', RecyclableMaterial.plastic),
                _buildCheckbox('Glass', RecyclableMaterial.glass),
                _buildCheckbox('Paper', RecyclableMaterial.paper),
                _buildCheckbox('Metal', RecyclableMaterial.metal),
                _buildCheckbox('E-waste', RecyclableMaterial.ewaste),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Distance'),
                    Text(
                      'Within ${_distance.toInt()} km',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: theme.colorScheme.onSurface, // Black track in light, White in dark
                    inactiveTrackColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    thumbColor: isDark ? const Color(0xFFE5E7EB) : Colors.white,
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
                    overlayColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    valueIndicatorColor: const Color(0xFF0D9488),
                  ),
                  child: Slider(
                    value: _distance,
                    min: 1,
                    max: 20,
                    onChanged: (value) {
                      setState(() {
                        _distance = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Quantity Range'),
                    Text(
                      '${_quantityRange.start.toInt()}-${_quantityRange.end.toInt()} kg',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: theme.colorScheme.onSurface, // Black/White
                    inactiveTrackColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    thumbColor: isDark ? const Color(0xFFE5E7EB) : Colors.white,
                    trackHeight: 6,
                    rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
                    overlayColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  ),
                  child: RangeSlider(
                    values: _quantityRange,
                    min: 1,
                    max: 50,
                    onChanged: (values) {
                      setState(() {
                        _quantityRange = values;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Pickup Time'),
                const SizedBox(height: 12),
                _buildTimeCheckbox('Morning', 'Morning (8AM - 12PM)'),
                _buildTimeCheckbox('Afternoon', 'Afternoon (12PM - 5PM)'),
                _buildTimeCheckbox('Evening', 'Evening (5PM - 8PM)'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCheckbox(String label, RecyclableMaterial material) {
    final isSelected = _selectedMaterials.contains(material);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedMaterials.remove(material);
            } else {
              _selectedMaterials.add(material);
            }
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)) : theme.cardColor, 
                border: Border.all(
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
               child: isSelected 
                  ? Center(child: Icon(Icons.check, size: 14, color: theme.colorScheme.onSurface)) 
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle( 
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCheckbox(String id, String label) {
    final isSelected = _selectedTimes.contains(id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedTimes.remove(id);
            } else {
              _selectedTimes.add(id);
            }
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
             Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)) : theme.cardColor,
                border: Border.all(
                  color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected 
                  ? Center(child: Icon(Icons.check, size: 14, color: theme.colorScheme.onSurface))
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
