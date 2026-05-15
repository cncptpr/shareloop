import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shareloop/state/location.dart';

class SearchedLocation {
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
}

class RateLimitException implements Exception {
  final int? retryAfterSeconds;
  const RateLimitException({this.retryAfterSeconds});
}

class SelectedLocationNotifier extends Notifier<SearchedLocation?> {
  @override
  SearchedLocation? build() => null;

  void select(SearchedLocation location) => state = location;
  void clear() => state = null;
}

final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, SearchedLocation?>(
  SelectedLocationNotifier.new,
);

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
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  throw StateError('unreachable');
}

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
            '')
        as String;
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

final effectiveLatLngProvider = Provider<(double?, double?)>((ref) {
  final manual = ref.watch(selectedLocationProvider);
  if (manual != null) return (manual.lat, manual.lng);

  final gps = ref.watch(currentPositionProvider).asData?.value;
  if (gps != null) return (gps.latitude, gps.longitude);

  return (null, null);
});
