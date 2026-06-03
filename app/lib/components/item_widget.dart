import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/item_screen.dart';

class ItemWidget extends ConsumerWidget {
  final FeaturedItem item;

  const ItemWidget(this.item, {super.key});

  @override
  Widget build(ctx, ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => ItemScreen(itemId: item.id)),
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: item.imageUuid != null
                      ? NetworkImage('${AppConfig.apiBaseUrl}/images/${item.imageUuid}')
                      : const AssetImage("assets/images/placeholder_image.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(item.title, textScaler: const TextScaler.linear(2)),
            Text(item.description),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                person(item.author),
                score(item.score),
                locationWidget(item.city, item.distance),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget person(Person person) {
    return Row(children: [
      const Icon(Icons.person),
      Text(person.name),
    ]);
  }

  Widget score(double score) {
    return Row(children: [
      const Icon(Icons.star),
      Text(score.toString()),
    ]);
  }

  Widget locationWidget(String? city, Distance? distance) {
    final parts = <String>[];
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    }
    if (distance != null) {
      parts.add('${distance.km.toStringAsFixed(0)} km');
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(children: [
      const Icon(Icons.location_on, size: 16),
      Text(parts.join(', ')),
    ]);
  }
}
