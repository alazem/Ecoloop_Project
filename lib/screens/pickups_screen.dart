import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/bottom_nav_bar.dart';

class PickupsScreen extends StatelessWidget {
  const PickupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final activePickups = appState.getActivePickups();
    final completedPickups = appState.getCompletedPickups();
    final isGuest = appState.isGuest;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Pickups',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your collection activities',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isGuest
                  ? _buildGuestView(theme)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Section
                          if (activePickups.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...activePickups.map((listing) => _buildPickupCard(context, listing)),
                            const SizedBox(height: 24),
                          ],
                          // Completed Section
                          if (completedPickups.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...completedPickups.map((listing) => _buildPickupCard(context, listing)),
                          ],
                          if (activePickups.isEmpty && completedPickups.isEmpty)
                            _buildEmptyState(theme),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildGuestView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Login to view your pickups',
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No pickups yet',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Accept a listing to start collecting',
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, Listing listing) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/collection-details', arguments: listing.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image Placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  child: Icon(Icons.image, size: 40, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${listing.weightDisplay} ${listing.materialName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xFF0D9488)),
                            const SizedBox(width: 4),
                            Text(
                              '${listing.estimatedPoints}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.ownerName,
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge(listing.materialName, _getMaterialColor(listing.materialType)),
                        const SizedBox(width: 8),
                        _buildBadge(listing.statusText, _getStatusColor(listing.status)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(listing.area, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(listing.pickupTime, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Color _getMaterialColor(RecyclableMaterial type) {
    switch (type) {
      case RecyclableMaterial.plastic: return const Color(0xFF10B981);
      case RecyclableMaterial.glass: return const Color(0xFF3B82F6);
      case RecyclableMaterial.paper: return const Color(0xFFF59E0B);
      case RecyclableMaterial.metal: return const Color(0xFF6B7280);
      case RecyclableMaterial.ewaste: return const Color(0xFF06B6D4);
    }
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending: return const Color(0xFF10B981);
      case PickupStatus.accepted: return const Color(0xFF3B82F6);
      case PickupStatus.onTheWay: return const Color(0xFF8B5CF6);
      case PickupStatus.arrived: return const Color(0xFFF59E0B);
      case PickupStatus.completed: return const Color(0xFF10B981);
    }
  }
}
