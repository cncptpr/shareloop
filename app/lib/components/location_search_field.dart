import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/state/location_search.dart';

class LocationSearchField extends ConsumerStatefulWidget {
  final VoidCallback? onSelected;

  const LocationSearchField({super.key, this.onSelected});

  @override
  ConsumerState<LocationSearchField> createState() =>
      _LocationSearchFieldState();
}

class _LocationSearchFieldState extends ConsumerState<LocationSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _activeQuery = '';
  List<SearchedLocation>? _cachedResults;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search() {
    final query = _controller.text.trim();
    if (query.length < 2) return;
    ref.invalidate(locationSearchProvider(query));
    setState(() => _activeQuery = query);
  }

  Future<void> _selectLocation(SearchedLocation location) async {
    await ref.read(selectedLocationProvider.notifier).select(location);
    ref.invalidate(storedLocationsProvider);
    _cachedResults = null;
    _activeQuery = '';
    _controller.clear();
    _focusNode.unfocus();
    widget.onSelected?.call();
  }

  Future<void> _clearLocation() async {
    await ref.read(selectedLocationProvider.notifier).clear();
    _cachedResults = null;
    _activeQuery = '';
    _controller.clear();
    _focusNode.unfocus();
    widget.onSelected?.call();
  }

  void _reset() {
    setState(() {
      _activeQuery = '';
      _cachedResults = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(locationSearchProvider(_activeQuery));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search city or postal code...',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _reset,
                  ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
            ),
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: (_) => setState(() {}),
        ),
        if (_controller.text.isNotEmpty && _activeQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Press the search button to search for this location.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        if (_activeQuery.isNotEmpty)
          resultsAsync.when(
            skipLoadingOnReload: true,
            data: (results) {
              _cachedResults = results;
              if (results.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No results found.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return _buildResultsList(results, false);
            },
            loading: () {
              if (_cachedResults != null) {
                return _buildResultsList(_cachedResults!, true);
              }
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            },
            error: (e, _) {
              if (_cachedResults != null) {
                return _buildResultsList(_cachedResults!, false);
              }
              final msg = e is RateLimitException
                  ? 'Rate limit reached. Try again in a moment.'
                  : 'Could not load results. Check your connection.';
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  msg,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              );
            },
          ),
        if (_activeQuery.isEmpty && _controller.text.isEmpty)
          _buildDefaultView(),
      ],
    );
  }

  Widget _buildResultsList(
    List<SearchedLocation> results,
    bool isLoading,
  ) {
    return Column(
      children: [
        if (isLoading) const LinearProgressIndicator(),
        ...results.map(
          (loc) => _SuggestionTile(
            leading: const Icon(Icons.location_city),
            title: loc.name,
            subtitle: loc.displayName,
            onTap: () => _selectLocation(loc),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultView() {
    final storedAsync = ref.watch(storedLocationsProvider);
    final selected = ref.watch(selectedLocationProvider);

    return storedAsync.when(
      data: (stored) {
        if (stored.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            _gpsTile(),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                'Recent',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            ...stored.map((loc) => _SuggestionTile(
                  leading: Icon(
                    loc.lat == selected?.lat && loc.lng == selected?.lng
                        ? Icons.check_circle
                        : Icons.history,
                  ),
                  title: loc.name,
                  subtitle: loc.displayName,
                  onTap: () => _selectLocation(loc),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => _deleteStored(loc),
                  ),
                )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _deleteStored(SearchedLocation location) async {
    await removeStoredLocation(location);
    ref.invalidate(storedLocationsProvider);
  }

  Widget _gpsTile() {
    final canUseGps = !Platform.isLinux && !Platform.isWindows;
    final tile = _SuggestionTile(
      leading: Icon(Icons.my_location),
      title: 'Aktuellen Standort verwenden',
      subtitle: canUseGps ? null : 'GPS auf diesem Gerät nicht verfügbar',
      onTap: null,
      enabled: false,
    );
    if (!canUseGps) return tile;

    final selected = ref.watch(selectedLocationProvider);
    if (selected == null) return tile;

    return _SuggestionTile(
      leading: const Icon(Icons.my_location),
      title: 'Aktuellen Standort verwenden',
      subtitle: null,
      onTap: _clearLocation,
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;

  const _SuggestionTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: enabled ? null : Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).disabledColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: enabled
                    ? null
                    : Theme.of(context).disabledColor,
              ),
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
      dense: true,
    );
  }
}
