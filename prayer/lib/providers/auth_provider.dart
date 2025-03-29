import 'package:flutter/material.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/local_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService();
  
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _appUser != null;

  // Listen to auth state changes
  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
    _initCurrentUser();
  }

  // Initialize with current user if any
  Future<void> _initCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _appUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Public method to reload the current user (for demo purposes)
  Future<void> reloadCurrentUser() async {
    await _initCurrentUser();
  }

  // Handle auth state changes
  void _onAuthStateChanged(AppUser? user) {
    _appUser = user;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _authService.registerWithEmailAndPassword(
        email, 
        password,
        displayName,
      );
      
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a friend
  Future<void> addFriend(String friendId) async {
    if (_appUser == null) return;
    
    try {
      await _authService.addFriend(_appUser!.id, friendId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get user's friends
  Future<List<AppUser>> getUserFriends() async {
    if (_appUser == null) return [];
    
    try {
      return await _authService.getUserFriends(_appUser!.id);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
  
  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
} 