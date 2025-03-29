import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/providers/prayer_provider.dart';
import 'package:prayer/screens/prayer_detail_screen.dart';
import 'package:prayer/widgets/prayer_request_card.dart';
import 'package:intl/intl.dart';

class MyPrayersScreen extends StatelessWidget {
  const MyPrayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prayer Requests'),
      ),
      body: prayerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prayerProvider.userPrayerRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No prayer requests yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to create one',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_prayer');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Prayer Request'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prayerProvider.userPrayerRequests.length,
                  itemBuilder: (context, index) {
                    final request = prayerProvider.userPrayerRequests[index];
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