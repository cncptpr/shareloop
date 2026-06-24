import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/router.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/token_storage.dart';

final serverInfoProvider = FutureProvider<ServerInfo?>((ref) async {
  try {
    return await AppConfig.apiClient.getInfo();
  } on ApiException catch (e) {
    debugPrint('[seeding] getInfo failed: ${e.code} ${e.message}');
    return null;
  } catch (e) {
    debugPrint('[seeding] getInfo error: $e');
    return null;
  }
});

Future<void> performSeed() async {
  try {
    await AppConfig.apiClient.seedDatabase();

    final loggedIn = await hasTokens();
    if (loggedIn) await logout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Testdaten eingespielt'),
          content: const Text(
            'Bitte starte die App neu, damit die Änderungen übernommen werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  } catch (e) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    });
  }
}

Future<void> checkSeedOnStartup(WidgetRef ref) async {
  final info = await ref.read(serverInfoProvider.future);
  if (info?.seeding == ServerInfoSeedingEnum.prompt) {
    _showStartupSeedDialog();
  }
}

void _showStartupSeedDialog() {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Testdaten einspielen?'),
      content: const Text(
        'Möchtest du die Datenbank mit Demo-Daten befüllen?\n\n'
        'Achtung: Alle vorhandenen Daten werden dabei GELÖSCHT.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text('Später fragen'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop();
            await AppConfig.apiClient.declineSeed();
          },
          child: const Text('Nein'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            performSeed();
          },
          child: const Text('Ja, jetzt einspielen'),
        ),
      ],
    ),
  );
}
