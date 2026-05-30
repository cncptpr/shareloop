import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

final featuredItemsProvider = FutureProvider<List<FeaturedItem>>((ref) async {
  return (await AppConfig.apiClient.getFeaturedItems()) ?? [];
});
