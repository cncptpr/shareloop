import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:openapi/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shareloop/state/location.dart';

sealed class SelectedLocation {
  Map<String, dynamic> selectedToJson();
  factory SelectedLocation.selectedFromJson(Map<String, dynamic> json) {
    if (json['type'] == 'GPSLocation') {
      return GPSLocation();
    } else if (json['type'] == 'SearchedLocation') {
      return SearchedLocation.fromJson(json['loc'] as Map<String, dynamic>);
    }
    throw Exception(
      'There must be a field "type" with either "GPSLocation" or "SearchedLocation"',
    );
  }
}

class GPSLocation implements SelectedLocation {
  @override
  Map<String, dynamic> selectedToJson() => {
        'type': 'GPSLocation',
      };
}

class SearchedLocation implements SelectedLocation {
  final double lat;
  final double lng;
  final String displayName;
  final String name;

  const SearchedLocation({
    required this.lat,
    required this.lng,
    required this.displayName,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'displayName': displayName,
        'name': name,
      };

  factory SearchedLocation.fromJson(Map<String, dynamic> json) =>
      SearchedLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        displayName: json['displayName'] as String,
        name: json['name'] as String,
      );

  @override
  Map<String, dynamic> selectedToJson() => {
        'type': 'SearchedLocation',
        'loc': toJson(),
      };
}

class RateLimitException implements Exception {
  final int? retryAfterSeconds;
  const RateLimitException({this.retryAfterSeconds});
}

const _maxStoredLocations = 20;
const _keySelectedLocation = 'selected_location';
const _keyStoredLocations = 'stored_locations';

Future<void> _saveSelectedLocation(SelectedLocation? location) async {
  final prefs = await SharedPreferences.getInstance();
  if (location == null) {
    await prefs.remove(_keySelectedLocation);
  } else {
    await prefs.setString(
      _keySelectedLocation,
      jsonEncode(location.selectedToJson()),
    );
  }
}

Future<void> _saveStoredLocations(List<SearchedLocation> locations) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _keyStoredLocations,
    jsonEncode(locations.map((l) => l.toJson()).toList()),
  );
}

Future<List<SearchedLocation>> _loadStoredLocations() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keyStoredLocations);
  if (raw == null) return [];
  final list = jsonDecode(raw) as List;
  return list
      .map((e) => SearchedLocation.fromJson(e as Map<String, dynamic>))
      .toList();
}

class SelectedLocationNotifier extends Notifier<SelectedLocation?> {
  // The following variable lives inside Notifier:
  // ```dart
  // SelectedLocation? state;
  // ```

  @override
  SearchedLocation? build() {
    _loadFromPrefs();
    return null;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySelectedLocation);
    if (raw != null) {
      final location = SelectedLocation.selectedFromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      state = location;
    }
  }

  Future<void> select(SelectedLocation location) async {
    state = location;
    await _saveSelectedLocation(location);
    final stored = await _loadStoredLocations();
    if (location is SearchedLocation) {
      stored.removeWhere((l) => l.lat == location.lat && l.lng == location.lng);
      stored.insert(0, location);
    }
    if (stored.length > _maxStoredLocations) {
      stored.removeLast();
    }
    await _saveStoredLocations(stored);
  }

  Future<void> selectGPS() async => select(GPSLocation());

  Future<void> clear() async {
    state = null;
    await _saveSelectedLocation(null);
  }
}

final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, SelectedLocation?>(
  SelectedLocationNotifier.new,
);

final storedLocationsProvider = FutureProvider<List<SearchedLocation>>(
  (ref) => _loadStoredLocations(),
);

Future<void> removeStoredLocation(SearchedLocation location) async {
  final stored = await _loadStoredLocations();
  stored.removeWhere((l) => l.lat == location.lat && l.lng == location.lng);
  await _saveStoredLocations(stored);
}

Future<http.Response> _fetchWithRetry(
  Future<http.Response> Function() request, {
  int maxRetries = 2,
}) async {
  for (var i = 0; i < maxRetries; i++) {
    try {
      final res = await request().timeout(const Duration(seconds: 5));
      if (res.statusCode == 429) {
        final retryAfter = int.tryParse(res.headers['retry-after'] ?? '');
        throw RateLimitException(retryAfterSeconds: retryAfter);
      }
      return res;
    } on RateLimitException {
      rethrow;
    } catch (_) {
      if (i == maxRetries) rethrow;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  throw StateError('unreachable');
}

// TODO: extract nominatim request into other file
final locationSearchProvider =
    FutureProvider.family<List<SearchedLocation>, String>(
  (ref, query) async {
    if (query.trim().length < 2) return [];
    final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'countrycodes': 'de',
      },
    );
    final res = await _fetchWithRetry(
      () => http.get(uri, headers: {'User-Agent': 'shareloop/1.0'}),
    );
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((j) {
      return SearchedLocation(
        lat: double.parse(j['lat'] as String),
        lng: double.parse(j['lon'] as String),
        displayName: j['display_name'] as String,
        name: j['name'] as String,
      );
    }).toList();
  },
);

final reverseLocationProvider =
    FutureProvider.family<SearchedLocation?, (double, double)>(
  (ref, coords) async {
    final (lat, lng) = coords;
    final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse')
        .replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
    });
    final res = await _fetchWithRetry(
      () => http.get(uri, headers: {'User-Agent': 'shareloop/1.0'}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data.containsKey('error')) return null;
    final addr = data['address'] as Map<String, dynamic>;
    final city = (addr['city'] ??
        addr['town'] ??
        addr['village'] ??
        addr['municipality'] ??
        '') as String;
    final postcode = (addr['postcode'] ?? '') as String;
    final name = postcode.isNotEmpty ? '$postcode $city' : city;
    return SearchedLocation(
      lat: lat,
      lng: lng,
      displayName: data['display_name'] as String,
      name: name,
    );
  },
);

final effectiveLatLngProvider = Provider<LatLng?>((ref) {
  final selected = ref.watch(selectedLocationProvider);
  if (selected is SearchedLocation) {
    return LatLng(lat: selected.lat, lng: selected.lng);
  } else if (selected is GPSLocation) {
    final gps = ref.watch(currentPositionProvider).asData?.value;
    if (gps != null) return LatLng(lat: gps.latitude, lng: gps.longitude);
  }

  return null;
});
