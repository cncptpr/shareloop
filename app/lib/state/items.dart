import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/location.dart';

final featuredItemsProvider = FutureProvider<List<FeaturedItem>>((ref) async {
  final position = await ref.read(currentPositionProvider.future);
  return (await AppConfig.apiClient.getFeaturedItems(
    lat: position?.latitude,
    lng: position?.longitude,
  )) ?? [];
});
