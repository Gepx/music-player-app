/// User Model for Music Player Application
/// Handles user data from Firebase Auth, Google Sign-In, and local SQLite storage
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? jwtToken;
  final String? refreshToken;
  final String? provider; // 'email', 'google', etc.
  final bool isPremium;
  final DateTime? premiumSince;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
    this.lastLoginAt,
    this.jwtToken,
    this.refreshToken,
    this.provider,
    this.isPremium = false,
    this.premiumSince,
  });

  // -------------------- JSON Serialization -------------------- //

  /// Convert UserModel to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'jwtToken': jwtToken,
      'refreshToken': refreshToken,
      'provider': provider,
      'isPremium': isPremium,
      'premiumSince': premiumSince?.toIso8601String(),
    };
  }

  /// Create UserModel from JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      jwtToken: json['jwtToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      provider: json['provider'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumSince: json['premiumSince'] != null
          ? DateTime.tryParse(json['premiumSince'] as String)
          : null,
    );
  }

  // -------------------- SQLite Serialization -------------------- //

  /// Convert UserModel to SQLite Map (for database storage)
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'provider': provider,
      'isPremium': isPremium ? 1 : 0,
      'premiumSince': premiumSince?.millisecondsSinceEpoch,
      // Note: JWT tokens stored separately in secure storage, not SQLite
    };
  }

  /// Create UserModel from SQLite Map
  factory UserModel.fromSQLite(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] as int)
          : null,
      provider: map['provider'] as String?,
      isPremium: (map['isPremium'] as int? ?? 0) == 1,
      premiumSince: map['premiumSince'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['premiumSince'] as int)
          : null,
    );
  }

  // -------------------- Copy With -------------------- //

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? jwtToken,
    String? refreshToken,
    String? provider,
    bool? isPremium,
    DateTime? premiumSince,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      jwtToken: jwtToken ?? this.jwtToken,
      refreshToken: refreshToken ?? this.refreshToken,
      provider: provider ?? this.provider,
      isPremium: isPremium ?? this.isPremium,
      premiumSince: premiumSince ?? this.premiumSince,
    );
  }

  // -------------------- Helper Methods -------------------- //

  /// Check if user is authenticated
  bool get isAuthenticated => jwtToken != null && jwtToken!.isNotEmpty;

  /// Get display name or fallback to email
  String get displayNameOrEmail => displayName ?? email.split('@').first;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, provider: $provider, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.phoneNumber == phoneNumber &&
        other.provider == provider &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      displayName,
      photoUrl,
      phoneNumber,
      provider,
      isPremium,
    );
  }
}

