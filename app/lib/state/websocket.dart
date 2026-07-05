import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../app_config.dart';
import '../services/notification_service.dart';
import 'auth.dart';
import 'renting.dart';

final webSocketProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

class WebSocketService {
  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _disposed = false;
  int _reconnectAttempts = 0;

  int? currentChatRequestId;

  WebSocketService(this._ref) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _ref.listen(authProvider, (previous, next) {
      final user = next.value;
      _reconnectAttempts = 0;
      if (user != null) {
        _connect();
      } else {
        _disconnect();
      }
    });
  }

  String get _wsBaseUrl {
    const restBase = AppConfig.apiBaseUrl;
    if (restBase.startsWith('http://') || restBase.startsWith('https://')) {
      final uri = Uri.parse(restBase);
      return Uri(
        scheme: uri.scheme == 'https' ? 'wss' : 'ws',
        host: uri.host,
        port: uri.port,
        path: '/ws',
      ).toString();
    }
    final page = Uri.base;
    return Uri(
      scheme: page.scheme == 'https' ? 'wss' : 'ws',
      host: page.host,
      port: page.port,
      path: '/ws',
    ).toString();
  }

  void _connect() {
    if (_disposed) return;
    _disconnect();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsBaseUrl));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          debugPrint('[ws] stream error: $e');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[ws] stream closed');
          _scheduleReconnect();
        },
      );
      Future.delayed(const Duration(milliseconds: 100), _sendAuth);
    } catch (e) {
      debugPrint('[ws] connect error: $e');
      _scheduleReconnect();
    }
  }

  void _sendAuth() {
    final token = AppConfig.bearerAuth.accessToken as String?;
    if (token != null && token.isNotEmpty) {
      debugPrint('[ws] Sending auth');
      _channel?.sink.add(jsonEncode({'type': 'auth', 'token': token}));
    } else {
      debugPrint('[ws] No token, disconnecting');
      _disconnect();
    }
  }

  void _onMessage(dynamic raw) {
    _reconnectAttempts = 0;
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String?;

      if (type == 'auth') {
        debugPrint('[ws] Received auth response: ${msg['status']}');
        if (msg['status'] == 'error' || msg['status'] == 'timeout') {
          _disconnect();
        }
        return;
      }

      final requestId = msg['rent_request_id'] as int?;
      if (type == null || requestId == null) return;

      debugPrint('[ws] Received update: $type for request $requestId');
      _ref.invalidate(rentRequestProvider(requestId));
      _ref.invalidate(myRentRequestsProvider);

      final currentChatId = currentChatRequestId;
      if (requestId != currentChatId) {
        _showNotification(type);
      }
    } catch (e) {
      debugPrint('[ws] malformed message: $e');
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectAttempts++;
    const maxAttempts = 10;
    if (_reconnectAttempts > maxAttempts) {
      debugPrint('[ws] max reconnect attempts ($maxAttempts) reached, giving up');
      return;
    }
    _reconnectTimer?.cancel();
    final raw = 1000 * (1 << (_reconnectAttempts - 1));
    final ms = raw < 30000 ? raw : 30000;
    debugPrint('[ws] reconnect $_reconnectAttempts/$maxAttempts in ${ms}ms');
    _reconnectTimer = Timer(Duration(milliseconds: ms), _connect);
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _disposed = true;
    _disconnect();
  }

  String _notificationBody(String type) {
    if (type.startsWith('message')) return 'Neue Nachricht';
    if (type.startsWith('offer.created')) return 'Neues Angebot';
    if (type.startsWith('offer.accepted')) return 'Angebot akzeptiert';
    if (type.startsWith('borrow')) return 'Ausleihe bestätigt';
    if (type.startsWith('return')) return 'Rückgabe bestätigt';
    return 'Neues Ereignis in einer Anfrage';
  }

  void _showNotification(String type) {
    NotificationService().showMessageNotification(
      title: 'Neue Aktivität',
      body: _notificationBody(type),
    );
  }
}
