// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/item_detail.dart';
import 'package:shareloop/screens/rating_dialogs.dart';
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
  late final WebSocketService _webSocketService;
  int? _requestId;
  bool _creatingRequest = false;
  bool _showScrollToBottom = false;
  bool _didInitialScroll = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _requestId = widget.requestId;
    _webSocketService = ref.read(webSocketProvider);
    _scrollController.addListener(_onScrollChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestId != null && mounted) {
      _webSocketService.currentChatRequestId = _requestId;
    }
  }

  @override
  void dispose() {
    _webSocketService.currentChatRequestId = null;
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
      if (request != null && context.mounted) {
        setState(() => _requestId = request.id);
        _webSocketService.currentChatRequestId = request.id;
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
    if (!context.mounted) return;
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
    if (!context.mounted) return;
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
    if (!context.mounted) return;
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
                  color: Theme.of(ctx).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(ctx).colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum beginnt erst am '
                        '${_formatDateSimple(acceptedOffer.startDate)}.',
                        style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onTertiaryContainer,
                        ),
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
    if (!context.mounted) return;
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
                  color: Theme.of(ctx).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(ctx).colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Der vereinbarte Ausleihzeitraum endet erst am '
                        '${_formatDateSimple(acceptedOffer.endDate)}.',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.onTertiaryContainer,
                          fontSize: 13,
                        ),
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
    if (!context.mounted) return;
    ref.invalidate(rentRequestProvider(_requestId!));
    ref.invalidate(myRentRequestsProvider);
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
      if (prevId != null && prevId != nextId && _requestId != null && context.mounted) {
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
          if (mounted && context.mounted) {
            ref.invalidate(myRentRequestsProvider);
          }
        });
      });
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final personName = request != null
        ? (isOwner ? request.requester.name : request.ownerName)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (request != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    personName.isNotEmpty ? personName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(personName.isNotEmpty ? personName : title,
                      style: tt.titleMedium),
                  if (request != null)
                    Text(
                      request.itemTitle,
                      style: tt.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
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
    final sorted = <_ChatItem>[
      for (final m in messages) _ChatItem.message(m),
      for (final o in offers) _ChatItem.offer(o),
      if (request?.borrowConfirmedAt != null)
        _ChatItem.system('Ausleihe bestätigt',
            createdAt: request!.borrowConfirmedAt!),
      if (request?.returnedAt != null)
        _ChatItem.system('Rückgabe bestätigt', createdAt: request!.returnedAt!),
    ];
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final items = <_ListEntry>[];
    DateTime? lastDate;
    for (final item in sorted) {
      final d = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      if (lastDate == null || d != lastDate) {
        items.add(_ListEntry.divider(d));
        lastDate = d;
      }
      items.add(_ListEntry.chat(item));
    }

    final canRateUser = request != null &&
        isReturned &&
        request.myUserRating == null &&
        (isOwner || isRequester);
    final canRateItem = request != null &&
        isReturned &&
        isRequester &&
        request.myItemRating == null;

    if (isOwner && !isReturned && !isBorrowed && hasAcceptedOffer) {
      items.add(_ListEntry.action(
        Icons.check_circle_outline,
        'Ausleihe bestätigen',
        subtitle: 'Bestätige, dass der Artikel übergeben wurde',
        onTap: _confirmBorrow,
      ));
    }
    if (isOwner && !isReturned && isBorrowed) {
      items.add(_ListEntry.action(
        Icons.replay,
        'Rückgabe bestätigen',
        subtitle: 'Bestätige, dass der Artikel zurückgegeben wurde',
        onTap: _confirmReturn,
      ));
    }
    if (canRateUser) {
      final revieweeName = isOwner ? request.requester.name : request.ownerName;
      items.add(_ListEntry.action(
        Icons.star_border,
        '$revieweeName bewerten',
        onTap: () => showUserRatingDialog(context, ref, _requestId!, request, isOwner),
      ));
    }
    if (canRateItem) {
      items.add(_ListEntry.action(
        Icons.star_border,
        '${request.itemTitle} bewerten',
        onTap: () => showItemRatingDialog(context, ref, _requestId!, request),
      ));
    }
    if (request != null && request.myUserRating != null) {
      final revieweeName = isOwner ? request.requester.name : request.ownerName;
      items.add(_ListEntry.rated('$revieweeName bewertet'));
    }
    if (request != null && request.myItemRating != null) {
      items.add(_ListEntry.rated('${request.itemTitle} bewertet'));
    }

    if (items.isEmpty && _requestId == null) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Schreibe eine Nachricht,\num die Anfrage zu starten.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final entry = items[i];
        switch (entry.type) {
          case _ListEntryType.divider:
            return _DateDivider(date: entry.date!);
          case _ListEntryType.chatItem:
            final item = entry.chatItem!;
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
                return _OfferCard(
                  offer: offer,
                  isMyOffer: isMyOffer,
                  isAccepted: isAccepted,
                  canConfirm: !isMyOffer && isLatestOpen,
                  onConfirm: () => _acceptOffer(offer.id),
                  onReschedule: !isMyOffer && isLatestOpen ? _createOffer : null,
                  itemId: request!.itemId,
                );
              case _ChatItemType.system:
                return _SystemNoteBubble(
                  text: item.systemText!,
                  createdAt: item.createdAt,
                );
            }
          case _ListEntryType.actionCard:
            final a = entry.action!;
            return _SystemActionCard(
              icon: a.icon,
              title: a.title,
              subtitle: a.subtitle,
              onTap: a.onTap,
            );
          case _ListEntryType.rated:
            return _RatedStatus(text: entry.ratedText!);
        }
      },
    );
  }
}

