import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/renting.dart';

class RentRequestChatScreen extends ConsumerStatefulWidget {
  final int requestId;
  final RentRequest rentRequest;

  const RentRequestChatScreen({
    super.key,
    required this.requestId,
    required this.rentRequest,
  });

  @override
  ConsumerState<RentRequestChatScreen> createState() =>
      _RentRequestChatScreenState();
}

class _RentRequestChatScreenState
    extends ConsumerState<RentRequestChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await sendMessage(widget.requestId, text);
    ref.invalidate(messagesProvider(widget.requestId));
    _scrollToBottom();
  }

  Future<void> _createOffer() async {
    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (dates == null) return;
    await createOffer(widget.requestId, dates.start, dates.end);
    ref.invalidate(offersProvider(widget.requestId));
    ref.invalidate(rentRequestProvider(widget.requestId));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _acceptOffer(int offerId) async {
    await acceptOffer(offerId);
    ref.invalidate(offersProvider(widget.requestId));
    ref.invalidate(rentRequestProvider(widget.requestId));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _confirmBorrow() async {
    await confirmBorrow(widget.requestId);
    ref.invalidate(rentRequestProvider(widget.requestId));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _confirmReturn() async {
    await confirmReturn(widget.requestId);
    ref.invalidate(rentRequestProvider(widget.requestId));
    ref.invalidate(myRentRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages = ref.watch(messagesProvider(widget.requestId));
    final asyncOffers = ref.watch(offersProvider(widget.requestId));
    final asyncUser = ref.watch(authProvider);
    final asyncRequest = ref.watch(rentRequestProvider(widget.requestId));

    final request = asyncRequest.hasValue ? asyncRequest.value ?? widget.rentRequest : widget.rentRequest;
    final userId = asyncUser.hasValue ? asyncUser.value?.id : null;
    final isOwner = userId != null && request.ownerId == userId;
    final isRequester = userId != null && request.requester.id == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(request.itemTitle),
        actions: [
          if (isOwner && request.latestAcceptedOfferId != null && request.borrowConfirmedAt == null)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Ausleihe bestätigen',
              onPressed: _confirmBorrow,
            ),
          if (isOwner && request.borrowConfirmedAt != null && request.returnedAt == null)
            IconButton(
              icon: const Icon(Icons.replay),
              tooltip: 'Rückgabe bestätigen',
              onPressed: _confirmReturn,
            ),
        ],
      ),
      body: Column(
        children: [
          _StatusBanner(request: request, isOwner: isOwner),
          if (isOwner || isRequester) _OffersSection(
            offers: asyncOffers.hasValue ? asyncOffers.value ?? [] : [],
            isOwner: isOwner,
            userId: userId ?? 0,
            acceptedOfferId: request.latestAcceptedOfferId,
            onAccept: _acceptOffer,
            onCreateOffer: isRequester ? _createOffer : null,
          ),
          Expanded(
            child: asyncMessages.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Keine Nachrichten'));
                }
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = msg.authorId == userId;
                    return _MessageBubble(
                      message: msg,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final RentRequest request;
  final bool isOwner;

  const _StatusBanner({required this.request, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(request);
    final icon = _statusIcon(request);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blue[50],
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(child: Text(statusText, style: TextStyle(color: Colors.blue[700]))),
        ],
      ),
    );
  }
}

class _OffersSection extends StatelessWidget {
  final List<RentOffer> offers;
  final bool isOwner;
  final int userId;
  final int? acceptedOfferId;
  final void Function(int offerId) onAccept;
  final VoidCallback? onCreateOffer;

  const _OffersSection({
    required this.offers,
    required this.isOwner,
    required this.userId,
    required this.acceptedOfferId,
    required this.onAccept,
    required this.onCreateOffer,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty && onCreateOffer == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (offers.isNotEmpty) ...[
            Text('Angebote', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...offers.map((offer) {
              final isAccepted = offer.id == acceptedOfferId;
              final isMyOffer = offer.senderId == userId;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${offer.startDate.toLocal().toString().substring(0, 10)} - ${offer.endDate.toLocal().toString().substring(0, 10)}',
                ),
                subtitle: Text(isMyOffer ? 'Dein Angebot' : 'Angebot von anderer Person'),
                trailing: isAccepted
                    ? const Chip(label: Text('Akzeptiert'))
                    : isOwner && !isMyOffer
                        ? TextButton(
                            onPressed: () => onAccept(offer.id),
                            child: const Text('Akzeptieren'),
                          )
                        : null,
              );
            }),
          ],
          if (onCreateOffer != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: onCreateOffer,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Angebot erstellen'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt.toLocal().toString().substring(11, 16),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Nachricht schreiben...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

String _statusText(RentRequest req) {
  if (req.returnedAt != null) return 'Abgeschlossen · Rückgabe bestätigt';
  if (req.borrowConfirmedAt != null) return 'Ausgeliehen · Rückgabe ausstehend';
  if (req.latestAcceptedOfferId != null) return 'Angebot akzeptiert · Ausleihe bestätigen';
  if (req.latestOpenOfferId != null) return 'Angebot erhalten';
  return 'Ausstehend';
}

IconData _statusIcon(RentRequest req) {
  if (req.returnedAt != null) return Icons.check_circle;
  if (req.borrowConfirmedAt != null) return Icons.swap_horiz;
  if (req.latestAcceptedOfferId != null) return Icons.how_to_vote;
  if (req.latestOpenOfferId != null) return Icons.local_offer;
  return Icons.schedule;
}
