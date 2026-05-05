import 'package:flutter_riverpod/legacy.dart';

const mock = [
  Item(
    title: "Inserat 1",
    description: "Ganz tolles Inserat",
    author: Person(name: "Ich"),
  ),
  Item(
    title: "Inserat 2",
    description: "Papput",
    author: Person(name: "Ich"),
  ),
  Item(
    title: "Auto",
    description: "Kann fahren",
    author: Person(name: "Carl"),
  ),
];

final itemProvider = StateProvider((ref) => mock);

class Person {
  final String name;

  const Person({required this.name});
}

class Item {
  final String title;
  final String description;
  final Person author;

  const Item(
      {required this.title, required this.description, required this.author});
}
