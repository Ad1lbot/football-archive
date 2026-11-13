import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'providers/player_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(),
        ),
      ],
      child: const FootballArchiveApp(),
    ),
  );
}

class FootballArchiveApp extends StatelessWidget {
  const FootballArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Archive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntryScreen(),
    );
  }
}

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  bool _showSplash = true;

  void _finishSplash() {
    if (!mounted) return;

    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onFinished: _finishSplash,
      );
    }

    return const HomeScreen();
  }
}
