import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// TODO: introduce logging to replace debugPrint()
// TODO: rename this file to something 'gps' or 'geolocator'
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  if (Platform.isLinux || Platform.isWindows) {
    debugPrint("[WARN] Geolocator does not support Linux and Windows");
    return null;
  }

  try {
    return await _getPosition();
  } catch (err) {
    debugPrint("[Error] An error occured while getting locations:\n$err");
    return null;
  }
});

Future<Position?> _getPosition() async {
  debugPrint("[DEBUG] Setting up Geolocator...");
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("[WARN] Location service is disabled");
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    debugPrint("[INFO] Location permission denied, requesting permission.");
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint("[WARN] Location permission was not granted.");
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    debugPrint("[WARN] Location permission denied forever.");
    return null;
  }

  debugPrint("[DEBUG] Setup successfull, retrieving current position");

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.low,
    ),
  );
}
