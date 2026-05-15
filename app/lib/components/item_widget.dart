import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openapi/api.dart';

class ItemWidget extends ConsumerWidget {
  final FeaturedItem item;

  const ItemWidget(this.item, {super.key});

  @override
  Widget build(ctx, ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              image: DecorationImage(
                image: AssetImage("assets/images/placeholder_image.jpg"),
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
              if (item.distance != null) distance(item.distance!),
            ],
          )
        ],
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

  Widget distance(Distance distance) {
    return Row(children: [
      const Icon(Icons.social_distance),
      Text(distance.km.toString()),
    ]);
  }
}
