import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(milliseconds: 2500),
      () {
        if (mounted) {
          widget.onFinished();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 112,
                width: 112,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'FOOTBALL',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'ARCHIVE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 9,
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'WHERE FOOTBALL HISTORY LIVES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2.5,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 55),

              const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
