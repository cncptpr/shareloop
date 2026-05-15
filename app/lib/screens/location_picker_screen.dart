import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/location_search_field.dart';
import 'package:shareloop/state/location_search.dart';

class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLocation = ref.watch(selectedLocationProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standort wählen'),
        actions: [
          if (hasLocation)
            TextButton(
              onPressed: () {
                ref.read(selectedLocationProvider.notifier).clear();
                Navigator.pop(context);
              },
              child: const Text('Aufheben'),
            ),
        ],
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
