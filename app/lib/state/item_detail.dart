import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

final itemDetailProvider = FutureProvider.autoDispose.family<ItemDetail, int>((ref, itemId) async {
  final result = await AppConfig.apiClient.getItem(itemId);
  if (result == null) throw Exception('Item not found');
  return result;
});
