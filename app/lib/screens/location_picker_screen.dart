import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/location_search_field.dart';
import 'package:shareloop/state/location_search.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  final SelectedLocation? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  SelectedLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _confirm() {
    Navigator.pop(context, _selectedLocation);
  }

  void _clear() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standort wählen'),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _clear,
              child: const Text('Aufheben'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LocationSearchField(
          selectedLocation: _selectedLocation,
          onLocationSelected: (loc) {
            setState(() => _selectedLocation = loc);
            _confirm();
          },
          onGpsSelected: () {
            setState(() => _selectedLocation = const GPSLocation());
            _confirm();
          },
        ),
      ),
    );
  }
}