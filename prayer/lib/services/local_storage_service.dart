import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/models/user.dart';

class LocalStorageService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _prayerRequestsKey = 'prayer_requests';
  
  // User methods
  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    final users = await getUsers();
    
    // Update or add the user
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    
    // Save users back to storage
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toMap()).toList()));
  }
  
  Future<List<AppUser>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null) return [];
    
    try {
      final List<dynamic> usersList = jsonDecode(usersJson);
      return usersList.map((json) => AppUser.fromMap(json)).toList();
    } catch (e) {
      print('Error parsing users from storage: $e');
      return [];
    }
  }
  
  Future<AppUser?> getUserById(String userId) async {
    final users = await getUsers();
    return users.cast<AppUser?>().firstWhere(
      (user) => user?.id == userId,
      orElse: () => null,
    );
  }
  
  Future<AppUser?> getUserByEmail(String email) async {
    final users = await getUsers();
    return users.cast<AppUser?>().firstWhere(
      (user) => user?.email.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );
  }
  
  // Current user methods
  Future<void> saveCurrentUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
    await saveUser(user);
  }
  
  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
  
  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) return null;
    
    try {
      return AppUser.fromMap(jsonDecode(userJson));
    } catch (e) {
      print('Error parsing current user from storage: $e');
      return null;
    }
  }
  
  // Prayer request methods
  Future<void> savePrayerRequest(PrayerRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing requests
    final requests = await getPrayerRequests();
    
    // Update or add the request
    final index = requests.indexWhere((r) => r.id == request.id);
    if (index >= 0) {
      requests[index] = request;
    } else {
      requests.add(request);
    }
    
    // Save requests back to storage
    await prefs.setString(_prayerRequestsKey, jsonEncode(requests.map((r) => r.toMap()).toList()));
  }
  
  Future<List<PrayerRequest>> getPrayerRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_prayerRequestsKey);
    
    if (requestsJson == null) return [];
    
    try {
      final List<dynamic> requestsList = jsonDecode(requestsJson);
      return requestsList.map((json) => PrayerRequest.fromMap(json)).toList();
    } catch (e) {
      print('Error parsing prayer requests from storage: $e');
      return [];
    }
  }
  
  Future<List<PrayerRequest>> getPrayerRequestsForUser(String userId) async {
    final requests = await getPrayerRequests();
    return requests.where((request) => request.userId == userId).toList();
  }
  
  Future<List<PrayerRequest>> getFriendsPrayerRequests(List<String> friendIds) async {
    if (friendIds.isEmpty) return [];
    
    final requests = await getPrayerRequests();
    return requests.where((request) => friendIds.contains(request.userId)).toList();
  }
  
  Future<PrayerRequest?> getPrayerRequestById(String requestId) async {
    final requests = await getPrayerRequests();
    return requests.cast<PrayerRequest?>().firstWhere(
      (request) => request?.id == requestId,
      orElse: () => null,
    );
  }
  
  Future<void> addPrayerResponse(String requestId, PrayerResponse response) async {
    final request = await getPrayerRequestById(requestId);
    if (request == null) return;
    
    final updatedResponses = [...request.responses, response];
    final updatedRequest = PrayerRequest(
      id: request.id,
      userId: request.userId,
      title: request.title,
      description: request.description,
      createdAt: request.createdAt,
      isAnswered: request.isAnswered,
      responses: updatedResponses,
    );
    
    await savePrayerRequest(updatedRequest);
  }
  
  Future<void> markPrayerRequestAsAnswered(String requestId) async {
    final request = await getPrayerRequestById(requestId);
    if (request == null) return;
    
    final updatedRequest = PrayerRequest(
      id: request.id,
      userId: request.userId,
      title: request.title,
      description: request.description,
      createdAt: request.createdAt,
      isAnswered: true,
      responses: request.responses,
    );
    
    await savePrayerRequest(updatedRequest);
  }
} 