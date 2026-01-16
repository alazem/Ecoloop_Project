import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // Firebase Auth
  // Remove direct initialization
  // final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Use a getter to look up the instance only when needed
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Current user
  User? _currentUser;
  bool _isGuest = false;

  // Theme
  bool _isDarkMode = false;

  // Listings
  final List<Listing> _listings = [];

  // Rewards
  final List<Reward> _rewards = [];
  ImpactStats _impactStats = ImpactStats();

  // Getters
  User? get currentUser => _currentUser;
  bool get isGuest => _isGuest;
  bool get isLoggedIn => _currentUser != null || _isGuest;
  bool get isDarkMode => _isDarkMode;
  List<Listing> get listings => List.unmodifiable(_listings);
  List<Reward> get rewards => List.unmodifiable(_rewards);
  ImpactStats get impactStats => _impactStats;

  AppState() {
    _initializeMockData();
    // Wrap auth init in try-catch to allow tests to run without Firebase
    try {
      _initAuth();
    } catch (e) {
      debugPrint(
          'Warning: Firebase Auth initialization failed (expected in tests): $e');
    }
  }

  void _initAuth() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Fetch additional data from Firestore
        String? imageBase64;
        String? phoneNumber;
        
        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists) {
            final data = doc.data();
            imageBase64 = data?['imageBase64'];
            phoneNumber = data?['phoneNumber'];
          }
        } catch (e) {
          debugPrint('Error fetching user data from Firestore: $e');
        }

        // Map Firebase User to App User
        _currentUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          initials:
              (firebaseUser.displayName ?? 'U').substring(0, 1).toUpperCase(),
          role: UserRole.household, // Default role
          ecoRating: 0.0,
          totalPoints: 0,
          listingsCount: 0,
          pickupsCount: 0,
          photoUrl: firebaseUser.photoURL,
          phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
          imageBase64: imageBase64,
        );
        _isGuest = false;
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  void _initializeMockData() {
    // Initialize mock rewards
    _rewards.addAll([
      Reward(
        id: 'r1',
        title: '\$5 Coffee Voucher',
        description: 'Redeem at participating cafes',
        pointsCost: 500,
        iconName: 'coffee',
      ),
      Reward(
        id: 'r2',
        title: '1GB Mobile Data',
        description: 'Added to your mobile',
        pointsCost: 300,
        iconName: 'phone',
      ),
      Reward(
        id: 'r3',
        title: '\$10 Grocery Voucher',
        description: 'Use at local stores',
        pointsCost: 800,
        iconName: 'shopping_cart',
      ),
      Reward(
        id: 'r4',
        title: 'Plant a Tree',
        description: 'We plant a tree in your name',
        pointsCost: 200,
        iconName: 'park',
      ),
    ]);

    // Initialize mock listings
    _listings.addAll([
      Listing(
        id: 'l1',
        materialType: RecyclableMaterial.plastic,
        quantity: 5,
        unit: 'kg',
        location: 'Green Community Center',
        area: 'Downtown',
        pickupTime: '9:00 AM',
        estimatedPoints: 50,
        ownerName: 'John Smith',
        ownerId: 'u2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: PickupStatus.pending,
      ),
      Listing(
        id: 'l2',
        materialType: RecyclableMaterial.paper,
        quantity: 10,
        unit: 'kg',
        location: 'Local School',
        area: 'Westside',
        pickupTime: '10:30 AM',
        estimatedPoints: 75,
        ownerName: 'Mike Williams',
        ownerId: 'u3',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: PickupStatus.accepted,
        collectorId: 'u1',
        collectorName: 'Sarah Johnson',
      ),
      Listing(
        id: 'l3',
        materialType: RecyclableMaterial.glass,
        quantity: 3,
        unit: 'bags',
        location: 'City Park',
        area: 'Eastside',
        pickupTime: '2:00 PM',
        estimatedPoints: 40,
        ownerName: 'Emma Davis',
        ownerId: 'u4',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: PickupStatus.onTheWay,
        collectorId: 'u1',
        collectorName: 'Sarah Johnson',
      ),
      Listing(
        id: 'l4',
        materialType: RecyclableMaterial.metal,
        quantity: 8,
        unit: 'kg',
        location: 'Local Restaurant',
        area: 'Downtown',
        pickupTime: '11:00 AM',
        estimatedPoints: 60,
        ownerName: 'Local Restaurant',
        ownerId: 'u5',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: PickupStatus.completed,
        collectorId: 'u1',
        collectorName: 'Sarah Johnson',
      ),
      Listing(
        id: 'l5',
        materialType: RecyclableMaterial.ewaste,
        quantity: 2,
        unit: 'kg',
        location: 'Tech Office',
        area: 'Business District',
        pickupTime: '3:00 PM',
        estimatedPoints: 30,
        ownerName: 'Tech Corp',
        ownerId: 'u6',
        createdAt: DateTime.now(),
        status: PickupStatus.pending,
      ),
    ]);

    // Initialize impact stats
    _impactStats = ImpactStats(
      recycledKg: 347,
      co2SavedKg: 624,
      pickupsCount: 45,
      treesSaved: 28,
    );
  }

  // Auth methods
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // Handle error, maybe propagate it
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      // Trigger reload to get the display name
      await userCredential.user?.reload();
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
  }

  void continueAsGuest() {
    _currentUser = null;
    _isGuest = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isGuest = false;
    notifyListeners();
  }

  void toggleRole() {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        role: _currentUser!.role == UserRole.household
            ? UserRole.collector
            : UserRole.household,
      );
      notifyListeners();
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
    String? photoUrl,
    String? imageBase64,
  }) async {
    if (_currentUser == null) return;

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user found');
      }

      debugPrint('Updating profile for user: ${firebaseUser.uid}');
      
      // Update Firebase Display Name
      if (name != firebaseUser.displayName) {
        debugPrint('Updating display name to: $name');
        await firebaseUser.updateDisplayName(name);
      }

      // Update Firebase Photo URL (if provided)
      if (photoUrl != null && photoUrl != firebaseUser.photoURL) {
        debugPrint('Updating photo URL');
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      debugPrint('Updating Firestore document');
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'imageBase64': imageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Reload user to get updated info
      await firebaseUser.reload();
      
      // Update local state
      _currentUser = _currentUser!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl ?? firebaseUser.photoURL,
        imageBase64: imageBase64,
        initials: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
      );
      
      notifyListeners();
      debugPrint('Profile update successful');
    } catch (e, stack) {
      debugPrint('Update profile error: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  // Listing methods
  List<Listing> getFilteredListings({
    String? searchQuery,
    List<RecyclableMaterial>? materialResults,
    double? maxDistance,
    RangeValues? quantityRange,
    List<String>? timeFilters,
  }) {
    return _listings.where((listing) {
      // Filter by search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!listing.location.toLowerCase().contains(query) &&
            !listing.area.toLowerCase().contains(query) &&
            !listing.materialName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by material type
      if (materialResults != null && materialResults.isNotEmpty) {
        if (!materialResults.contains(listing.materialType)) {
          return false;
        }
      }

      // Filter by distance (Simulated)
      if (maxDistance != null) {
        // Simulate distance based on listing ID hash
        final simulatedDistance =
            (listing.id.hashCode % 100) / 10.0; // 0.0 - 9.9 km
        if (simulatedDistance > maxDistance) {
          return false;
        }
      }

      // Filter by quantity
      if (quantityRange != null) {
        if (listing.quantity < quantityRange.start ||
            listing.quantity > quantityRange.end) {
          return false;
        }
      }

      // Filter by time
      if (timeFilters != null && timeFilters.isNotEmpty) {
        final timeCategory = _getTimeCategory(listing.pickupTime);
        if (!timeFilters.contains(timeCategory)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _getTimeCategory(String timeStr) {
    // Parse time string like "9:00 AM"
    try {
      final parts = timeStr.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final isPM = parts[1].toUpperCase() == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      if (hour >= 8 && hour < 12) return 'Morning';
      if (hour >= 12 && hour < 17) return 'Afternoon';
      if (hour >= 17 && hour < 20) return 'Evening';
      return 'Night';
    } catch (e) {
      return 'Any'; // Fallback
    }
  }

  List<Listing> getActivePickups() {
    if (_currentUser == null) return [];

    return _listings.where((listing) {
      final isActive = listing.status != PickupStatus.completed &&
          listing.status != PickupStatus.pending;

      if (_currentUser!.role == UserRole.collector) {
        return isActive && listing.collectorId == _currentUser!.id;
      } else {
        return isActive && listing.ownerId == _currentUser!.id;
      }
    }).toList();
  }

  List<Listing> getCompletedPickups() {
    if (_currentUser == null) return [];

    return _listings.where((listing) {
      if (_currentUser!.role == UserRole.collector) {
        return listing.status == PickupStatus.completed &&
            listing.collectorId == _currentUser!.id;
      } else {
        return listing.status == PickupStatus.completed &&
            listing.ownerId == _currentUser!.id;
      }
    }).toList();
  }

  List<Listing> getAvailableListings() {
    return _listings.where((l) => l.status == PickupStatus.pending).toList();
  }

  void addListing(Listing listing) {
    _listings.insert(0, listing);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        listingsCount: _currentUser!.listingsCount + 1,
      );
    }
    notifyListeners();
  }

  Listing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  // Pickup status methods
  void acceptPickup(String listingId) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1 && _currentUser != null) {
      _listings[index].status = PickupStatus.accepted;
      _listings[index].collectorId = _currentUser!.id;
      _listings[index].collectorName = _currentUser!.name;
      notifyListeners();
    }
  }

  void updatePickupStatus(String listingId, PickupStatus newStatus) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final oldStatus = _listings[index].status;
      _listings[index].status = newStatus;

      // Award points when completed
      if (newStatus == PickupStatus.completed &&
          oldStatus != PickupStatus.completed) {
        _awardPoints(_listings[index].estimatedPoints);
        _updateImpactStats(_listings[index]);
      }

      notifyListeners();
    }
  }

  void _awardPoints(int points) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        totalPoints: _currentUser!.totalPoints + points,
        pickupsCount: _currentUser!.pickupsCount + 1,
      );
    }
  }

  void _updateImpactStats(Listing listing) {
    final kg = listing.unit == 'kg'
        ? listing.quantity.toInt()
        : listing.quantity.toInt() * 2;
    _impactStats = _impactStats.copyWith(
      recycledKg: _impactStats.recycledKg + kg,
      co2SavedKg: _impactStats.co2SavedKg + (kg * 2),
      pickupsCount: _impactStats.pickupsCount + 1,
      treesSaved: _impactStats.treesSaved + (kg ~/ 20),
    );
  }

  // Reward methods
  bool redeemReward(String rewardId) {
    final index = _rewards.indexWhere((r) => r.id == rewardId);
    if (index != -1 && _currentUser != null) {
      final reward = _rewards[index];
      if (_currentUser!.totalPoints >= reward.pointsCost &&
          !reward.isRedeemed) {
        _currentUser = _currentUser!.copyWith(
          totalPoints: _currentUser!.totalPoints - reward.pointsCost,
        );
        _rewards[index].isRedeemed = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}

// InheritedWidget for accessing AppState
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    Key? key,
    required AppState state,
    required Widget child,
  }) : super(key: key, notifier: state, child: child);

  static AppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    return provider!.notifier!;
  }

  static AppState? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    return provider?.notifier;
  }

  static AppState read(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<AppStateProvider>();
    return provider!.notifier!;
  }
}
