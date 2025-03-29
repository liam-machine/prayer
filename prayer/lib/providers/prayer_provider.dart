import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/local_prayer_service.dart';

class PrayerProvider with ChangeNotifier {
  final LocalPrayerService _prayerService = LocalPrayerService();
  
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
    _userRequestsSubscription = _prayerService
        .userRequestsStream
        .listen(
          _updateUserPrayerRequests,
          onError: _handleError,
        );
    
    // Listen to friends' prayer requests if user has friends
    _friendsRequestsSubscription = _prayerService
        .friendsRequestsStream
        .listen(
          _updateFriendsPrayerRequests,
          onError: _handleError,
        );
    
    // Load initial data
    _loadInitialData(user);
  }
  
  // Load initial data
  Future<void> _loadInitialData(AppUser user) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _prayerService.getPrayerRequestsForUser(user.id);
      
      if (user.friendIds.isNotEmpty) {
        await _prayerService.getFriendsPrayerRequests(user.friendIds);
      } else {
        _friendsPrayerRequests = [];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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
  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    notifyListeners();
  }
  
  // Create new prayer request
  Future<bool> createPrayerRequest(PrayerRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _prayerService.createPrayerRequest(request);
      
      // Subscribe to notifications for this request
      await _prayerService.subscribeToPrayerRequest(request.userId, request.id);
      
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
      await _prayerService.addPrayerResponse(requestId, response);
      
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
      await _prayerService.markPrayerRequestAsAnswered(requestId);
      
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
    _prayerService.dispose();
    super.dispose();
  }
} 