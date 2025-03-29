import 'package:uuid/uuid.dart';

class PrayerRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isAnswered;
  final List<PrayerResponse> responses;

  PrayerRequest({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    DateTime? createdAt,
    this.isAnswered = false,
    List<PrayerResponse>? responses,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        responses = responses ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isAnswered': isAnswered,
      'responses': responses.map((response) => response.toMap()).toList(),
    };
  }

  factory PrayerRequest.fromMap(Map<String, dynamic> map) {
    return PrayerRequest(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isAnswered: map['isAnswered'] ?? false,
      responses: (map['responses'] as List?)
              ?.map((response) => PrayerResponse.fromMap(response))
              .toList() ??
          [],
    );
  }
}

class PrayerResponse {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  PrayerResponse({
    String? id,
    required this.userId,
    required this.userName,
    required this.message,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrayerResponse.fromMap(Map<String, dynamic> map) {
    return PrayerResponse(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 