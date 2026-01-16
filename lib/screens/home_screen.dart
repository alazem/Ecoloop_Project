import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/recyclable_card.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  List<RecyclableMaterial> _selectedMaterials = [];
  double _filterDistance = 20.0; // Default max
  RangeValues _filterQuantityRange = const RangeValues(1, 50);
  List<String> _filterTimes = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FilterScreen(
          selectedMaterials: _selectedMaterials,
          distance: _filterDistance,
          quantityRange: _filterQuantityRange,
          selectedTimes: _filterTimes,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _selectedMaterials = result['materials'] ?? [];
        _filterDistance = result['distance'] ?? 20.0;
        _filterQuantityRange =
            result['quantityRange'] ?? const RangeValues(1, 50);
        _filterTimes = result['times'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final listings = appState.getFilteredListings(
      searchQuery: _searchQuery,
      materialResults: _selectedMaterials.isEmpty ? null : _selectedMaterials,
      maxDistance: _filterDistance,
      quantityRange: _filterQuantityRange,
      timeFilters: _filterTimes,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0D9488),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Downtown Area',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          hintText: 'Search recyclables near you',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    GestureDetector(
                      // Tuner icon action
                      onTap: _openFilterScreen,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.tune,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Chips
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(context, 'All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      context, 'Plastic', RecyclableMaterial.plastic),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Glass', RecyclableMaterial.glass),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Paper', RecyclableMaterial.paper),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Metal', RecyclableMaterial.metal),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Recyclable Cards List
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No listings found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],  
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RecyclableCard(
                            imageUrl: listing.images.isNotEmpty
                                ? listing.images.first
                                : 'assets/${listing.materialName.toLowerCase()}.jpg',
                            weight: listing.weightDisplay,
                            points: listing.estimatedPoints,
                            location: listing.location,
                            area: listing.area,
                            time: listing.pickupTime,
                            materialType: listing.materialName,
                            status: listing.statusText,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/collection-details',
                                arguments: listing.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, RecyclableMaterial? type) {
    // Logic: If type is null (All), selected if list is empty.
    // If type is not null, selected if list contains it AND list has only 1 item.
    // This allows chips to work as single-select shortcuts without breaking multi-select logic completely.
    final isSelected = type == null
        ? _selectedMaterials.isEmpty
        : (_selectedMaterials.length == 1 && _selectedMaterials.first == type);

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (type == null) {
            _selectedMaterials = [];
          } else {
            _selectedMaterials = [type];
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:
                isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
