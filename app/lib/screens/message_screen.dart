// See docs/rent-request-chat-flow.md — state machine, providers, and invalidation rules.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/rent_request_chat_screen.dart';
import 'package:shareloop/state/auth.dart';
import 'package:shareloop/state/item_detail.dart';
import 'package:shareloop/state/renting.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final ValueNotifier<int> resetNotifier;

  const MessageScreen({super.key, required this.resetNotifier});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final _scrollController = ScrollController();
  bool _showClosed = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    widget.resetNotifier.addListener(_onReset);
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_onReset);
    _scrollController.dispose();
    super.dispose();
  }

  void _onReset() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(authProvider);
    final asyncRequests = ref.watch(myRentRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Posteingang'),
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
          final incoming = filtered
              .where((r) => r.ownerId == userId)
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          final outgoing = filtered
              .where((r) => r.requester.id == userId)
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                  _showClosed ? 'Keine Anfragen' : 'Keine offenen Anfragen'),
            );
          }

          final displayList = _selectedTab == 0 ? incoming : outgoing;
          final incomingUnread = incoming.fold(0, (sum, r) => sum + r.unreadCount);
          final outgoingUnread = outgoing.fold(0, (sum, r) => sum + r.unreadCount);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myRentRequestsProvider);
            },
            child: ListView(
              controller: _scrollController,
              children: [
                _TabBar(
                  selectedIndex: _selectedTab,
                  incomingUnread: incomingUnread,
                  outgoingUnread: outgoingUnread,
                  onTap: (i) => setState(() => _selectedTab = i),
                ),
                ...displayList.map((req) => _RentRequestCard(
                  request: req,
                  userId: userId,
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
                )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final int incomingUnread;
  final int outgoingUnread;
  final ValueChanged<int> onTap;

  const _TabBar({
    required this.selectedIndex,
    required this.incomingUnread,
    required this.outgoingUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTab(context, 0, 'Leihanfragen', incomingUnread)),
          Expanded(child: _buildTab(context, 1, 'Meine Anfragen', outgoingUnread)),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, String label, int unread) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: TextStyle(
                    color: cs.onTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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

class _RentRequestCard extends ConsumerWidget {
  final RentRequestOverview request;
  final int userId;
  final VoidCallback onTap;

  const _RentRequestCard({
    required this.request,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final asyncDetail = ref.watch(itemDetailProvider(request.itemId));

    final isOwner = request.ownerId == userId;
    final otherName = isOwner ? request.requester.name : request.ownerName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _nameToColor(otherName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherName,
                            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatRelativeTime(request.updatedAt),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        if (request.unreadCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${request.unreadCount}',
                              style: TextStyle(
                                color: cs.onError,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: _buildItemThumbnail(asyncDetail, cs),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  request.itemTitle,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _statusKeyword(request),
                          style: TextStyle(
                            color: _statusColor(request, cs),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemThumbnail(AsyncValue<ItemDetail> asyncDetail, ColorScheme cs) {
    final detail = asyncDetail.value;
    if (detail != null && detail.imageUuids.isNotEmpty) {
      return Image.network(
        '${AppConfig.apiBaseUrl}/images/${detail.imageUuids.first}',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _itemPlaceholder(cs),
      );
    }
    return _itemPlaceholder(cs);
  }

  Widget _itemPlaceholder(ColorScheme cs) {
    return Container(
      color: cs.surfaceContainerHigh,
      child: Icon(Icons.image, size: 16, color: cs.onSurfaceVariant),
    );
  }
}

Color _statusColor(RentRequestOverview req, ColorScheme cs) {
  if (req.returnedAt != null) return const Color(0xFF2E7D32);
  if (req.borrowConfirmedAt != null) return cs.secondary;
  if (req.latestAcceptedOfferId != null) return cs.primary;
  if (req.latestOpenOfferId != null) return cs.tertiary;
  return cs.outline;
}

String _statusKeyword(RentRequestOverview req) {
  if (req.returnedAt != null) return 'Abgeschlossen';
  if (req.borrowConfirmedAt != null) return 'Ausgeliehen';
  if (req.latestAcceptedOfferId != null) return 'Akzeptiert';
  if (req.latestOpenOfferId != null) return 'Angebot';
  return 'Ausstehend';
}

Color _nameToColor(String name) {
  final hue = name.hashCode.abs() % 360;
  return HSLColor.fromAHSL(0.35, hue.toDouble(), 0.5, 0.5).toColor();
}

String _formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final local = dt.toLocal();
  final diff = now.difference(local);

  if (diff.inDays == 0) {
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else if (diff.inDays == 1) {
    return 'Gestern';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} Tag.';
  }
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.';
}
