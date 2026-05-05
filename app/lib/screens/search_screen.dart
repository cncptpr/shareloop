import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/components/item_widget.dart';
import 'package:shareloop/state/items.dart';

/// The search screen
class SearchScreen extends StatefulWidget {
  /// Constructs a [SearchScreen]
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchText = "";

  @override
  Widget build(ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Screen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
                      child: Consumer(builder: (ctx, ref, _) {
                        final items = ref.watch(itemProvider);
                        return Column(
                          children:
                              items.map((item) => ItemWidget(item)).toList(),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
