import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';
import 'package:shareloop/app_config.dart';
import 'package:shareloop/screens/item_screen.dart';
import 'package:shareloop/theme/app_theme.dart';

class ItemWidget extends ConsumerWidget {
  final ItemOverview item;

  const ItemWidget(this.item, {super.key});

  @override
  Widget build(ctx, ref) {
    final cs = Theme.of(ctx).colorScheme;
    final tt = Theme.of(ctx).textTheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => ItemScreen(itemId: item.id)),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
        ),
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
                        AppConfig.imageUrl(item.imageUuid!),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/placeholder_image.jpg",
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(text: item.title, style: tt.titleMedium),
                              TextSpan(
                                text: ' · von ${item.author.name}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '${item.pricePerDay.toStringAsFixed(0)}€/Tag',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: starColor),
                      const SizedBox(width: 2),
                      Text(item.score.toStringAsFixed(1), style: tt.labelSmall),
                      const SizedBox(width: 16),
                      if (item.distance != null) ...[
                        Icon(Icons.location_on, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(
                          '${item.distance!.km.toStringAsFixed(0)} km',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                      if (item.distance != null && item.city != null)
                        Text(
                          ' · ',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      if (item.city != null)
                        Expanded(
                          child: Text(
                            item.city!,
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
