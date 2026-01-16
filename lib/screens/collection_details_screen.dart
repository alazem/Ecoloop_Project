import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final String listingId;

  const CollectionDetailsScreen({Key? key, required this.listingId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    Listing? listing;
    try {
      listing = appState.listings.firstWhere((l) => l.id == listingId);
    } catch (_) {}

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Listing not found')),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = appState.currentUser;
    final isGuest = appState.isGuest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildListingImage(listing, isDark, theme),
                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getMaterialColor(listing.materialType),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            listing.materialName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${listing.weightDisplay} Available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF0D9488),
                        child: Text(
                          listing.ownerName.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.ownerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (24)',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.message_outlined),
                        color: const Color(0xFF0D9488),
                        onPressed: () {}, // TODO: Implement chat
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_outlined),
                        color: const Color(0xFF0D9488),
                        onPressed: () {}, // TODO: Implement call
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Details Grid
                  Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          Icons.location_on_outlined,
                          'Location',
                          listing.area,
                          theme,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          Icons.calendar_today_outlined,
                          'Pickup Date',
                          listing.pickupTime.split(' ')[0],
                          theme,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.person_outline, 'Listed by',
                      listing.ownerName, theme),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, 'Location',
                      listing.location, theme),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                      Icons.place_outlined, 'Area', listing.area, theme),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Pickup Time',
                      listing.pickupTime, theme),
                  if (listing.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.notes, 'Notes', listing.notes, theme),
                  ],
                  if (listing.collectorName != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.local_shipping_outlined, 'Collector',
                        listing.collectorName!, theme),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                            : const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Estimated Reward',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${listing.estimatedPoints} Points',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Map Preview
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Map Preview',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: 32),
                  // Action Button
                  if (!isGuest && currentUser != null)
                    _buildActionButtons(
                        context, appState, listing, currentUser, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String label, String value, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState appState,
      Listing listing, User user, bool isDark) {
    final isCollector = user.role == UserRole.collector;
    final isOwner = listing.ownerId == user.id;
    final isAssignedCollector = listing.collectorId == user.id;

    return Column(
      children: [
        if (isCollector && listing.status == PickupStatus.pending)
          _buildActionButton(
            'Accept Pickup',
            const Color(0xFF0D9488),
            () {
              appState.acceptPickup(listing.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup accepted!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
          ),
        if (isCollector &&
            isAssignedCollector &&
            listing.status == PickupStatus.accepted)
          _buildActionButton(
            'On My Way',
            const Color(0xFF3B82F6),
            () {
              appState.updatePickupStatus(listing.id, PickupStatus.onTheWay);
            },
          ),
        if (isCollector &&
            isAssignedCollector &&
            listing.status == PickupStatus.onTheWay)
          _buildActionButton(
            'Arrived',
            const Color(0xFF8B5CF6),
            () {
              appState.updatePickupStatus(listing.id, PickupStatus.arrived);
            },
          ),
        if (isOwner && listing.status == PickupStatus.arrived)
          _buildActionButton(
            'Confirm Pickup',
            const Color(0xFF10B981),
            () {
              appState.updatePickupStatus(listing.id, PickupStatus.completed);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Pickup completed! +${listing.estimatedPoints} points earned'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
              Navigator.pop(context);
            },
          ),
        if (listing.status == PickupStatus.completed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Pickup Completed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildListingImage(Listing listing, bool isDark, ThemeData theme) {
    if (listing.images.isNotEmpty) {
      final imageUrl = listing.images.first;
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(isDark, theme),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(isDark, theme),
        );
      } else {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(isDark, theme),
        );
      }
    }

    // Fallback to stock image
    return Image.asset(
      'assets/${listing.materialName.toLowerCase()}.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(isDark, theme),
    );
  }

  Widget _buildPlaceholder(bool isDark, ThemeData theme) {
    return Container(
      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.image,
          size: 80,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Color _getMaterialColor(RecyclableMaterial type) {
    switch (type) {
      case RecyclableMaterial.plastic:
        return const Color(0xFF10B981);
      case RecyclableMaterial.glass:
        return const Color(0xFF3B82F6);
      case RecyclableMaterial.paper:
        return const Color(0xFFF59E0B);
      case RecyclableMaterial.metal:
        return const Color(0xFF6B7280);
      case RecyclableMaterial.ewaste:
        return const Color(0xFF06B6D4);
    }
  }
}
