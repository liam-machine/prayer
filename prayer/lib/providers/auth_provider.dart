import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/auth_service.dart';
import 'package:prayer/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
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
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _appUser = null;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _appUser = await _firestoreService.getUser(firebaseUser.uid);
      
      // Create user if not found in Firestore
      if (_appUser == null) {
        _appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
        );
        await _firestoreService.createUser(_appUser!);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
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
      User? user = await _authService.registerWithEmailAndPassword(
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
      _appUser = null;
      notifyListeners();
    }
  }

  // Add a friend
  Future<void> addFriend(String friendId) async {
    if (_appUser == null) return;
    
    try {
      await _firestoreService.addFriend(_appUser!.id, friendId);
      
      // Update local user
      _appUser = _appUser!.copyWith(
        friendIds: [..._appUser!.friendIds, friendId],
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Get user's friends
  Future<List<AppUser>> getUserFriends() async {
    if (_appUser == null) return [];
    
    try {
      return await _firestoreService.getUserFriends(_appUser!.id);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }
} 