String _formatDateSimple(DateTime dt) {
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _formatDateGerman(DateTime dt) {
  final d = dt.toLocal();
  const wochentage = [
    'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag',
  ];
  final wd = wochentage[d.weekday - 1];
  return '$wd ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
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

enum _ListEntryType { divider, chatItem, actionCard, rated }

class _ActionCardData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  _ActionCardData(this.icon, this.title, {this.subtitle, required this.onTap});
}

class _ListEntry {
  final _ListEntryType type;
  final DateTime? date;
  final _ChatItem? chatItem;
  final _ActionCardData? action;
  final String? ratedText;

  _ListEntry.divider(this.date)
      : type = _ListEntryType.divider,
        chatItem = null,
        action = null,
        ratedText = null;

  _ListEntry.chat(this.chatItem)
      : type = _ListEntryType.chatItem,
        date = null,
        action = null,
        ratedText = null;

  _ListEntry.action(IconData icon, String title, {String? subtitle, required VoidCallback onTap})
      : type = _ListEntryType.actionCard,
        date = null,
        chatItem = null,
        action = _ActionCardData(icon, title, subtitle: subtitle, onTap: onTap),
        ratedText = null;

  _ListEntry.rated(this.ratedText)
      : type = _ListEntryType.rated,
        date = null,
        chatItem = null,
        action = null;
}

class _RatedStatus extends StatelessWidget {
  final String text;
  const _RatedStatus({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: cs.primary, size: 18),
          const SizedBox(width: 6),
          Text(text, style: tt.bodyMedium?.copyWith(color: cs.primary)),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDateGerman(date),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final RentRequestDetail request;
  final bool isOwner;

  const _StatusBanner({required this.request, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(request);
    final icon = _statusIcon(request);

    final cs = Theme.of(context).colorScheme;
    final color = _statusBannerColor(request, cs);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
              child: Text(statusText, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}

Color _statusBannerColor(RentRequestDetail req, ColorScheme cs) {
  if (req.returnedAt != null) return const Color(0xFF2E7D32);
  if (req.borrowConfirmedAt != null) return cs.secondary;
  if (req.latestAcceptedOfferId != null) return cs.primary;
  if (req.latestOpenOfferId != null) return cs.tertiary;
  return cs.outline;
}

class _OfferCard extends ConsumerWidget {
  final RentOffer offer;
  final bool isMyOffer;
  final bool isAccepted;
  final bool canConfirm;
  final VoidCallback onConfirm;
  final VoidCallback? onReschedule;
  final int itemId;

  const _OfferCard({
    required this.offer,
    required this.isMyOffer,
    required this.isAccepted,
    required this.canConfirm,
    required this.onConfirm,
    this.onReschedule,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final asyncDetail = ref.watch(itemDetailProvider(itemId));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 100,
                child: _buildThumbnail(asyncDetail, cs),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    asyncDetail.value?.title ?? '',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'von ${_formatDateGerman(offer.startDate)}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    'bis ${_formatDateGerman(offer.endDate)}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (isAccepted) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: cs.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Buchung akzeptiert',
                          style: tt.bodyMedium?.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                  ] else if (!isMyOffer) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: canConfirm ? onConfirm : null,
                            child: const Text('Buchung bestätigen'),
                          ),
                        ),
                        if (onReschedule != null) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: onReschedule,
                            child: const Text('Verschieben'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(AsyncValue<ItemDetail> asyncDetail, ColorScheme cs) {
    final detail = asyncDetail.value;
    final uuids = detail?.imageUuids;
    if (uuids != null && uuids.isNotEmpty) {
      return Image.network(
        '${AppConfig.apiBaseUrl}/images/${uuids.first}',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(cs),
      );
    }
    return _imagePlaceholder(cs);
  }

  Widget _imagePlaceholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHigh,
      child: Icon(Icons.image, color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.chevron_right, size: 20, color: cs.outline),
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
    final cs = Theme.of(context).colorScheme;
    final ts = _formatMessageTime(createdAt);
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
              Text(
                text,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ts,
                style: TextStyle(fontSize: 11, color: cs.outline),
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
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              message.content,
              style: TextStyle(color: isMe ? cs.onPrimary : null),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _formatMessageTime(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (onCreateOffer != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: cs.primary),
                  tooltip: 'Angebot erstellen',
                  onPressed: onCreateOffer,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nachricht schreiben...',
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: cs.onPrimary, size: 20),
                onPressed: onSend,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
