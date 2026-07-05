import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

final userProfileProvider = FutureProvider.family<UserProfile, int>((ref, userId) async {
  final result = await AppConfig.apiClient.getUserProfile(userId);
  if (result == null) throw Exception('Profile not found');
  return result;
});

final userItemsProvider = FutureProvider.family<List<ItemOverview>, int>((ref, userId) async {
  final result = await AppConfig.apiClient.getUserItems(userId);
  return result ?? [];
});

final userRatingsProvider = FutureProvider.family<List<UserRatingDetail>, int>((ref, userId) async {
  final result = await AppConfig.apiClient.getUserRatings(userId);
  return result ?? [];
});
