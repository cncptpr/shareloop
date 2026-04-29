import 'package:flutter/material.dart';
import 'package:shareloop/router.dart';

/// The search screen
class SearchScreen extends StatelessWidget {
  /// Constructs a [SearchScreen]
  const SearchScreen({super.key});

  @override
  Widget build(ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routes.couter.go(ctx),
          child: const Text('Goto Counter'),
        ),
      ),
    );
  }
}
