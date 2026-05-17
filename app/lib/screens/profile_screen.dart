import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/router.dart';
import 'package:shareloop/state/auth.dart';

/// The profile screen
class ProfileScreen extends ConsumerWidget {
  /// Constructs a [ProfileScreen]
  const ProfileScreen({super.key});

  @override
  Widget build(ctx, ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: Center(
        child: Column(
          children: [
            const Text(AppConfig.apiBaseUrl),
            user.when(
              data: (user) => Text(user!.email),
              error: (e, s) => const Text("Auth failed"),
              loading: () => const Text("logging in"),
            ),
            ElevatedButton(
              onPressed: () => Routes.home.go(ctx),
              child: const Text('Go back to the Home screen'),
            ),
          ],
        ),
      ),
    );
  }
}
