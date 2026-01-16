import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/bottom_nav_bar.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final currentUser = appState.currentUser;
    final impactStats = appState.impactStats;
    final rewards = appState.rewards;
    final isGuest = appState.isGuest;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalPoints = currentUser?.totalPoints ?? 0;
    const nextTierPoints = 2000;
    final progress = (totalPoints / nextTierPoints).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F766E), const Color(0xFF114352)]
                        : [const Color(0xFF0D9488), const Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.star, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isGuest ? '0' : '$totalPoints',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Points',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress to Gold Tier',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                            Text('$totalPoints / $nextTierPoints',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Impact Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Your Impact',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.recycling,
                        value: '${impactStats.recycledKg} kg',
                        label: 'Recycled',
                        color: isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF10B981),
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.eco_outlined,
                        value: '${impactStats.co2SavedKg} kg',
                        label: 'CO₂ Saved',
                        color: isDark
                            ? const Color(0xFF1D4ED8).withValues(alpha: 0.3)
                            : const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF3B82F6),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.local_shipping_outlined,
                        value: '${impactStats.pickupsCount}',
                        label: 'Pickups',
                        color: isDark
                            ? const Color(0xFF92400E).withValues(alpha: 0.3)
                            : const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFF59E0B),
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImpactCard(
                        icon: Icons.park_outlined,
                        value: '${impactStats.treesSaved}',
                        label: 'Trees Saved',
                        color: isDark
                            ? const Color(0xFF064E3B)
                            : const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF10B981),
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Redeem Rewards Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Redeem Rewards',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 16),
              ...rewards.map((reward) => _buildRewardCard(
                    context,
                    appState,
                    reward,
                    totalPoints,
                    isGuest,
                    theme,
                    isDark,
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildImpactCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: iconColor)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    BuildContext context,
    AppState appState,
    dynamic reward,
    int totalPoints,
    bool isGuest,
    ThemeData theme,
    bool isDark,
  ) {
    final canRedeem =
        !isGuest && totalPoints >= reward.pointsCost && !reward.isRedeemed;

    IconData iconData;
    switch (reward.iconName) {
      case 'coffee':
        iconData = Icons.coffee;
        break;
      case 'phone':
        iconData = Icons.phone_android;
        break;
      case 'shopping_cart':
        iconData = Icons.shopping_cart;
        break;
      case 'park':
        iconData = Icons.park;
        break;
      default:
        iconData = Icons.card_giftcard;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData,
                  size: 28, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reward.pointsCost} points',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D9488)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            reward.isRedeemed
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                          : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Redeemed',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981)),
                    ),
                  )
                : ElevatedButton(
                    onPressed: canRedeem
                        ? () {
                            final success = appState.redeemReward(reward.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${reward.title} redeemed!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Redeem',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
