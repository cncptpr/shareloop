import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';

final bookedDatesProvider =
    FutureProvider.autoDispose.family<List<DateRange>, int>(
  (ref, itemId) async {
    final result = await AppConfig.apiClient.getBookedDates(itemId);
    return result ?? [];
  },
);
