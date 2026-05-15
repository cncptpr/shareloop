import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/item_widget.dart';
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
    final manual = ref.watch(selectedLocationProvider);
    if (manual != null) return manual.name;

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
  }

  @override
  Widget build(BuildContext context) {
    final label = _locationLabel(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Screen'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const LocationPickerScreen(),
                )),
            icon: const Icon(Icons.location_on),
            label: Text(label),
          ),
        ],
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: LayoutBuilder(
                  builder: (ctx, constraints) => Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth),
                      child: Consumer(builder: (ctx, ref, _) {
                        final itemsAsync = ref.watch(featuredItemsProvider);
                        return itemsAsync.when(
                          skipLoadingOnReload: true,
                          data: (items) => Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            ),
                            ...items.map((item) => ItemWidget(item)),
                          ]),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) =>
                              Center(child: Text('Error: $e')),
                        );
                      }),
                    ),
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
