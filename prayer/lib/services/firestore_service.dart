import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Collection Reference
  CollectionReference get usersCollection => _firestore.collection('users');
  
  // Prayer Requests Collection Reference
  CollectionReference get prayerRequestsCollection => 
      _firestore.collection('prayer_requests');

  // Create User
  Future<void> createUser(AppUser user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  // Get User
  Future<AppUser?> getUser(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Update User
  Future<void> updateUser(AppUser user) async {
    await usersCollection.doc(user.id).update(user.toMap());
  }

  // Add a friend
  Future<void> addFriend(String userId, String friendId) async {
    await usersCollection.doc(userId).update({
      'friendIds': FieldValue.arrayUnion([friendId]),
    });
  }

  // Get user's friends
  Future<List<AppUser>> getUserFriends(String userId) async {
    final userDoc = await usersCollection.doc(userId).get();
    final user = AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
    
    List<AppUser> friends = [];
    for (String friendId in user.friendIds) {
      final friendDoc = await usersCollection.doc(friendId).get();
      if (friendDoc.exists && friendDoc.data() != null) {
        friends.add(AppUser.fromMap(friendDoc.data() as Map<String, dynamic>));
      }
    }
    
    return friends;
  }

  // Create prayer request
  Future<String> createPrayerRequest(PrayerRequest request) async {
    final docRef = await prayerRequestsCollection.add(request.toMap());
    await prayerRequestsCollection.doc(docRef.id).update({'id': docRef.id});
    return docRef.id;
  }

  // Get prayer requests for a user
  Stream<List<PrayerRequest>> getPrayerRequestsForUser(String userId) {
    return prayerRequestsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrayerRequest.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get friend's prayer requests
  Stream<List<PrayerRequest>> getFriendsPrayerRequests(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }
    
    return prayerRequestsCollection
        .where('userId', whereIn: friendIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PrayerRequest.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Add prayer response
  Future<void> addPrayerResponse(String requestId, PrayerResponse response) async {
    await prayerRequestsCollection.doc(requestId).update({
      'responses': FieldValue.arrayUnion([response.toMap()]),
    });
  }

  // Mark prayer request as answered
  Future<void> markPrayerRequestAsAnswered(String requestId) async {
    await prayerRequestsCollection.doc(requestId).update({
      'isAnswered': true,
    });
  }
} 