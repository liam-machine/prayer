import 'dart:async';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/services/local_storage_service.dart';

class LocalPrayerService {
  final LocalStorageService _storageService = LocalStorageService();
  
  // Stream controllers for prayer requests
  final _userRequestsController = StreamController<List<PrayerRequest>>.broadcast();
  final _friendsRequestsController = StreamController<List<PrayerRequest>>.broadcast();
  
  // Streams
  Stream<List<PrayerRequest>> get userRequestsStream => _userRequestsController.stream;
  Stream<List<PrayerRequest>> get friendsRequestsStream => _friendsRequestsController.stream;
  
  // Create a prayer request
  Future<String> createPrayerRequest(PrayerRequest request) async {
    await _storageService.savePrayerRequest(request);
    
    // Update user requests stream
    _refreshUserRequests(request.userId);
    
    return request.id;
  }
  
  // Get prayer requests for a user
  Future<List<PrayerRequest>> getPrayerRequestsForUser(String userId) async {
    final requests = await _storageService.getPrayerRequestsForUser(userId);
    
    // Sort by created date, newest first
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Update stream
    _userRequestsController.add(requests);
    
    return requests;
  }
  
  // Get friends' prayer requests
  Future<List<PrayerRequest>> getFriendsPrayerRequests(List<String> friendIds) async {
    final requests = await _storageService.getFriendsPrayerRequests(friendIds);
    
    // Sort by created date, newest first
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Update stream
    _friendsRequestsController.add(requests);
    
    return requests;
  }
  
  // Add a prayer response
  Future<void> addPrayerResponse(String requestId, PrayerResponse response) async {
    await _storageService.addPrayerResponse(requestId, response);
    
    // Refresh streams
    final request = await _storageService.getPrayerRequestById(requestId);
    if (request != null) {
      _refreshUserRequests(request.userId);
      
      // Also refresh friends requests for everyone
      final allRequests = await _storageService.getPrayerRequests();
      final uniqueUserIds = allRequests.map((r) => r.userId).toSet();
      
      for (final userId in uniqueUserIds) {
        final user = await _storageService.getUserById(userId);
        if (user != null) {
          _refreshFriendsRequests(user.friendIds);
        }
      }
    }
  }
  
  // Mark prayer request as answered
  Future<void> markPrayerRequestAsAnswered(String requestId) async {
    await _storageService.markPrayerRequestAsAnswered(requestId);
    
    // Refresh streams
    final request = await _storageService.getPrayerRequestById(requestId);
    if (request != null) {
      _refreshUserRequests(request.userId);
      
      // Also refresh friends requests for everyone
      final allRequests = await _storageService.getPrayerRequests();
      final uniqueUserIds = allRequests.map((r) => r.userId).toSet();
      
      for (final userId in uniqueUserIds) {
        final user = await _storageService.getUserById(userId);
        if (user != null) {
          _refreshFriendsRequests(user.friendIds);
        }
      }
    }
  }
  
  // Subscribe a user to receive updates for a prayer request
  Future<void> subscribeToPrayerRequest(String userId, String requestId) async {
    // In a real app, this would register for notifications
    // Here we're just simulating the functionality
    print('User $userId subscribed to prayer request $requestId');
  }
  
  // Helper to refresh user requests stream
  Future<void> _refreshUserRequests(String userId) async {
    final requests = await _storageService.getPrayerRequestsForUser(userId);
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _userRequestsController.add(requests);
  }
  
  // Helper to refresh friends requests stream
  Future<void> _refreshFriendsRequests(List<String> friendIds) async {
    final requests = await _storageService.getFriendsPrayerRequests(friendIds);
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _friendsRequestsController.add(requests);
  }
  
  // Clean up
  void dispose() {
    _userRequestsController.close();
    _friendsRequestsController.close();
  }
} 