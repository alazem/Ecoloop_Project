// Data models for EcoLoop app

enum RecyclableMaterial { plastic, glass, paper, metal, ewaste }

enum PickupStatus { pending, accepted, onTheWay, arrived, completed }

enum UserRole { household, collector }

class User {
  final String id;
  final String name;
  final String email;
  final String initials;
  final UserRole role;
  final double ecoRating;
  int totalPoints;
  int listingsCount;
  int pickupsCount;
  final String? photoUrl;
  final String? phoneNumber;
  final String? imageBase64;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.role,
    this.ecoRating = 4.8,
    this.totalPoints = 0,
    this.listingsCount = 0,
    this.pickupsCount = 0,
    this.photoUrl,
    this.phoneNumber,
    this.imageBase64,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? initials,
    UserRole? role,
    double? ecoRating,
    int? totalPoints,
    int? listingsCount,
    int? pickupsCount,
    String? photoUrl,
    String? phoneNumber,
    String? imageBase64,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      role: role ?? this.role,
      ecoRating: ecoRating ?? this.ecoRating,
      totalPoints: totalPoints ?? this.totalPoints,
      listingsCount: listingsCount ?? this.listingsCount,
      pickupsCount: pickupsCount ?? this.pickupsCount,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}

class Listing {
  final String id;
  final RecyclableMaterial materialType;
  final double quantity;
  final String unit;
  final String location;
  final String area;
  final String pickupTime;
  final String notes;
  final int estimatedPoints;
  final String ownerName;
  final String ownerId;
  final DateTime createdAt;
  PickupStatus status;
  String? collectorId;
  String? collectorName;
  final List<String>? imageUrls;

  Listing({
    required this.id,
    required this.materialType,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.area,
    required this.pickupTime,
    this.notes = '',
    required this.estimatedPoints,
    required this.ownerName,
    required this.ownerId,
    required this.createdAt,
    this.status = PickupStatus.pending,
    this.collectorId,
    this.collectorName,
    this.imageUrls,
  });

  List<String> get images => imageUrls ?? const [];

  String get materialName {
    switch (materialType) {
      case RecyclableMaterial.plastic:
        return 'Plastic';
      case RecyclableMaterial.glass:
        return 'Glass';
      case RecyclableMaterial.paper:
        return 'Paper';
      case RecyclableMaterial.metal:
        return 'Metal';
      case RecyclableMaterial.ewaste:
        return 'E-waste';
    }
  }

  String get statusText {
    switch (status) {
      case PickupStatus.pending:
        return 'Available';
      case PickupStatus.accepted:
        return 'Accepted';
      case PickupStatus.onTheWay:
        return 'On the Way';
      case PickupStatus.arrived:
        return 'Arrived';
      case PickupStatus.completed:
        return 'Completed';
    }
  }

  String get weightDisplay => '$quantity $unit';

  static int calculatePoints(RecyclableMaterial type, double quantity) {
    int basePoints;
    switch (type) {
      case RecyclableMaterial.plastic:
        basePoints = 10;
        break;
      case RecyclableMaterial.glass:
        basePoints = 8;
        break;
      case RecyclableMaterial.paper:
        basePoints = 7;
        break;
      case RecyclableMaterial.metal:
        basePoints = 12;
        break;
      case RecyclableMaterial.ewaste:
        basePoints = 15;
        break;
    }
    return (quantity * basePoints).toInt();
  }
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String iconName;
  bool isRedeemed;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.iconName,
    this.isRedeemed = false,
  });
}

class ImpactStats {
  final int recycledKg;
  final int co2SavedKg;
  final int pickupsCount;
  final int treesSaved;

  ImpactStats({
    this.recycledKg = 0,
    this.co2SavedKg = 0,
    this.pickupsCount = 0,
    this.treesSaved = 0,
  });

  ImpactStats copyWith({
    int? recycledKg,
    int? co2SavedKg,
    int? pickupsCount,
    int? treesSaved,
  }) {
    return ImpactStats(
      recycledKg: recycledKg ?? this.recycledKg,
      co2SavedKg: co2SavedKg ?? this.co2SavedKg,
      pickupsCount: pickupsCount ?? this.pickupsCount,
      treesSaved: treesSaved ?? this.treesSaved,
    );
  }
}
