import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/location_search.dart' hide LatLng;

final featuredItemsProvider = FutureProvider<List<FeaturedItem>>((ref) async {
  final location = ref.watch(effectiveLatLngProvider);
  final latLng = location != null ? LatLng(lat: location.lat, lng: location.lng) : null;

  return (await AppConfig.apiClient.getFeaturedItems(latLng: latLng)) ?? [];
});
