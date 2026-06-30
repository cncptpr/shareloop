// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/rent_request_chat_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/renting.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  bool _showClosed = false;

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(authProvider);
    final asyncRequests = ref.watch(myRentRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anfragen'),
        actions: [
          if (asyncUser.value != null)
            TextButton.icon(
              onPressed: () => setState(() => _showClosed = !_showClosed),
              icon: Icon(_showClosed ? Icons.visibility_off : Icons.visibility),
              label: Text(_showClosed ? 'Ausblenden' : 'Abgeschlossene'),
            ),
        ],
      ),
      body: asyncRequests.when(
        data: (requests) {
          if (asyncUser.value == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bitte einloggen'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => LoginScreen.push(context),
                    child: const Text('Einloggen'),
                  ),
                ],
              ),
            );
          }

          final filtered = _showClosed
              ? requests
              : requests.where((r) => r.returnedAt == null).toList();

          final userId = asyncUser.value!.id;
          final incoming = filtered.where((r) => r.ownerId == userId).toList();
          final outgoing =
              filtered.where((r) => r.requester.id == userId).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                  _showClosed ? 'Keine Anfragen' : 'Keine offenen Anfragen'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myRentRequestsProvider);
            },
            child: ListView(
              children: [
                if (incoming.isNotEmpty) ...[
                  const _SectionHeader(title: 'Eingehend'),
                  ...incoming.map((req) => _requestTile(req, userId)),
                ],
                if (outgoing.isNotEmpty) ...[
                  const _SectionHeader(title: 'Ausgehend'),
                  ...outgoing.map((req) => _requestTile(req, userId)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _requestTile(RentRequestOverview req, int userId) {
    final otherName =
        req.requester.id == userId ? req.ownerName : req.requester.name;
    final subtitle = _statusText(req);

    return ListTile(
      leading: CircleAvatar(
        child: Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?'),
      ),
      title: Text(req.itemTitle),
      subtitle: Text('$otherName · $subtitle'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (req.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${req.unreadCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RentRequestChatScreen.existing(
              requestId: req.id,
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

String _statusText(RentRequestOverview req) {
  if (req.returnedAt != null) return 'Rückgabe bestätigt · Abgeschlossen';
  if (req.borrowConfirmedAt != null) return 'Ausgeliehen';
  if (req.latestAcceptedOfferId != null) return 'Angebot akzeptiert';
  if (req.latestOpenOfferId != null) return 'Angebot erhalten';
  return 'Ausstehend';
}
