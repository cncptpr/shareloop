import 'package:flutter_riverpod/legacy.dart';

const mock = [
  Item(
    title: "Inserat 1",
    description: "Ganz tolles Inserat",
    author: Person(name: "Ich"),
    distance: Distance(km: 8.3),
    score: 4.9,
  ),
  Item(
    title: "Inserat 2",
    description: "Papput",
    author: Person(name: "Ich"),
    distance: Distance(km: 8.3),
    score: 4.9,
  ),
  Item(
    title: "Auto",
    description: "Kann fahren",
    author: Person(name: "Carl"),
    distance: Distance(km: 8.3),
    score: 4.3,
  ),
  Item(
    title: "Spezi",
    description: "Bitte voll zurueck",
    author: Person(name: "Timon"),
    distance: Distance(km: 2.3),
    score: 5,
  ),
];

final itemProvider = StateProvider((ref) => mock);

class Person {
  final String name;
  const Person({required this.name});
}

class Distance {
  final double km;
  const Distance({required this.km});
}

class Item {
  final String title;
  final String description;
  final Person author;
  final Distance distance;
  final double score;

  const Item({
    required this.title,
    required this.description,
    required this.author,
    required this.distance,
    required this.score,
  });
}
