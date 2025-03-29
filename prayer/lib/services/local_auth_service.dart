import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/local_storage_service.dart';

class LocalAuthService {
  final LocalStorageService _storageService = LocalStorageService();
  final _authStateController = StreamController<AppUser?>.broadcast();
  
  // Auth state stream
  Stream<AppUser?> get authStateChanges => _authStateController.stream;
  
  // Constructor
  LocalAuthService() {
    _initStream();
  }
  
  // Initialize the auth state stream
  Future<void> _initStream() async {
    final currentUser = await _storageService.getCurrentUser();
    _authStateController.add(currentUser);
  }
  
  // Get current user
  Future<AppUser?> getCurrentUser() async {
    return _storageService.getCurrentUser();
  }
  
  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    // In a real app, this would verify credentials against a server
    // Here we're just checking if a user with this email exists
    final user = await _storageService.getUserByEmail(email);
    
    if (user != null) {
      // In a real app, you would check password hash
      // For this demo, we're simplifying by not validating passwords
      
      await _storageService.saveCurrentUser(user);
      _authStateController.add(user);
      return user;
    }
    
    return null;
  }
  
  // Register with email and password
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String displayName) async {
    // Check if user already exists
    final existingUser = await _storageService.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('User with this email already exists');
    }
    
    // Create new user
    final newUser = AppUser(
      id: const Uuid().v4(),
      email: email,
      displayName: displayName,
    );
    
    // Save user
    await _storageService.saveUser(newUser);
    await _storageService.saveCurrentUser(newUser);
    
    _authStateController.add(newUser);
    return newUser;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _storageService.clearCurrentUser();
    _authStateController.add(null);
  }
  
  // Add a friend
  Future<void> addFriend(String userId, String friendId) async {
    final user = await _storageService.getUserById(userId);
    if (user == null) return;
    
    if (!user.friendIds.contains(friendId)) {
      final updatedUser = user.copyWith(
        friendIds: [...user.friendIds, friendId],
      );
      
      await _storageService.saveUser(updatedUser);
      
      // Update current user if it's the same user
      final currentUser = await _storageService.getCurrentUser();
      if (currentUser?.id == userId) {
        await _storageService.saveCurrentUser(updatedUser);
        _authStateController.add(updatedUser);
      }
    }
  }
  
  // Get user's friends
  Future<List<AppUser>> getUserFriends(String userId) async {
    final user = await _storageService.getUserById(userId);
    if (user == null) return [];
    
    final friends = <AppUser>[];
    for (final friendId in user.friendIds) {
      final friend = await _storageService.getUserById(friendId);
      if (friend != null) {
        friends.add(friend);
      }
    }
    
    return friends;
  }
  
  // Clean up
  void dispose() {
    _authStateController.close();
  }
} 