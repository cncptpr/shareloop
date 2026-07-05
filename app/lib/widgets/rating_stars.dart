import 'package:flutter/material.dart';
import 'package:shareloop/theme/app_theme.dart';

class ReadOnlyStars extends StatelessWidget {
  final double value;
  final double size;

  const ReadOnlyStars({super.key, required this.value, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= value.round() ? Icons.star : Icons.star_border,
            size: size,
            color: starColor,
          ),
      ],
    );
  }
}

class RatingMetric extends StatelessWidget {
  final String label;
  final int value;

  const RatingMetric({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        Icon(Icons.star, size: 16, color: starColor),
        const SizedBox(width: 2),
        Text('$value'),
      ],
    );
  }
}
