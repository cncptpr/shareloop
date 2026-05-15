import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/location_search_field.dart';

class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standort wählen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LocationSearchField(
          onSelected: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
