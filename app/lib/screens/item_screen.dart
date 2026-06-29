// See docs/item-edit-create-flow.md (edit flow) and docs/rent-request-chat-flow.md (rent request flow).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/edit_item_screen.dart';
import 'package:shareloop/screens/login_screen.dart';
import 'package:shareloop/screens/rent_request_chat_screen.dart';
import 'package:shareloop/state/auth.dart' show authProvider;
import 'package:shareloop/state/item_detail.dart';

class ItemScreen extends ConsumerWidget {
  final int itemId;

  const ItemScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItem = ref.watch(itemDetailProvider(itemId));
    final asyncUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (asyncItem.hasValue &&
              asyncUser.hasValue &&
              asyncUser.value != null &&
              asyncItem.value!.author.id == asyncUser.value!.id)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result =
                    await EditItemScreen.push(context, asyncItem.value!.id);
                if (result == true) {
                  ref.invalidate(itemDetailProvider(itemId));
                }
              },
            ),
        ],
      ),
      body: asyncItem.when(
        data: (item) => _Content(
          item: item,
          userId: asyncUser.hasValue ? asyncUser.value?.id : null,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ItemDetail item;
  final int? userId;

  const _Content({required this.item, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isOwnItem = userId != null && item.author.id == userId;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageGallery(imageUuids: item.imageUuids),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(item.description),
                const SizedBox(height: 16),
                _ProfileCard(author: item.author),
                const SizedBox(height: 16),
                if (item.city != null || item.postalCode != null)
                  Row(children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 4),
                    Text([item.postalCode, item.city].nonNulls.join(' ')),
                  ]),
                const SizedBox(height: 8),
                Text(
                  item.category,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                if (!isOwnItem) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (userId == null) {
                          LoginScreen.push(context);
                          return;
                        }
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RentRequestChatScreen.newRequest(
                                itemId: item.id,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Anfragen'),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _ItemRatingsSection(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRatingsSection extends StatelessWidget {
  final ItemDetail item;

  const _ItemRatingsSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bewertungen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (item.itemRatingCount > 0) ...[
              Icon(Icons.star, size: 20, color: Colors.amber[700]),
              const SizedBox(width: 4),
              Text(
                '${item.score.toStringAsFixed(1)} (${item.itemRatingCount})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (item.itemRatings.isEmpty)
          const Row(
            children: [
              Icon(Icons.star_border, color: Colors.grey),
              SizedBox(width: 8),
              Text('Noch keine Bewertungen'),
            ],
          )
        else
          for (var index = 0; index < item.itemRatings.length; index++) ...[
            _ItemRatingEntry(rating: item.itemRatings[index]),
            if (index < item.itemRatings.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),
          ],
      ],
    );
  }
}

class _ItemRatingEntry extends StatelessWidget {
  final ItemRating rating;

  const _ItemRatingEntry({required this.rating});

  @override
  Widget build(BuildContext context) {
    final comment = rating.comment?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(
                rating.reviewer.name.isNotEmpty
                    ? rating.reviewer.name[0].toUpperCase()
                    : '?',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating.reviewer.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    MaterialLocalizations.of(context)
                        .formatShortDate(rating.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _ReadOnlyStars(value: rating.overall),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _RatingMetric(label: 'Zustand', value: rating.condition),
            _RatingMetric(
              label: 'Sauberkeit',
              value: rating.cleanliness,
            ),
          ],
        ),
        if (comment != null && comment.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(comment),
        ],
      ],
    );
  }
}

class _ReadOnlyStars extends StatelessWidget {
  final double value;

  const _ReadOnlyStars({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= value.round() ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber[700],
          ),
      ],
    );
  }
}

class _RatingMetric extends StatelessWidget {
  final String label;
  final int value;

  const _RatingMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        Icon(Icons.star, size: 16, color: Colors.amber[700]),
        const SizedBox(width: 2),
        Text('$value'),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> imageUuids;

  const _ImageGallery({required this.imageUuids});

  @override
  Widget build(BuildContext context) {
    if (imageUuids.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.image, size: 64, color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: imageUuids.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final uuid = imageUuids[i];
          return GestureDetector(
            onTap: () => _openFullscreen(context, initialIndex: i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                '${AppConfig.apiBaseUrl}/images/$uuid',
                height: 284,
                width: 284,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFullscreen(BuildContext context, {required int initialIndex}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(
          imageUuids: imageUuids,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> imageUuids;
  final int initialIndex;

  const _FullscreenGallery({
    required this.imageUuids,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUuids.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: widget.imageUuids.map((uuid) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                '${AppConfig.apiBaseUrl}/images/$uuid',
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Person author;

  const _ProfileCard({required this.author});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child:
              Text(author.name.isNotEmpty ? author.name[0].toUpperCase() : '?'),
        ),
        title: Text(author.name),
      ),
    );
  }
}
