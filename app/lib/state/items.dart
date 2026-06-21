import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/item_search.dart';
import 'package:shareloop/state/location_search.dart';

final featuredItemsProvider = FutureProvider<List<ItemOverview>>((ref) async {
  final location = ref.watch(effectiveLatLngProvider);

  return (await AppConfig.apiClient.getFeaturedItems(latLng: location)) ?? [];
});

final searchItemsProvider = FutureProvider<List<ItemOverview>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final location = ref.watch(effectiveLatLngProvider);

  return (await AppConfig.apiClient.searchItems(
    itemSearchRequest: filters.toRequest(location),
  )) ?? [];
});
