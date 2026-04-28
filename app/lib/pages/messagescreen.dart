import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The details screen
class MessageScreen extends StatelessWidget {
  /// Constructs a [MessageScreen]
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Messages Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go back to the Home screen'),
        ),
      ),
    );
  }
}

