// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import '../app_config.dart';
import 'auth.dart';

final myRentRequestsProvider = FutureProvider<List<RentRequest>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final result = await AppConfig.apiClient.getRentRequests();
  return result ?? [];
});

final rentRequestProvider =
    FutureProvider.autoDispose.family<RentRequest?, int>(
  (ref, requestId) async {
    try {
      return await AppConfig.apiClient.getRentRequest(requestId);
    } catch (_) {
      return null;
    }
  },
);

final messagesProvider = FutureProvider.autoDispose.family<List<Message>, int>(
  (ref, requestId) async {
    final result = await AppConfig.apiClient.getMessages(requestId);
    return result ?? [];
  },
);

final offersProvider = FutureProvider.autoDispose.family<List<RentOffer>, int>(
  (ref, requestId) async {
    final result = await AppConfig.apiClient.getOffers(requestId);
    return result ?? [];
  },
);

Future<RentRequest?> createRentRequest(int itemId) async {
  try {
    return await AppConfig.apiClient.createRentRequest(itemId);
  } catch (_) {
    return null;
  }
}

Future<Message?> sendMessage(int requestId, String content) async {
  try {
    return await AppConfig.apiClient.sendMessage(
      requestId,
      SendMessageRequest(content: content),
    );
  } catch (_) {
    return null;
  }
}

Future<RentOffer?> createOffer(
    int requestId, DateTime startDate, DateTime endDate,) async {
  try {
    return await AppConfig.apiClient.createOffer(
      requestId,
      CreateOfferRequest(startDate: startDate, endDate: endDate),
    );
  } catch (_) {
    return null;
  }
}

Future<RentOffer?> acceptOffer(int offerId) async {
  try {
    return await AppConfig.apiClient.acceptOffer(offerId);
  } catch (_) {
    return null;
  }
}

Future<RentRequest?> confirmBorrow(int requestId) async {
  try {
    return await AppConfig.apiClient.confirmBorrow(requestId);
  } catch (_) {
    return null;
  }
}

Future<RentRequest?> confirmReturn(int requestId) async {
  try {
    return await AppConfig.apiClient.confirmReturn(requestId);
  } catch (_) {
    return null;
  }
}
