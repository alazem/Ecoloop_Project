import 'package:flutter/material.dart';

class PickupCard extends StatelessWidget {
  final String imageUrl;
  final String weight;
  final String material;
  final String name;
  final String location;
  final String date;
  final int points;
  final String status;
  final Color statusColor;

  const PickupCard({
    Key? key,
    required this.imageUrl,
    required this.weight,
    required this.material,
    required this.name,
    required this.location,
    required this.date,
    required this.points,
    required this.status,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: const Color(0xFFE5E7EB),
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Color(0xFF9CA3AF),
                ),
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
                        '$weight $material',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$points',
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Material Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getMaterialColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          material,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getMaterialColor(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
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
    switch (material.toLowerCase()) {
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
}
