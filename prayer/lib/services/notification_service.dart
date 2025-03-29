import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialize notifications
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();
    
    // Get FCM token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveDeviceToken(token);
      print('FCM Token: $token');
    }
    
    // Configure notification handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check for initial message (app opened from notification)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }
  
  // Request notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('User notification permission status: ${settings.authorizationStatus}');
  }
  
  // Save device token to SharedPreferences for now
  // In a real app, this would be saved to the user's profile in Firestore
  Future<void> _saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    
    // Here we would show a local notification, but for simplicity we're just printing
  }
  
  // Handle clicked notifications when app is in background
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked when app was in background: ${message.data}');
    
    // Navigate to relevant screen based on payload
  }
  
  // Handle initial message (app opened from terminated state)
  void _handleInitialMessage(RemoteMessage message) {
    print('App opened from terminated state by notification: ${message.data}');
    
    // Navigate to relevant screen based on payload
  }
  
  // Subscribe to topic for a prayer request
  Future<void> subscribeToPrayerRequest(String requestId) async {
    await _messaging.subscribeToTopic('prayer_request_$requestId');
  }
  
  // Unsubscribe from a prayer request
  Future<void> unsubscribeFromPrayerRequest(String requestId) async {
    await _messaging.unsubscribeFromTopic('prayer_request_$requestId');
  }
} 