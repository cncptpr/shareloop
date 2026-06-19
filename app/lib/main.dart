// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/router.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String get _title {
    final ns = AppConfig.storageNamespace;
    return ns.isEmpty ? 'shareloop' : 'shareloop [$ns]';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: _title, routerConfig: router);
  }
}
