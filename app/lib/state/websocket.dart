import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../app_config.dart';
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

  WebSocketService(this._ref) {
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _ref.listen(authProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _connect();
      } else {
        _disconnect();
      }
    });
  }

  String get _wsBaseUrl {
    final restBase = AppConfig.apiBaseUrl;
    final wsBase = restBase
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceAll('/api', '');
    return '$wsBase/ws';
  }

  void _connect() {
    if (_disposed) return;
    _disconnect();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsBaseUrl));
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: () => _scheduleReconnect(),
      );
      _sendAuth();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _sendAuth() {
    final token = AppConfig.bearerAuth.accessToken as String?;
    if (token != null && token.isNotEmpty) {
      print('[ws] Sending auth');
      _channel?.sink.add(jsonEncode({'type': 'auth', 'token': token}));
    } else {
      print('[ws] No token, disconnecting');
      _disconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = msg['type'] as String?;

      // Ignore auth responses
      if (type == 'auth') {
        print('[ws] Received auth response: ${msg['status']}');
        return;
      }

      final requestId = msg['rent_request_id'] as int?;
      if (type == null || requestId == null) return;

      print('[ws] Received update: $type for request $requestId');
      _ref.invalidate(messagesProvider(requestId));
      _ref.invalidate(offersProvider(requestId));
      _ref.invalidate(rentRequestProvider(requestId));
      _ref.invalidate(myRentRequestsProvider);
    } catch (_) {
      // Ignore malformed messages
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _connect);
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
}
