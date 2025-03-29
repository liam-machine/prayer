import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/models/user.dart';
import 'package:prayer/services/local_storage_service.dart';
import 'package:uuid/uuid.dart';

class DemoData {
  static final LocalStorageService _storage = LocalStorageService();
  
  // Demo user ID
  static const String demoUserId = 'demo-user-123';
  
  // Demo friend IDs
  static const String friend1Id = 'friend-user-456';
  static const String friend2Id = 'friend-user-789';
  
  // Generate and save demo data
  static Future<AppUser> generateDemoData() async {
    // Create demo user
    final demoUser = AppUser(
      id: demoUserId,
      email: 'demo@example.com',
      displayName: 'Demo User',
      friendIds: [friend1Id, friend2Id],
    );
    
    // Create demo friends
    final friend1 = AppUser(
      id: friend1Id,
      email: 'john@example.com',
      displayName: 'John Smith',
      friendIds: [demoUserId],
    );
    
    final friend2 = AppUser(
      id: friend2Id,
      email: 'sarah@example.com',
      displayName: 'Sarah Johnson',
      friendIds: [demoUserId],
    );
    
    // Create demo prayer requests for the demo user
    final myRequest1 = PrayerRequest(
      id: 'prayer-demo-1',
      userId: demoUserId,
      title: 'Health concerns',
      description: 'Please pray for my upcoming surgery next week. I\'m feeling anxious about it and would appreciate prayers for healing and peace.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      responses: [
        PrayerResponse(
          userId: friend1Id,
          userName: 'John Smith',
          message: 'Praying for you! God will be with you through this.',
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
        ),
        PrayerResponse(
          userId: friend2Id,
          userName: 'Sarah Johnson',
          message: 'I\'ll be keeping you in my prayers. Let me know if you need anything!',
          createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
        )
      ],
    );
    
    final myRequest2 = PrayerRequest(
      id: 'prayer-demo-2',
      userId: demoUserId,
      title: 'New job opportunity',
      description: 'I have an interview for a job I really want next Monday. Please pray that God\'s will be done and that I can present myself well during the interview.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      responses: [],
    );
    
    // Create demo prayer requests from friends
    final friendRequest1 = PrayerRequest(
      id: 'prayer-friend-1',
      userId: friend1Id,
      title: 'Family reunion',
      description: 'We\'re having a family reunion this weekend after many years apart. Please pray that it goes smoothly and that relationships can be restored.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      responses: [
        PrayerResponse(
          userId: demoUserId,
          userName: 'Demo User',
          message: 'Praying for your family! Hope it\'s a blessed time together.',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 12)),
        )
      ],
    );
    
    final friendRequest2 = PrayerRequest(
      id: 'prayer-friend-2',
      userId: friend2Id,
      title: 'Moving to a new city',
      description: 'I\'m moving to a new city for work next month and feeling nervous about the change. Please pray for a smooth transition and that I find a good church community.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isAnswered: true,
      responses: [
        PrayerResponse(
          userId: demoUserId,
          userName: 'Demo User',
          message: 'Will be praying for you during this transition! God has great things in store.',
          createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        PrayerResponse(
          userId: friend1Id,
          userName: 'John Smith',
          message: 'You\'ll do great! Praying for God\'s guidance.',
          createdAt: DateTime.now().subtract(const Duration(hours: 15)),
        )
      ],
    );
    
    // Save all the data
    await _storage.saveUser(demoUser);
    await _storage.saveUser(friend1);
    await _storage.saveUser(friend2);
    
    await _storage.savePrayerRequest(myRequest1);
    await _storage.savePrayerRequest(myRequest2);
    await _storage.savePrayerRequest(friendRequest1);
    await _storage.savePrayerRequest(friendRequest2);
    
    // Return the demo user
    return demoUser;
  }
  
  // Clear demo data
  static Future<void> clearDemoData() async {
    // Would need to implement functionality to selectively clear data
    // For now, leaving this as a placeholder
  }
} 