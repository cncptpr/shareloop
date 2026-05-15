import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  if (Platform.isLinux || Platform.isWindows) {
    print("[WARN] Geolocator does not support Linux and Windows");
    return null;
  }

  try {
    return await _getPosition();
  } catch (err) {
    print("[Error] An error occured while getting locations:\n$err");
    return null;
  }
});

Future<Position?> _getPosition() async {
  print("[DEBUG] Setting up Geolocator...");
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print("[WARN] Location service is disabled");
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    print("[INFO] Location permission denied, requesting permission.");
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("[WARN] Location permission was not granted.");
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    print("[WARN] Location permission denied forever.");
    return null;
  }

  print("[DEBUG] Setup successfull, retrieving current position");

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.low,
    ),
  );
}
