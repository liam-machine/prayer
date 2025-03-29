import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/firestore_service.dart';
import 'package:prayer/services/notification_service.dart';

class PrayerProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  
  List<PrayerRequest> _userPrayerRequests = [];
  List<PrayerRequest> _friendsPrayerRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Streams subscription
  StreamSubscription<List<PrayerRequest>>? _userRequestsSubscription;
  StreamSubscription<List<PrayerRequest>>? _friendsRequestsSubscription;

  // Getters
  List<PrayerRequest> get userPrayerRequests => _userPrayerRequests;
  List<PrayerRequest> get friendsPrayerRequests => _friendsPrayerRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Initialize streams for a user
  void initializeForUser(AppUser user) {
    // Cancel existing subscriptions
    _userRequestsSubscription?.cancel();
    _friendsRequestsSubscription?.cancel();
    
    // Listen to user's prayer requests
    _userRequestsSubscription = _firestoreService
        .getPrayerRequestsForUser(user.id)
        .listen(
          _updateUserPrayerRequests,
          onError: _handleError,
        );
    
    // Listen to friends' prayer requests if user has friends
    if (user.friendIds.isNotEmpty) {
      _friendsRequestsSubscription = _firestoreService
          .getFriendsPrayerRequests(user.friendIds)
          .listen(
            _updateFriendsPrayerRequests,
            onError: _handleError,
          );
    } else {
      _friendsPrayerRequests = [];
      notifyListeners();
    }
  }
  
  // Update user prayer requests
  void _updateUserPrayerRequests(List<PrayerRequest> requests) {
    _userPrayerRequests = requests;
    notifyListeners();
  }
  
  // Update friends' prayer requests
  void _updateFriendsPrayerRequests(List<PrayerRequest> requests) {
    _friendsPrayerRequests = requests;
    notifyListeners();
  }
  
  // Handle errors
  void _handleError(error) {
    _errorMessage = error.toString();
    notifyListeners();
  }
  
  // Create new prayer request
  Future<bool> createPrayerRequest(PrayerRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      String requestId = await _firestoreService.createPrayerRequest(request);
      
      // Subscribe to notifications for this request
      await _notificationService.subscribeToPrayerRequest(requestId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Add a prayer response
  Future<bool> addPrayerResponse(
      String requestId, PrayerResponse response) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _firestoreService.addPrayerResponse(requestId, response);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Mark a prayer request as answered
  Future<bool> markPrayerRequestAsAnswered(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _firestoreService.markPrayerRequestAsAnswered(requestId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cleanup subscriptions
  @override
  void dispose() {
    _userRequestsSubscription?.cancel();
    _friendsRequestsSubscription?.cancel();
    super.dispose();
  }
} 