import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

final itemProvider = FutureProvider<List<FeaturedItem>>((ref) async {
  return (await AppConfig.apiClient.getFeaturedItems()) ?? [];
});
