import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart' show ServerInfo, User;
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/seeding.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final serverInfo = ref.watch(serverInfoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: user.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text("Auth failed"),
            data: (u) {
              if (u == null) return _notLoggedIn(ctx, ref, serverInfo);
              return _loggedIn(ctx, ref, u, serverInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _notLoggedIn(
    BuildContext ctx,
    WidgetRef ref,
    AsyncValue<ServerInfo?> serverInfo,
  ) {
    final seedingAvailable =
        serverInfo.whenOrNull(data: (d) => d)?.seeding != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Not logged in'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => LoginScreen.push(ctx),
          child: const Text('Log in'),
        ),
        if (seedingAvailable) ...[
          const SizedBox(height: 24),
          _seedButton(ctx),
        ],
      ],
    );
  }

  Widget _loggedIn(
    BuildContext ctx,
    WidgetRef ref,
    User u,
    AsyncValue<ServerInfo?> serverInfo,
  ) {
    final seedingAvailable =
        serverInfo.whenOrNull(data: (d) => d)?.seeding != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(AppConfig.apiBaseUrl),
        const SizedBox(height: 16),
        Text('ID: ${u.id}'),
        Text('Email: ${u.email}'),
        Text('Created: ${u.createdAt}'),
        const SizedBox(height: 24),
        if (seedingAvailable) ...[
          _seedButton(ctx),
          const SizedBox(height: 16),
        ],
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

  Widget _seedButton(BuildContext ctx) {
    return ElevatedButton.icon(
      onPressed: () => _showSeedConfirmDialog(ctx),
      icon: const Icon(Icons.storage),
      label: const Text('Demo-Daten einspielen'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade100,
        foregroundColor: Colors.orange.shade900,
      ),
    );
  }

  void _showSeedConfirmDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Demo-Daten einspielen?'),
        content: const Text(
          'ACHTUNG: Dabei werden ALLE vorhandenen Daten gelöscht!\n\n'
          'Vorhandene Nutzer, Artikel, Anfragen und Nachrichten werden '
          'unwiderruflich entfernt und durch Demo-Daten ersetzt.\n\n'
          'Fortfahren?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              performSeed();
            },
            child: const Text('Ja, einspielen'),
          ),
        ],
      ),
    );
  }
}
