// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/router.dart';
import 'package:shareloop/services/notification_service.dart';
import 'package:shareloop/state/seeding.dart';
import 'package:shareloop/state/websocket.dart';
import 'package:shareloop/theme/app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSeedOnStartup(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(webSocketProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: _title,
      theme: buildTheme(),
      routerConfig: router,
    );
  }

  static String get _title {
    const ns = AppConfig.storageNamespace;
    return ns.isEmpty ? 'shareloop' : 'shareloop [$ns]';
  }
}
