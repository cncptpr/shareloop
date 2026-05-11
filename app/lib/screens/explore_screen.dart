import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/item_widget.dart';
import 'package:shareloop/state/items.dart';

/// The search screen
class ExploreScreen extends StatefulWidget {
  /// Constructs a [ExploreScreen]
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchText = "";

  @override
  Widget build(ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Screen')),
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
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (ctx, constraints) => Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                      child: Consumer(builder: (ctx, ref, _) {
                      final itemsAsync = ref.watch(itemProvider);
                      return itemsAsync.when(
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
                        loading: () => const Center(child: CircularProgressIndicator()),
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
