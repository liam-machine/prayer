import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/providers/prayer_provider.dart';
import 'package:prayer/providers/auth_provider.dart';
import 'package:prayer/screens/prayer_detail_screen.dart';
import 'package:prayer/widgets/prayer_request_card.dart';
import 'package:prayer/screens/add_friend_screen.dart';

class FriendsPrayersScreen extends StatelessWidget {
  const FriendsPrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends\' Prayer Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFriendScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: prayerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prayerProvider.friendsPrayerRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No prayer requests from friends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.appUser?.friendIds.isEmpty ?? true
                            ? 'Add friends to see their prayer requests'
                            : 'Your friends haven\'t created any prayer requests yet',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (authProvider.appUser?.friendIds.isEmpty ?? true)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddFriendScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Friends'),
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prayerProvider.friendsPrayerRequests.length,
                  itemBuilder: (context, index) {
                    final request = prayerProvider.friendsPrayerRequests[index];
                    return PrayerRequestCard(
                      request: request,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrayerDetailScreen(
                              prayerRequest: request,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
 