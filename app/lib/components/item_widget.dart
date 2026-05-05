import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shareloop/state/items.dart';

class ItemWidget extends ConsumerWidget {
  final Item item;

  const ItemWidget(this.item, {super.key});

  @override
  Widget build(ctx, ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, textScaler: const TextScaler.linear(2)),
          Text(item.description),
          Row(children: [const Icon(Icons.person), Text(item.author.name)]),
          Image.asset(
            "assets/images/placeholder_image.jpg",
            width: 300,
            height: 300,
          ),
        ],
      ),
    );
  }
}
