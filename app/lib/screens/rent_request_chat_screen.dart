// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/item_detail.dart';
import 'package:shareloop/state/renting.dart';
import 'package:shareloop/state/websocket.dart';

class RentRequestChatScreen extends ConsumerStatefulWidget {
  final int? requestId;
  final int? itemId;
  final RentRequestDetail? rentRequest;

  const RentRequestChatScreen.newRequest({
    required this.itemId,
    super.key,
  })  : requestId = null,
        rentRequest = null;

  const RentRequestChatScreen.existing({
    required this.requestId,
    this.rentRequest,
    super.key,
  }) : itemId = null;

  @override
  ConsumerState<RentRequestChatScreen> createState() =>
      _RentRequestChatScreenState();
}

class _RentRequestChatScreenState extends ConsumerState<RentRequestChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  int? _requestId;
  bool _creatingRequest = false;
  bool _showScrollToBottom = false;
  bool _didInitialScroll = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _requestId = widget.requestId;
    _scrollController.addListener(_onScrollChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestId != null && mounted) {
      ref.read(webSocketProvider).currentChatRequestId = _requestId;
    }
  }

  @override
  void dispose() {
    ref.read(webSocketProvider).currentChatRequestId = null;
    _messageController.dispose();
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    const threshold = 150.0;
    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold;
    final shouldShow = !atBottom;
    if (shouldShow != _showScrollToBottom && mounted) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  void _tryScrollToBottom() {
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _scrollToBottom();
      _didInitialScroll = true;
    }
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
        ref.read(webSocketProvider).currentChatRequestId = request.id;
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
    ref.invalidate(rentRequestProvider(_requestId!));
    _scrollToBottom();
  }

  Future<void> _createOffer() async {
    if (_requestId == null) {
      await _ensureRequestCreated();
    }
    if (_requestId == null) return;
    if (!mounted) return;

    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (dates == null) return;
    await createOffer(_requestId!, dates.start, dates.end);
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
    _scrollToBottom();
  }

  Future<void> _acceptOffer(int offerId) async {
    if (_requestId == null) return;
    final request =
        ref.read(rentRequestProvider(_requestId!)).value ?? widget.rentRequest;
    final offers = request?.offers ?? [];
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
              '${_formatDateSimple(offer.startDate)} – ${_formatDateSimple(offer.endDate)}',
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
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _confirmBorrow() async {
    if (_requestId == null) return;
    final request =
        ref.read(rentRequestProvider(_requestId!)).value ?? widget.rentRequest;
    final offers = request?.offers ?? [];
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
                    Icon(Icons.warning_amber,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum beginnt erst am '
                        '${_formatDateSimple(acceptedOffer.startDate)}.',
                        style:
                            TextStyle(color: Colors.orange[900], fontSize: 13),
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
    final offers = request?.offers ?? [];
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
                    Icon(Icons.warning_amber,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum endet erst am '
                        '${_formatDateSimple(acceptedOffer.endDate)}.',
                        style:
                            TextStyle(color: Colors.orange[900], fontSize: 13),
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

  Future<void> _showUserRatingDialog(
      RentRequestDetail request, bool isOwner) async {
    if (_requestId == null) return;
    final revieweeName = isOwner ? request.requester.name : request.ownerName;
    final userCommentController = TextEditingController();

    int? friendliness;
    int? punctuality;
    int? reliability;
    int? roleSpecific;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final userRatingComplete = friendliness != null &&
              punctuality != null &&
              reliability != null &&
              roleSpecific != null;

          return AlertDialog(
            title: Text('$revieweeName bewerten'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _RatingStars(
                      label: 'Freundlichkeit',
                      value: friendliness,
                      onChanged: (value) =>
                          setDialogState(() => friendliness = value),
                    ),
                    _RatingStars(
                      label: 'Pünktlichkeit',
                      value: punctuality,
                      onChanged: (value) =>
                          setDialogState(() => punctuality = value),
                    ),
                    _RatingStars(
                      label: 'Zuverlässigkeit',
                      value: reliability,
                      onChanged: (value) =>
                          setDialogState(() => reliability = value),
                    ),
                    _RatingStars(
                      label: isOwner ? 'Sorgsamer Umgang' : 'Kommunikation',
                      value: roleSpecific,
                      onChanged: (value) =>
                          setDialogState(() => roleSpecific = value),
                    ),
                    TextField(
                      controller: userCommentController,
                      decoration: const InputDecoration(
                        labelText: 'Kommentar (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              FilledButton.icon(
                onPressed:
                    userRatingComplete ? () => Navigator.pop(ctx, true) : null,
                icon: const Icon(Icons.star, size: 18),
                label: const Text('Bewertung senden'),
              ),
            ],
          );
        },
      ),
    );
    if (submitted != true) {
      userCommentController.dispose();
      return;
    }

    final userComment = userCommentController.text.trim();
    userCommentController.dispose();

    final rating = await submitUserRating(
      requestId: _requestId!,
      userRating: SubmitUserRatingRequest(
        friendliness: friendliness!,
        punctuality: punctuality!,
        reliability: reliability!,
        communication: isOwner ? null : roleSpecific!,
        carefulHandling: isOwner ? roleSpecific! : null,
        comment: userComment.isEmpty ? null : userComment,
      ),
    );
    if (!mounted) return;
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bewertung konnte nicht gespeichert werden.')),
      );
      return;
    }

    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
  }

  Future<void> _showItemRatingDialog(RentRequestDetail request) async {
    if (_requestId == null) return;
    final commentController = TextEditingController();
    int? condition;
    int? cleanliness;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final ratingComplete = condition != null && cleanliness != null;
          return AlertDialog(
            title: Text('${request.itemTitle} bewerten'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _RatingStars(
                      label: 'Zustand',
                      value: condition,
                      onChanged: (value) =>
                          setDialogState(() => condition = value),
                    ),
                    _RatingStars(
                      label: 'Sauberkeit',
                      value: cleanliness,
                      onChanged: (value) =>
                          setDialogState(() => cleanliness = value),
                    ),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Kommentar (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              FilledButton.icon(
                onPressed:
                    ratingComplete ? () => Navigator.pop(ctx, true) : null,
                icon: const Icon(Icons.star, size: 18),
                label: const Text('Bewertung senden'),
              ),
            ],
          );
        },
      ),
    );
    if (submitted != true) {
      commentController.dispose();
      return;
    }

    final comment = commentController.text.trim();
    commentController.dispose();
    final rating = await submitItemRating(
      requestId: _requestId!,
      itemRating: SubmitItemRatingRequest(
        condition: condition!,
        cleanliness: cleanliness!,
        comment: comment.isEmpty ? null : comment,
      ),
    );
    if (!mounted) return;
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Gegenstandsbewertung konnte nicht gespeichert werden.'),
        ),
      );
      return;
    }

    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
    ref.invalidate(itemDetailProvider(request.itemId));
  }

  RentRequestDetail? _resolveRequest(RentRequestDetail? fromProvider) {
    if (fromProvider != null) return fromProvider;
    if (widget.rentRequest != null && _requestId == widget.requestId) {
      return widget.rentRequest;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
        : const AsyncData<RentRequestDetail?>(null);

    if (_requestId != null &&
        asyncRequest.hasValue &&
        asyncRequest.value == null) {
      final navigator = Navigator.of(context);
      Future.microtask(() {
        if (mounted) navigator.pop();
      });
    }

    final request = _resolveRequest(asyncRequest.value);
    final userId = asyncUser.value?.id;
    final isOwner = userId != null && request?.ownerId == userId;
    final isRequester = userId != null && request?.requester.id == userId;
    final messages = asyncRequest.value?.messages ?? [];
    final offers = asyncRequest.value?.offers ?? [];

    final hasAcceptedOffer = request?.latestAcceptedOfferId != null;
    final isBorrowed = request?.borrowConfirmedAt != null;
    final isReturned = request?.returnedAt != null;

    final title = request?.itemTitle ?? 'Neue Anfrage';

    if (!_didInitialScroll && _requestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryScrollToBottom());
    }

    if (_requestId != null &&
        asyncRequest.hasValue &&
        asyncRequest.value != null &&
        messages.length > _lastMessageCount) {
      _lastMessageCount = messages.length;
      Future.microtask(() {
        markRentRequestRead(_requestId!).then((_) {
          ref.invalidate(myRentRequestsProvider);
        });
      });
    }

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
            child: Stack(
              children: [
                _buildChatList(
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
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ),
              ],
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onCreateOffer:
                (isOwner || isRequester) && !isReturned ? _createOffer : null,
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
    RentRequestDetail? request,
    bool hasAcceptedOffer,
    bool isBorrowed,
    bool isReturned,
  ) {
    final chatItems = <_ChatItem>[
      for (final m in messages) _ChatItem.message(m),
      for (final o in offers) _ChatItem.offer(o),
      if (request?.borrowConfirmedAt != null)
        _ChatItem.system('Ausleihe bestätigt',
            createdAt: request!.borrowConfirmedAt!),
      if (request?.returnedAt != null)
        _ChatItem.system('Rückgabe bestätigt', createdAt: request!.returnedAt!),
    ];
    chatItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int actionCount = 0;
    if (isOwner && !isReturned && !isBorrowed && hasAcceptedOffer) {
      actionCount++;
    }
    if (isOwner && !isReturned && isBorrowed) {
      actionCount++;
    }
    final canRateUser = request != null &&
        isReturned &&
        request.myUserRating == null &&
        (isOwner || isRequester);
    final canRateItem = request != null &&
        isReturned &&
        isRequester &&
        request.myItemRating == null;
    if (canRateUser) {
      actionCount++;
    }
    if (canRateItem) {
      actionCount++;
    }

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
          offset--;
        }
        if (canRateUser) {
          if (offset == 0) {
            final revieweeName =
                isOwner ? request.requester.name : request.ownerName;
            return _SystemActionCard(
              icon: Icons.star_border,
              title: '$revieweeName bewerten',
              onTap: () => _showUserRatingDialog(request, isOwner),
            );
          }
          offset--;
        }
        if (canRateItem && offset == 0) {
          return _SystemActionCard(
            icon: Icons.star_border,
            title: '${request.itemTitle} bewerten',
            onTap: () => _showItemRatingDialog(request),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

String _formatDateSimple(DateTime dt) {
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _formatMessageTime(DateTime dt) {
  final local = dt.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final msgDate = DateTime(local.year, local.month, local.day);
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  if (msgDate == today) return time;
  if (msgDate == yesterday) return 'Gestern $time';
  const wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  if (msgDate.isAfter(today.subtract(const Duration(days: 7)))) {
    return '${wd[local.weekday - 1]} $time';
  }
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}. $time';
}

String _statusText(RentRequestDetail req) {
  if (req.returnedAt != null) return 'Abgeschlossen · Rückgabe bestätigt';
  if (req.borrowConfirmedAt != null) return 'Ausgeliehen · Rückgabe ausstehend';
  if (req.latestAcceptedOfferId != null) {
    return 'Angebot akzeptiert · Ausleihe bestätigen';
  }
  if (req.latestOpenOfferId != null) return 'Angebot erhalten';
  return 'Ausstehend';
}

IconData _statusIcon(RentRequestDetail req) {
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
  final RentRequestDetail request;
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
          Expanded(
              child:
                  Text(statusText, style: TextStyle(color: Colors.blue[700]))),
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
    final startStr = _formatDateSimple(offer.startDate);
    final endStr = _formatDateSimple(offer.endDate);

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

class _RatingStars extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  const _RatingStars({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${value ?? 0}/5'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  constraints:
                      const BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                  tooltip: '$star Sterne',
                  onPressed: () => onChanged(star),
                  icon: Icon(
                    value != null && star <= value!
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber[700],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SystemActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
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
                      if (subtitle != null)
                        Text(
                          subtitle!,
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
    final ts = _formatMessageTime(createdAt);
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
              ts,
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
              _formatMessageTime(message.createdAt),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
