import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/item_screen.dart';

class ItemWidget extends ConsumerWidget {
  final ItemOverview item;

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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 300,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.title,
                      textScaler: const TextScaler.linear(2),
                      style: Theme.of(ctx).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.category,
                    style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(item.description),
            ),
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
      Text(score.toStringAsFixed(1)),
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
