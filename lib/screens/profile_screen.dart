import 'dart:convert';
import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final currentUser = appState.currentUser;
    final isGuest = appState.isGuest;
    final theme = Theme.of(context);

    if (isGuest) {
      return _buildGuestProfile(context);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: appState.isDarkMode 
                      ? const Color(0xFF064E3B) // Darker teal BG for dark mode
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: appState.isDarkMode
                                ? const Color(0xFF065F46)
                                : const Color(0xFFA7F3D0),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: currentUser?.imageBase64 != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.memory(
                                      base64Decode(currentUser!.imageBase64!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Text(
                                        currentUser.initials,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          color: appState.isDarkMode ? Colors.white : const Color(0xFF0D9488),
                                        ),
                                      ),
                                    ),
                                  )
                                : (currentUser?.photoUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.network(
                                          currentUser!.photoUrl!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Text(
                                            currentUser.initials,
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                              color: appState.isDarkMode ? Colors.white : const Color(0xFF0D9488),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        currentUser?.initials ?? 'U',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                          color: appState.isDarkMode ? Colors.white : const Color(0xFF0D9488),
                                        ),
                                      )),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentUser?.name ?? 'User',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: appState.isDarkMode ? Colors.white70 : const Color(0xFF0D9488),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentUser?.email ?? '',
                                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  appState.toggleRole();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Switched to ${currentUser?.role == UserRole.household ? 'Collector' : 'Household'} mode',
                                      ),
                                      backgroundColor: const Color(0xFF0D9488),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    currentUser?.role == UserRole.household ? 'Household' : 'Collector',
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eco Rating', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${currentUser?.ecoRating ?? 0.0}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < (currentUser?.ecoRating ?? 0).floor() ? Icons.star : Icons.star_border,
                                        size: 18,
                                        color: const Color(0xFFFBBF24),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: appState.isDarkMode ? Colors.white24 : const Color(0xFFA7F3D0)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Points', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(
                                  '${currentUser?.totalPoints ?? 0}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'My Listings',
                count: '${currentUser?.listingsCount ?? 0}',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.local_shipping_outlined,
                title: 'My Pickups',
                count: '${currentUser?.pickupsCount ?? 0}',
                onTap: () => Navigator.pushNamed(context, '/pickups'),
              ),
              _buildMenuItem(context, icon: Icons.card_giftcard_outlined, title: 'Rewards History', onTap: () {}),
              _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
              
              const SizedBox(height: 24),
              // Account Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              ),
              const SizedBox(height: 12),
              
              // Dark Mode Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode_outlined, color: Color(0xFF0D9488), size: 22),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text('Dark Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                        ),
                        Switch(
                          value: appState.isDarkMode,
                          onChanged: (value) {
                            appState.toggleTheme();
                          },
                          activeThumbColor: const Color(0xFF0D9488),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              _buildMenuItem(context, icon: Icons.privacy_tip_outlined, title: 'Privacy Settings', onTap: () {}),
              _buildMenuItem(context, icon: Icons.notifications_outlined, title: 'Notification Settings', onTap: () {}),
              const SizedBox(height: 16),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appState.isDarkMode ? Colors.red.withValues(alpha: 0.3) : const Color(0xFFFEE2E2), width: 1.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        appState.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                            SizedBox(width: 8),
                            Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Version
              Center(
                child: Column(
                  children: [
                    Text('EcoLoop v1.0.0', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('Building sustainable communities', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline, size: 80, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 24),
                Text(
                  'Guest Mode',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to access your profile and unlock all features',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.dark_mode_outlined, color: Color(0xFF0D9488), size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Dark Mode', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: appState.isDarkMode,
                      onChanged: (value) {
                        appState.toggleTheme();
                      },
                      activeThumbColor: const Color(0xFF0D9488),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? count,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                   Icon(icon, color: const Color(0xFF0D9488), size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                  ),
                  if (count != null) ...[
                    Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
