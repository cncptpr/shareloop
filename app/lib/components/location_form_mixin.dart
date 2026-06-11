import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/state/location.dart';
import 'package:shareloop/state/location_search.dart';

mixin LocationFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  SearchedLocation? get selectedLocation;
  set selectedLocation(SearchedLocation? value);

  void setProviderLocation(SelectedLocation? loc);

  String? locationLabel() {
    final loc = selectedLocation;
    if (loc == null) return null;
    final parts = [loc.postalCode, loc.city]..removeWhere((s) => s.isEmpty);
    return parts.isEmpty ? loc.name : parts.join(' ');
  }

  void applyLocation(SearchedLocation loc) {
    selectedLocation = loc;
    setProviderLocation(loc);
  }

  void clearLocation() {
    selectedLocation = null;
    setProviderLocation(null);
  }

  Future<void> openLocationPicker() async {
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLocation: selectedLocation,
        ),
      ),
    );
    if (!mounted) return;
    if (result is SearchedLocation) {
      applyLocation(result);
    } else if (result is GPSLocation) {
      await resolveGpsFromPicker();
    } else {
      clearLocation();
    }
  }

  Future<void> resolveGpsFromPicker() async {
    try {
      final gps = await ref.read(currentPositionProvider.future);
      if (gps == null || !mounted) return;
      final loc = await ref.read(
        reverseLocationProvider((gps.latitude, gps.longitude)).future,
      );
      if (loc == null ||
          loc.city.isEmpty ||
          loc.postalCode.isEmpty ||
          !mounted) {
        return;
      }applyLocation(loc);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Konnte Standort nicht ermitteln. Bitte versuche es erneut.',
            ),
          ),
        );
      }
    }
  }
}
