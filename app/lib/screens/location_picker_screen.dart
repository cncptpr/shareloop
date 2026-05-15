import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/location_search_field.dart';
import 'package:shareloop/state/location_search.dart';

class LocationPickerScreen extends ConsumerWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standort wählen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: LocationSearchField(
              onSelected: () => Navigator.pop(context),
            ),
          ),
          TextButton.icon(
            onPressed: Platform.isLinux || Platform.isWindows
                ? null
                : () {
                    ref.read(selectedLocationProvider.notifier).clear();
                    Navigator.pop(context);
                  },
            icon: Icon(
              Icons.my_location,
              color: Platform.isLinux || Platform.isWindows
                  ? Theme.of(context).disabledColor
                  : null,
            ),
            label: Text(
              'Aktuelle Position verwenden',
              style: Platform.isLinux || Platform.isWindows
                  ? TextStyle(color: Theme.of(context).disabledColor)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
