import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The profile screen
class ProfileScreen extends StatelessWidget {
  /// Constructs a [ProfileScreen]
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go back to the Home screen'),
        ),
      ),
    );
  }
}
