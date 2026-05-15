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

  void _selectLocation(SearchedLocation location) {
    ref.read(selectedLocationProvider.notifier).select(location);
    _cachedResults = null;
    _activeQuery = '';
    _controller.clear();
    _focusNode.unfocus();
    widget.onSelected?.call();
  }

  void _clearLocation() {
    ref.read(selectedLocationProvider.notifier).clear();
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
    final selected = ref.watch(selectedLocationProvider);

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
              return _buildResultsList(results, selected, false);
            },
            loading: () {
              if (_cachedResults != null) {
                return _buildResultsList(_cachedResults!, selected, true);
              }
              return const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              );
            },
            error: (e, _) {
              if (_cachedResults != null) {
                return _buildResultsList(_cachedResults!, selected, false);
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
      ],
    );
  }

  Widget _buildResultsList(
    List<SearchedLocation> results,
    SearchedLocation? selected,
    bool isLoading,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: Divider.createBorderSide(context),
          left: Divider.createBorderSide(context),
          right: Divider.createBorderSide(context),
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(8),
        ),
      ),
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          if (isLoading) const LinearProgressIndicator(),
          _gpsTile(),
          ...results.map(
            (loc) => _SuggestionTile(
              leading: const Icon(Icons.location_city),
              title: loc.name,
              subtitle: loc.displayName,
              onTap: () => _selectLocation(loc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gpsTile() {
    final canUseGps = !Platform.isLinux && !Platform.isWindows;
    final tile = _SuggestionTile(
      leading: Icon(Icons.my_location),
      title: 'Use current location',
      subtitle: canUseGps ? null : 'GPS not available on this device',
      onTap: null,
      enabled: false,
    );
    if (!canUseGps) return tile;

    final selected = ref.watch(selectedLocationProvider);
    if (selected == null) return tile;

    return _SuggestionTile(
      leading: const Icon(Icons.my_location),
      title: 'Use current location',
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

  const _SuggestionTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
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
      onTap: enabled ? onTap : null,
      enabled: enabled,
      dense: true,
    );
  }
}
