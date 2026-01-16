import 'dart:io';
import 'package:flutter/material.dart';

class RecyclableCard extends StatelessWidget {
  final String imageUrl;
  final String weight;
  final int points;
  final String location;
  final String area;
  final String time;
  final String materialType;
  final String status;
  final VoidCallback? onTap;

  const RecyclableCard({
    Key? key,
    required this.imageUrl,
    required this.weight,
    required this.points,
    required this.location,
    required this.area,
    required this.time,
    required this.materialType,
    required this.status,
    this.onTap,
  }) : super(key: key);

  Widget _buildImage() {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return const Icon(
      Icons.image,
      size: 60,
      color: Color(0xFF9CA3AF),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFE5E7EB),
                    child: _buildImage(),
                  ),
                ),
                // Material Type Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMaterialColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      materialType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        weight,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 18,
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$points pts',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        area,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMaterialColor() {
    switch (materialType.toLowerCase()) {
      case 'plastic':
        return const Color(0xFF10B981);
      case 'glass':
        return const Color(0xFF3B82F6);
      case 'paper':
        return const Color(0xFFF59E0B);
      case 'metal':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF0D9488);
    }
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF10B981);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'on the way':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
