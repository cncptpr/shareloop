import 'package:openapi/api.dart';
import '../app_config.dart';

Future<UserRating?> submitUserRating({
  required int requestId,
  required SubmitUserRatingRequest userRating,
}) async {
  try {
    return await AppConfig.apiClient.submitUserRating(requestId, userRating);
  } catch (_) {
    return null;
  }
}

Future<ItemRating?> submitItemRating({
  required int requestId,
  required SubmitItemRatingRequest itemRating,
}) async {
  try {
    return await AppConfig.apiClient.submitItemRating(requestId, itemRating);
  } catch (_) {
    return null;
  }
}
