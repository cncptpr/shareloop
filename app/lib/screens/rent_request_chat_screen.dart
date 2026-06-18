// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/renting.dart';

class RentRequestChatScreen extends ConsumerStatefulWidget {
  final int? requestId;
  final int? itemId;
  final RentRequest? rentRequest;

  const RentRequestChatScreen.newRequest({
    required this.itemId,
    super.key,
  }) : requestId = null,
       rentRequest = null;

  const RentRequestChatScreen.existing({
    required this.requestId,
    required this.rentRequest,
    super.key,
  }) : itemId = null;

  @override
  ConsumerState<RentRequestChatScreen> createState() =>
      _RentRequestChatScreenState();
}

class _RentRequestChatScreenState
    extends ConsumerState<RentRequestChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  int? _requestId;
  bool _creatingRequest = false;

  @override
  void initState() {
    super.initState();
    _requestId = widget.requestId;
  }

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

  Future<void> _ensureRequestCreated() async {
    if (_requestId != null) return;
    if (widget.itemId == null) return;
    if (_creatingRequest) return;

    _creatingRequest = true;
    try {
      final request = await createRentRequest(widget.itemId!);
      if (request != null && mounted) {
        setState(() => _requestId = request.id);
        ref.invalidate(rentRequestProvider(request.id));
        ref.invalidate(myRentRequestsProvider);
      }
    } finally {
      _creatingRequest = false;
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_requestId == null) {
      await _ensureRequestCreated();
    }
    if (_requestId == null) return;

    _messageController.clear();
    await sendMessage(_requestId!, text);
    ref.invalidate(messagesProvider(_requestId!));
    _scrollToBottom();
  }

  Future<void> _createOffer() async {
    if (_requestId == null) {
      await _ensureRequestCreated();
    }
    if (_requestId == null) return;

    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (dates == null) return;
    await createOffer(_requestId!, dates.start, dates.end);
    ref.invalidate(offersProvider(_requestId!));
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
    _scrollToBottom();
  }

  Future<void> _acceptOffer(int offerId) async {
    if (_requestId == null) return;
    final offers = ref.read(offersProvider(_requestId!)).value ?? [];
    final offer = offers.firstWhere((o) => o.id == offerId);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Angebot akzeptieren'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Möchtest du dieses Angebot akzeptieren?'),
            const SizedBox(height: 12),
            Text(
              '${offer.startDate.toLocal().toString().substring(0, 10)} – ${offer.endDate.toLocal().toString().substring(0, 10)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Akzeptieren'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await acceptOffer(offerId);
    ref.invalidate(offersProvider(_requestId!));
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _confirmBorrow() async {
    if (_requestId == null) return;
    final request =
        ref.read(rentRequestProvider(_requestId!)).value ?? widget.rentRequest;
    final offers = ref.read(offersProvider(_requestId!)).value ?? [];
    final acceptedOffer = request?.latestAcceptedOfferId != null
        ? offers.cast<RentOffer?>().firstWhere(
              (o) => o?.id == request?.latestAcceptedOfferId,
              orElse: () => null,
            )
        : null;

    final now = DateTime.now();
    final isEarly =
        acceptedOffer != null && now.isBefore(acceptedOffer.startDate);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ausleihe bestätigen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hast du den Artikel an den Ausleiher übergeben?'),
            if (isEarly) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum beginnt erst am '
                        '${acceptedOffer.startDate.toLocal().toString().substring(0, 10)}.',
                        style: TextStyle(color: Colors.orange[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await confirmBorrow(_requestId!);
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _confirmReturn() async {
    if (_requestId == null) return;
    final request =
        ref.read(rentRequestProvider(_requestId!)).value ?? widget.rentRequest;
    final offers = ref.read(offersProvider(_requestId!)).value ?? [];
    final acceptedOffer = request?.latestAcceptedOfferId != null
        ? offers.cast<RentOffer?>().firstWhere(
              (o) => o?.id == request?.latestAcceptedOfferId,
              orElse: () => null,
            )
        : null;

    final now = DateTime.now();
    final isEarly =
        acceptedOffer != null && now.isBefore(acceptedOffer.endDate);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rückgabe bestätigen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hast du den Artikel zurückerhalten?'),
            if (isEarly) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum endet erst am '
                        '${acceptedOffer.endDate.toLocal().toString().substring(0, 10)}.',
                        style: TextStyle(color: Colors.orange[900], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await confirmReturn(_requestId!);
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
  }

  RentRequest? _resolveRequest(RentRequest? fromProvider) {
    if (fromProvider != null) return fromProvider;
    if (widget.rentRequest != null && _requestId == widget.requestId) {
      return widget.rentRequest;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages = _requestId != null
        ? ref.watch(messagesProvider(_requestId!))
        : const AsyncData<List<Message>>([]);
    final asyncOffers = _requestId != null
        ? ref.watch(offersProvider(_requestId!))
        : const AsyncData<List<RentOffer>>([]);
    final asyncUser = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      final prevId = prev?.asData?.value?.id;
      final nextId = next.asData?.value?.id;
      if (prevId != null && prevId != nextId && _requestId != null && mounted) {
        ref.invalidate(rentRequestProvider(_requestId!));
      }
    });

    final asyncRequest = _requestId != null
        ? ref.watch(rentRequestProvider(_requestId!))
        : const AsyncData<RentRequest?>(null);

    if (_requestId != null && asyncRequest.hasValue && asyncRequest.value == null) {
      Future.microtask(() {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final request = _resolveRequest(asyncRequest.value);
    final userId = asyncUser.value?.id;
    final isOwner = userId != null && request?.ownerId == userId;
    final isRequester = userId != null && request?.requester.id == userId;
    final messages = asyncMessages.value ?? [];
    final offers = asyncOffers.value ?? [];

    final hasAcceptedOffer = request?.latestAcceptedOfferId != null;
    final isBorrowed = request?.borrowConfirmedAt != null;
    final isReturned = request?.returnedAt != null;

    final title = request?.itemTitle ?? 'Neue Anfrage';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (request != null)
              Text(
                isOwner
                    ? 'Anfrage von ${request.requester.name}'
                    : 'Anbieter: ${request.ownerName}',
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
        actions: [
          if (request != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Zum Artikel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemScreen(itemId: request.itemId),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (request != null)
            _StatusBanner(request: request, isOwner: isOwner),
          Expanded(
            child: _buildChatList(
              messages,
              offers,
              userId,
              isOwner,
              isRequester,
              request,
              hasAcceptedOffer,
              isBorrowed,
              isReturned,
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onCreateOffer: (isOwner || isRequester) && !isReturned ? _createOffer : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(
    List<Message> messages,
    List<RentOffer> offers,
    int? userId,
    bool isOwner,
    bool isRequester,
    RentRequest? request,
    bool hasAcceptedOffer,
    bool isBorrowed,
    bool isReturned,
  ) {
    final chatItems = <_ChatItem>[
      for (final m in messages) _ChatItem.message(m),
      for (final o in offers) _ChatItem.offer(o),
      if (request?.borrowConfirmedAt != null)
        _ChatItem.system('Ausleihe bestätigt', createdAt: request!.borrowConfirmedAt!),
      if (request?.returnedAt != null)
        _ChatItem.system('Rückgabe bestätigt', createdAt: request!.returnedAt!),
    ];
    chatItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int actionCount = 0;
    if (isOwner && !isReturned && !isBorrowed && hasAcceptedOffer) actionCount++;
    if (isOwner && !isReturned && isBorrowed) actionCount++;

    if (chatItems.isEmpty && actionCount == 0 && _requestId == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Schreibe eine Nachricht,\num die Anfrage zu starten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatItems.length + actionCount,
      itemBuilder: (ctx, i) {
        if (i < chatItems.length) {
          final item = chatItems[i];
          switch (item.type) {
            case _ChatItemType.message:
              final isMe = item.message!.authorId == userId;
              return _MessageBubble(
                message: item.message!,
                isMe: isMe,
              );
            case _ChatItemType.offer:
              final offer = item.offer!;
              final isMyOffer = offer.senderId == userId;
              final isAccepted = offer.id == request?.latestAcceptedOfferId;
              final isLatestOpen = offer.id == request?.latestOpenOfferId;
              return _OfferBubble(
                offer: offer,
                isMyOffer: isMyOffer,
                isAccepted: isAccepted,
                canAccept: !isMyOffer && isLatestOpen,
                onAccept: () => _acceptOffer(offer.id),
              );
            case _ChatItemType.system:
              return _SystemNoteBubble(
                text: item.systemText!,
                createdAt: item.createdAt,
              );
          }
        }

        var offset = i - chatItems.length;
        if (isOwner && !isReturned && !isBorrowed && hasAcceptedOffer) {
          if (offset == 0) {
            return _SystemActionCard(
              icon: Icons.check_circle_outline,
              title: 'Ausleihe bestätigen',
              subtitle: 'Bestätige, dass der Artikel übergeben wurde',
              onTap: _confirmBorrow,
            );
          }
          offset--;
        }
        if (isOwner && !isReturned && isBorrowed) {
          if (offset == 0) {
            return _SystemActionCard(
              icon: Icons.replay,
              title: 'Rückgabe bestätigen',
              subtitle: 'Bestätige, dass der Artikel zurückgegeben wurde',
              onTap: _confirmReturn,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

String _formatDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatShortDate(date.toLocal());
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

enum _ChatItemType { message, offer, system }

class _ChatItem {
  final _ChatItemType type;
  final DateTime createdAt;
  final Message? message;
  final RentOffer? offer;
  final String? systemText;

  _ChatItem.message(this.message)
      : type = _ChatItemType.message,
        createdAt = message!.createdAt,
        offer = null,
        systemText = null;

  _ChatItem.offer(this.offer)
      : type = _ChatItemType.offer,
        createdAt = offer!.createdAt,
        message = null,
        systemText = null;

  _ChatItem.system(this.systemText, {required this.createdAt})
      : type = _ChatItemType.system,
        message = null,
        offer = null;
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

class _OfferBubble extends StatelessWidget {
  final RentOffer offer;
  final bool isMyOffer;
  final bool isAccepted;
  final bool canAccept;
  final VoidCallback onAccept;

  const _OfferBubble({
    required this.offer,
    required this.isMyOffer,
    required this.isAccepted,
    required this.canAccept,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final startStr = _formatDate(context, offer.startDate);
    final endStr = _formatDate(context, offer.endDate);

    return Align(
      alignment: isMyOffer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAccepted ? Colors.green[50] : Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccepted ? Colors.green : Colors.amber,
            width: 1.5,
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.date_range,
                  size: 16,
                  color: isAccepted ? Colors.green[700] : Colors.amber[800],
                ),
                const SizedBox(width: 6),
                Text(
                  'Angebot${isMyOffer ? ' (von dir)' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isAccepted ? Colors.green[700] : Colors.amber[800],
                  ),
                ),
                if (isAccepted) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Akzeptiert',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$startStr – $endStr',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            if (canAccept) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.thumb_up, size: 18),
                  label: const Text('Akzeptieren'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SystemActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SystemActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[500]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemNoteBubble extends StatelessWidget {
  final String text;
  final DateTime createdAt;

  const _SystemNoteBubble({required this.text, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(context, createdAt);
    final timeStr = createdAt.toLocal().toString().substring(11, 16);
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$dateStr $timeStr',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
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
  final VoidCallback? onCreateOffer;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    this.onCreateOffer,
  });

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
            if (onCreateOffer != null) ...[
              IconButton(
                icon: const Icon(Icons.event),
                tooltip: 'Angebot erstellen',
                onPressed: onCreateOffer,
              ),
              const SizedBox(width: 4),
            ],
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
