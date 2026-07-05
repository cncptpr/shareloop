import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart' show ServerInfo;
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/seeding.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverInfo = ref.watch(serverInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AccountSection(),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _DebugSection(serverInfo: serverInfo),
          ],
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konto',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await logout();
              ref.invalidate(authProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }
}

class _DebugSection extends ConsumerWidget {
  final AsyncValue<ServerInfo?> serverInfo;

  const _DebugSection({required this.serverInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedingAvailable =
        serverInfo.whenOrNull(data: (d) => d)?.seeding != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debug',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _InfoRow(label: 'Backend-URL', value: AppConfig.apiBaseUrl),
                if (AppConfig.storageNamespace.isNotEmpty)
                  const _InfoRow(
                    label: 'Storage-Namespace',
                    value: AppConfig.storageNamespace,
                  ),
              ],
            ),
          ),
        ),
        if (seedingAvailable) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showReSeedConfirmDialog(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Datenbank mit seeding Daten ersetzen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showReSeedConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Datenbank mit seeding Daten ersetzen?'),
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
            child: const Text('Ja, ersetzen'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
