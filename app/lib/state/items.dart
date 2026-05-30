import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/location_search.dart';

final featuredItemsProvider = FutureProvider<List<FeaturedItem>>((ref) async {
  final location = ref.watch(effectiveLatLngProvider);

  return (await AppConfig.apiClient.getFeaturedItems(latLng: location)) ?? [];
});
