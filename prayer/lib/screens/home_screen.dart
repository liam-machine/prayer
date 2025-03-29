import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/providers/auth_provider.dart';
import 'package:prayer/providers/prayer_provider.dart';
import 'package:prayer/screens/my_prayers_screen.dart';
import 'package:prayer/screens/friends_prayers_screen.dart';
import 'package:prayer/screens/profile_screen.dart';
import 'package:prayer/screens/add_prayer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MyPrayersScreen(),
    const FriendsPrayersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize prayer provider with current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
      
      if (authProvider.appUser != null) {
        prayerProvider.initializeForUser(authProvider.appUser!);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'My Prayers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPrayerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 