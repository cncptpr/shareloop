import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/components/item_widget.dart';
import 'package:shareloop/screens/create_item_screen.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/state/item_search.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart';
import 'package:shareloop/state/location_search.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _locationLabel(WidgetRef ref) {
    final selected = ref.watch(selectedLocationProvider);
    String formatLabel(SearchedLocation l) {
      final parts = [l.postalCode, l.city]..removeWhere((s) => s.isEmpty);
      return parts.isEmpty ? l.name : parts.join(' ');
    }
    switch (selected) {
      case SearchedLocation manual:
        return formatLabel(manual);
      case GPSLocation _:
        final gps = ref.watch(currentPositionProvider).asData?.value;
        if (gps == null) return 'Position wählen';
        final reverse = ref.watch(
          reverseLocationProvider((gps.latitude, gps.longitude)),
        );
        return reverse.when(
          data: (loc) => loc != null ? formatLabel(loc) : 'Aktuelle Position',
          loading: () => 'Aktuelle Position',
          error: (_, __) => 'Aktuelle Position',
        );
      default:
        return 'Position wählen';
    }
  }

  Future<void> _openLocationPicker() async {
    final current = ref.read(selectedLocationProvider);
    final result = await Navigator.push<SelectedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLocation: current),
      ),
    );
    if (result != null && mounted) {
      ref.read(selectedLocationProvider.notifier).select(result);
    } else if (mounted) {
      ref.read(selectedLocationProvider.notifier).clear();
    }
  }

  bool _hasActiveFilters(SearchFilters f) {
    return f.query.isNotEmpty ||
        f.categories.isNotEmpty ||
        f.maxDistanceKm != null ||
        f.minScore != null ||
        f.sortBy != ItemSearchRequestSortByEnum.relevance;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchFiltersProvider.notifier).setQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final label = _locationLabel(ref);
    final filters = ref.watch(searchFiltersProvider);
    final hasFilters = _hasActiveFilters(filters);

    final itemsAsync = hasFilters
        ? ref.watch(searchItemsProvider)
        : ref.watch(featuredItemsProvider);
    final featuredAsync = ref.watch(featuredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('ShareLoop'),
        actions: [
          TextButton.icon(
            onPressed: _openLocationPicker,
            icon: const Icon(Icons.location_on),
            label: Text(label),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateItemScreen.push(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (hasFilters) {
            ref.invalidate(searchItemsProvider);
            await ref.read(searchItemsProvider.future);
          } else {
            ref.invalidate(featuredItemsProvider);
            await ref.read(featuredItemsProvider.future);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SearchBar(
                  hintText: 'Suche für Inserate',
                  controller: _searchController,
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(cs.surfaceContainerHigh),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),

            if (itemsAsync.isLoading || itemsAsync.isReloading)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _ActiveFilterChip(
                      active: filters.maxDistanceKm != null,
                      label: filters.maxDistanceKm != null
                          ? '≤${filters.maxDistanceKm!.toInt()} km'
                          : 'Entfernung',
                      icon: Icons.explore,
                      onClear: filters.maxDistanceKm != null
                          ? () => ref.read(searchFiltersProvider.notifier).setMaxDistanceKm(null)
                          : null,
                      childBuilder: () => PopupMenuButton<double>(
                        onSelected: (v) {
                          ref.read(searchFiltersProvider.notifier).setMaxDistanceKm(v);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 1,
                            child: ListTile(
                              leading: Icon(Icons.directions_walk, size: 20),
                              title: Text('1 km'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 5,
                            child: ListTile(
                              leading: Icon(Icons.directions_bike, size: 20),
                              title: Text('5 km'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 10,
                            child: ListTile(
                              leading: Icon(Icons.directions_car, size: 20),
                              title: Text('10 km'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 25,
                            child: ListTile(
                              leading: Icon(Icons.directions_car, size: 20),
                              title: Text('25 km'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 50,
                            child: ListTile(
                              leading: Icon(Icons.flight, size: 20),
                              title: Text('50 km'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        child: const Chip(
                          label: Text('Entfernung'),
                          avatar: Icon(Icons.explore, size: 16),
                        ),
                      ),
                    ),
                    _ActiveFilterChip(
                      active: filters.minScore != null,
                      label: filters.minScore != null
                          ? '≥${filters.minScore}★'
                          : 'Mindestbewertung',
                      icon: Icons.star,
                      onClear: filters.minScore != null
                          ? () => ref.read(searchFiltersProvider.notifier).setMinScore(null)
                          : null,
                      childBuilder: () => PopupMenuButton<double>(
                        onSelected: (v) {
                          ref.read(searchFiltersProvider.notifier).setMinScore(v);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 3,
                            child: ListTile(
                              leading: Icon(Icons.star_half, size: 20, color: Colors.amber),
                              title: Text('3★ und mehr'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 3.5,
                            child: ListTile(
                              leading: Icon(Icons.star_half, size: 20, color: Colors.amber),
                              title: Text('3.5★ und mehr'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 4,
                            child: ListTile(
                              leading: Icon(Icons.star, size: 20, color: Colors.amber),
                              title: Text('4★ und mehr'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 4.5,
                            child: ListTile(
                              leading: Icon(Icons.star, size: 20, color: Colors.amber),
                              title: Text('4.5★ und mehr'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        child: const Chip(
                          label: Text('Mindestbewertung'),
                          avatar: Icon(Icons.star, size: 16),
                        ),
                      ),
                    ),
                    PopupMenuButton<ItemSearchRequestSortByEnum>(
                      onSelected: (v) {
                        ref.read(searchFiltersProvider.notifier).setSortBy(v);
                      },
                      itemBuilder: (_) {
                        final cur = filters.sortBy;
                        return [
                          PopupMenuItem(
                            value: ItemSearchRequestSortByEnum.relevance,
                            child: ListTile(
                              leading: const Icon(Icons.trending_up, size: 20),
                              title: const Text('Beste Treffer'),
                              trailing: cur == ItemSearchRequestSortByEnum.relevance
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: ItemSearchRequestSortByEnum.score,
                            child: ListTile(
                              leading: const Icon(Icons.star, size: 20, color: Colors.amber),
                              title: const Text('Bewertung'),
                              trailing: cur == ItemSearchRequestSortByEnum.score
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: ItemSearchRequestSortByEnum.distance,
                            child: ListTile(
                              leading: const Icon(Icons.near_me, size: 20),
                              title: const Text('Entfernung'),
                              trailing: cur == ItemSearchRequestSortByEnum.distance
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: ItemSearchRequestSortByEnum.newest,
                            child: ListTile(
                              leading: const Icon(Icons.schedule, size: 20),
                              title: const Text('Neueste'),
                              trailing: cur == ItemSearchRequestSortByEnum.newest
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ];
                      },
                      child: Chip(
                        label: Text(_sortLabel(filters.sortBy)),
                        avatar: const Icon(Icons.sort, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text('Entdecke Kategorien', style: tt.titleLarge),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildCategoryBento(filters, ref),
              ),
            ),

            if (!hasFilters) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Empfohlene Artikel', style: tt.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Alle anzeigen'),
                      ),
                    ],
                  ),
                ),
              ),
              featuredAsync.when(
                data: (items) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: 280,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) => _FeaturedItemCard(items[i]),
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('In deiner Nähe', style: tt.titleLarge),
                    ],
                  ),
                ),
              ),
            ],

            if (hasFilters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Deine Auswahl', style: tt.titleLarge),
                ),
              ),

            itemsAsync.when(
              skipLoadingOnReload: true,
              data: (items) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ItemWidget(items[i], key: ValueKey(items[i].id)),
                    childCount: items.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Fehler: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBento(SearchFilters filters, WidgetRef ref) {
    _CategoryTile catTile(String name, IconData icon, {String? forcedImage}) {
      final active = filters.categories.contains(name);
      return _CategoryTile(
        icon: icon,
        label: name,
        active: active,
        imageUrl: forcedImage ?? _categoryImageUrls[name],
        onTap: () => ref.read(searchFiltersProvider.notifier).toggleCategory(name),
      );
    }

    _CategoryTile catEntry(String name) {
      final entry = _categoryIcons.firstWhere((e) => e.key == name);
      return catTile(entry.key, entry.value);
    }

    return Column(
      children: [
        _buildBentoRow(
          left: catEntry('Werkzeug'),
          right: Column(
            children: [
              Expanded(child: catEntry('Elektronik')),
              const SizedBox(height: 8),
              Expanded(child: catEntry('Sport')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildBentoRow(
          left: Column(
            children: [
              Expanded(child: catEntry('Bücher')),
              const SizedBox(height: 8),
              Expanded(child: catEntry('Sonstiges')),
            ],
          ),
          right: catEntry('Outdoor'),
        ),
      ],
    );
  }

  Widget _buildBentoRow({
    required Widget left,
    required Widget right,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = ((constraints.maxWidth - 8) / 2).clamp(0.0, double.infinity);
        return SizedBox(
          height: tileWidth,
          child: Row(
            children: [
              SizedBox(width: tileWidth, child: left),
              const SizedBox(width: 8),
              SizedBox(width: tileWidth, child: right),
            ],
          ),
        );
      },
    );
  }

  static const _categoryIcons = <MapEntry<String, IconData>>[
    MapEntry('Elektronik', Icons.devices),
    MapEntry('Werkzeug', Icons.build),
    MapEntry('Sport', Icons.fitness_center),
    MapEntry('Bücher', Icons.menu_book),
    MapEntry('Outdoor', Icons.kayaking),
    MapEntry('Sonstiges', Icons.category),
  ];

  static const _categoryImageUrls = <String, String>{
    'Werkzeug':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAEs4r8ImdNw86kvr3MxaKr2tSiASZMae2ft_fW44Lgnb18N5ew0eNoFCm1HbPr7-o5RdyKw6-zmMugFP7tZ6PV--x5hQBDb72ZpZY5FWpK4uuzf22DTDzJq4CRHh70nn8nUm4SPY_OpzTtriXzHfj0H0YyafvLYuc_yg2Brvr7dJXBLFk7aZfZCsZQZbJ-x_eSkn6BIXW3lLTX0oYfdXTUIjCukLwQ2qrwhiGW5NziCnQq6LTi4IWbJHwbYO7M7eRVOfnBb5axCoW',
    'Outdoor':
        'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    'Elektronik':
        'https://images.unsplash.com/photo-1776090893591-90f5ea3fa523?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    'Sport':
        'https://images.unsplash.com/photo-1764595753275-d9278a0b8f56?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    'Bücher':
        'https://images.unsplash.com/photo-1739015828099-29531aa4bd1a?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    'Sonstiges':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBl4itt0NFbkkuFV5EYUkakoB6BObwmfF2JWpI4R4zh97Tg1w2IvpNuRSjUXA7YqK3z_97Gtus50CovW-dVyehwbf_Kp3NsegS0rg8NLRmsd06e2-KVVIBFPcUf26sZlyzylNcsgY5sOvENpOztDjS1qcM2FmRTnOgwnV2EJK4wZzZej8qWKqrNsB9lEeOnrDftUOTKLHEqyUQOxziXJXlGVRRMkBb1FSyWVErIeZiAwD1ePMC0Ba5BmJe5Scz6XaHsy_QJNwETEClP',
  };

  String _sortLabel(ItemSearchRequestSortByEnum sortBy) {
    if (sortBy == ItemSearchRequestSortByEnum.relevance) return 'Beste Treffer';
    if (sortBy == ItemSearchRequestSortByEnum.distance) return 'Entfernung';
    if (sortBy == ItemSearchRequestSortByEnum.newest) return 'Neueste';
    return 'Bewertung';
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback? onClear;
  final Widget Function() childBuilder;

  const _ActiveFilterChip({
    required this.active,
    required this.label,
    required this.icon,
    this.onClear,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (active) {
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        padding: const EdgeInsets.only(left: 4, right: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ),
          ],
        ),
      );
    }
    return childBuilder();
  }
}

class _FeaturedItemCard extends ConsumerWidget {
  final ItemOverview item;

  const _FeaturedItemCard(this.item);

  @override
  Widget build(BuildContext context, ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemScreen(itemId: item.id)),
      ),
      child: SizedBox(
        width: 180,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: item.imageUuid != null
                    ? Image.network(
                        '${AppConfig.apiBaseUrl}/images/${item.imageUuid}',
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/placeholder_image.jpg",
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(text: item.title, style: tt.titleSmall),
                          TextSpan(
                            text: ' · von ${item.author.name}',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(item.score.toStringAsFixed(1), style: tt.labelSmall),
                        const Spacer(),
                        if (item.distance != null) ...[
                          Icon(Icons.location_on, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            '${item.distance!.km.toStringAsFixed(0)} km',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                        if (item.distance != null && item.city != null)
                          Text(
                            ' · ',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        if (item.city != null)
                          Flexible(
                            child: Text(
                              item.city!,
                              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String? imageUrl;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.active,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: imageUrl != null ? _buildImageTile(cs, tt) : _buildColorTile(cs, tt),
      ),
    );
  }

  Widget _buildImageTile(ColorScheme cs, TextTheme tt) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildColorTile(cs, tt),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              ),
            ),
          ),
        ),
        if (active)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: cs.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorTile(ColorScheme cs, TextTheme tt) {
    return Container(
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: active ? cs.onPrimary : cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: tt.titleMedium?.copyWith(
              color: active ? cs.onPrimary : cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
