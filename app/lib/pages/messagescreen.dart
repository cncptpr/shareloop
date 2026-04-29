import 'package:flutter/material.dart';
import 'package:shareloop/router.dart';

/// The details screen
class MessageScreen extends StatelessWidget {
  /// Constructs a [MessageScreen]
  const MessageScreen({super.key});

  @override
  Widget build(ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Messages Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Routes.home.go(ctx),
          child: const Text('Go back to the Home screen'),
        ),
      ),
    );
  }
}
