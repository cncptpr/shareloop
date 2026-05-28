import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/app_config.dart';
import 'package:openapi/api.dart' show User;
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/state/auth.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(ctx, ref) {
    final user = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: user.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text("Auth failed"),
            data: (u) {
              if (u == null) return _notLoggedIn(ctx);
              return _loggedIn(ctx, ref, u);
            },
          ),
        ),
      ),
    );
  }

  Widget _notLoggedIn(BuildContext ctx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Not logged in'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => LoginScreen.push(ctx),
          child: const Text('Log in'),
        ),
      ],
    );
  }

  Widget _loggedIn(BuildContext ctx, WidgetRef ref, User u) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(AppConfig.apiBaseUrl),
        const SizedBox(height: 16),
        Text('ID: ${u.id}'),
        Text('Email: ${u.email}'),
        Text('Created: ${u.createdAt}'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            await logout();
            ref.invalidate(authProvider);
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
