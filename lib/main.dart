import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Add this import
import 'providers/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pickups_screen.dart';
import 'screens/add_listing_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/collection_details_screen.dart';
import 'screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Add this line
  );
  runApp(const EcoLoopApp());
}

class EcoLoopApp extends StatefulWidget {
  const EcoLoopApp({Key? key}) : super(key: key);

  @override
  State<EcoLoopApp> createState() => _EcoLoopAppState();
}

class _EcoLoopAppState extends State<EcoLoopApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, child) {
          return MaterialApp(
            title: 'EcoLoop',
            debugShowCheckedModeBanner: false,
            themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF0D9488),
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
              cardColor: Colors.white,
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D9488),
                primary: const Color(0xFF0D9488),
                surface: Colors.white,
                onSurface: const Color(0xFF1F2937), // Text color
                onSurfaceVariant: const Color(0xFF6B7280), // Subtitle color
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF0D9488),
              scaffoldBackgroundColor: const Color(0xFF111827), // Dark slate
              cardColor: const Color(0xFF1F2937), // Darker slate for cards
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0D9488),
                brightness: Brightness.dark,
                primary: const Color(0xFF0D9488), // Keep teal
                surface: const Color(0xFF1F2937),
                onSurface: const Color(0xFFF9FAFB), // White-ish text
                onSurfaceVariant:
                    const Color(0xFF9CA3AF), // Lighter gray for subtitles
              ),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => _appState.isLoggedIn
                  ? const HomeScreen()
                  : const OnboardingScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => _appState.isLoggedIn
                  ? const HomeScreen()
                  : const LoginScreen(),
              '/pickups': (context) => _appState.isLoggedIn
                  ? const PickupsScreen()
                  : const LoginScreen(),
              '/add-listing': (context) => _appState.isLoggedIn
                  ? const AddListingScreen()
                  : const LoginScreen(),
              '/rewards': (context) => _appState.isLoggedIn
                  ? const RewardsScreen()
                  : const LoginScreen(),
              '/profile': (context) => _appState.isLoggedIn
                  ? const ProfileScreen()
                  : const LoginScreen(),
              '/edit-profile': (context) => _appState.isLoggedIn
                  ? const EditProfileScreen()
                  : const LoginScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/collection-details') {
                final listingId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) =>
                      CollectionDetailsScreen(listingId: listingId),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
