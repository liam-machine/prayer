class AppUser {
  final String id;
  final String email;
  final String displayName;
  final List<String> friendIds;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    List<String>? friendIds,
    DateTime? createdAt,
  })  : friendIds = friendIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'friendIds': friendIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      friendIds: List<String>.from(map['friendIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    List<String>? friendIds,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 