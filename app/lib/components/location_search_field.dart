import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/state/location_search.dart';

class LocationSearchField extends ConsumerStatefulWidget {
  final SelectedLocation? selectedLocation;
  final ValueChanged<SearchedLocation> onLocationSelected;
  final VoidCallback? onGpsSelected;

  const LocationSearchField({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
    this.onGpsSelected,
  });

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
    _cachedResults = null;
    _activeQuery = '';
    _controller.clear();
    _focusNode.unfocus();
    await addStoredLocation(location);
    ref.invalidate(storedLocationsProvider);
    widget.onLocationSelected(location);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(),
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
        if (_activeQuery.isNotEmpty) _buildResultsView(),
        if (_activeQuery.isEmpty && _controller.text.isEmpty)
          _buildDefaultView(),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: 'Search city or postal code...',
        prefixIcon: const Icon(Icons.location_on_outlined),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller.text.isNotEmpty || _activeQuery.isNotEmpty)
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildResultsView() {
    final resultsAsync = ref.watch(locationSearchProvider(_activeQuery));
    return Column(
      children: [
        resultsAsync.when(
          skipLoadingOnReload: true,
          data: (results) {
            _cachedResults = results;
            return const SizedBox.shrink();
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),
          error: (e, _) {
            final msg = e is RateLimitException
                ? 'Rate limit reached. Try again in a moment.'
                : 'Could not load results. Check your connection.';
            var style = Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                );
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                msg,
                style: style,
              ),
            );
          },
        ),
        _buildResultsList(_cachedResults),
      ],
    );
  }

  Widget _buildResultsList(
    List<SearchedLocation>? results,
  ) {
    if (results == null) {
      return const SizedBox.shrink();
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'No results found.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Column(
      children: results
          .map(
            (loc) => _SuggestionTile(
              leading: const Icon(Icons.location_city),
              title: loc.name,
              subtitle: loc.displayName,
              onTap: () => _selectLocation(loc),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDefaultView() {
    final storedAsync = ref.watch(storedLocationsProvider);
    final selected = widget.selectedLocation;
    final recentTitle = Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Text(
        'Recent',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );

    return storedAsync.when(
      data: (stored) {
        if (stored.isEmpty && selected == null) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            _gpsTile(),
            if (stored.isNotEmpty) recentTitle,
            ...stored.map(
              (loc) => _SuggestionTile(
                leading: Icon(
                  selected is SearchedLocation &&
                          loc.lat == selected.lat &&
                          loc.lng == selected.lng
                      ? Icons.check_circle
                      : Icons.history,
                ),
                title: loc.name,
                subtitle: loc.displayName,
                onTap: () => _selectLocation(loc),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => removeStoredLocation(loc).then((_) {
                    ref.invalidate(storedLocationsProvider);
                  }),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _gpsTile() {
    final canUseGps = !Platform.isLinux && !Platform.isWindows;
    if (!canUseGps) {
      return _SuggestionTile(
        leading: const Icon(Icons.my_location),
        title: 'Aktuellen Standort verwenden',
        subtitle: 'GPS auf diesem Gerät nicht verfügbar',
        onTap: null,
        enabled: false,
      );
    }

    return _SuggestionTile(
      leading: const Icon(Icons.my_location),
      title: 'Aktuellen Standort verwenden',
      subtitle: null,
      onTap: () => widget.onGpsSelected?.call(),
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
        style: enabled
            ? null
            : Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled ? null : Theme.of(context).disabledColor,
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