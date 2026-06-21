// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/router.dart';
import 'package:shareloop/state/websocket.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static String get _title {
    const ns = AppConfig.storageNamespace;
    return ns.isEmpty ? 'shareloop' : 'shareloop [$ns]';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(webSocketProvider);
    return MaterialApp.router(title: _title, routerConfig: router);
  }
}
