import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/rent_request_chat_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/renting.dart';

class MessageScreen extends ConsumerWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authProvider);
    final asyncRequests = ref.watch(myRentRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Anfragen')),
      body: asyncRequests.when(
        data: (requests) {
          if (asyncUser.value == null) {
            return const Center(child: Text('Bitte einloggen'));
          }
          if (requests.isEmpty) {
            return const Center(child: Text('Keine Anfragen'));
          }
          final userId = asyncUser.value!.id;
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myRentRequestsProvider);
            },
            child: ListView.separated(
              itemCount: requests.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final req = requests[i];
                final otherName =
                    req.requester.id == userId ? req.ownerName : req.requester.name;
                final subtitle = _statusText(req);

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(otherName.isNotEmpty
                        ? otherName[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(req.itemTitle),
                  subtitle: Text('$otherName · $subtitle'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RentRequestChatScreen(
                          requestId: req.id,
                          rentRequest: req,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

String _statusText(RentRequest req) {
  if (req.returnedAt != null) return 'Rückgabe bestätigt · Abgeschlossen';
  if (req.borrowConfirmedAt != null) return 'Ausgeliehen';
  if (req.latestAcceptedOfferId != null) return 'Angebot akzeptiert';
  if (req.latestOpenOfferId != null) return 'Angebot erhalten';
  return 'Ausstehend';
}
