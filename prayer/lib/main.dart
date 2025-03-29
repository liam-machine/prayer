import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/providers/auth_provider.dart';
import 'package:prayer/providers/prayer_provider.dart';
import 'package:prayer/providers/theme_provider.dart';
import 'package:prayer/screens/login_screen.dart';
import 'package:prayer/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      child: const PrayerApp(),
    );
  }
}

class PrayerApp extends StatefulWidget {
  const PrayerApp({super.key});

  @override
  State<PrayerApp> createState() => _PrayerAppState();
}

class _PrayerAppState extends State<PrayerApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Prayer Connect',
      theme: themeProvider.getTheme(false),
      darkTheme: themeProvider.getTheme(true),
      themeMode: themeProvider.themeMode,
      home: authProvider.isAuthenticated 
          ? const HomeScreen() 
          : const LoginScreen(),
    );
  }
}
