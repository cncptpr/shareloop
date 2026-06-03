import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/item_widget.dart';
import 'package:shareloop/screens/create_item_screen.dart';
import 'package:shareloop/screens/location_picker_screen.dart';
import 'package:shareloop/state/items.dart';
import 'package:shareloop/state/location.dart';
import 'package:shareloop/state/location_search.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String searchText = "";

  String _locationLabel(WidgetRef ref) {
    final selected = ref.watch(selectedLocationProvider);
    switch (selected) {
      case SearchedLocation manual:
        return manual.name;
      case GPSLocation _:
        final gps = ref.watch(currentPositionProvider).asData?.value;
        if (gps == null) return 'Position wählen';
        final reverse = ref.watch(
          reverseLocationProvider((gps.latitude, gps.longitude)),
        );
        return reverse.when(
          data: (loc) => loc?.name ?? 'Aktuelle Position',
          loading: () => 'Aktuelle Position',
          error: (_, __) => 'Aktuelle Position',
        );
      default:
        return 'Position wählen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _locationLabel(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Screen'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LocationPickerScreen(),
                )),
            icon: const Icon(Icons.location_on),
            label: Text(label),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateItemScreen.push(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SearchBar(
            hintText: "Suche für Inserate",
            onChanged: (value) => setState(() {
              searchText = value;
            }),
          ),
          if (searchText != "") Text("Du suchst nach '$searchText'"),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(featuredItemsProvider);
                await ref.read(featuredItemsProvider.future);
              },
              child: LayoutBuilder(
                builder: (ctx, constraints) => Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: constraints.maxWidth),
                    child: Consumer(builder: (ctx, ref, _) {
                      final itemsAsync = ref.watch(featuredItemsProvider);
                      return itemsAsync.when(
                        skipLoadingOnReload: true,
                        data: (items) => ListView.builder(
                          cacheExtent: 500,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length + 1,
                          itemBuilder: (ctx, i) {
                            if (i == 0) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Featured Items",
                                    textScaler: TextScaler.linear(2),
                                  ),
                                  TextButton(
                                    child: const Row(
                                      children: [
                                        Text("View all"),
                                        Icon(Icons.arrow_right_alt),
                                      ],
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              );
                            }
                            return ItemWidget(items[i - 1]);
                          },
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
