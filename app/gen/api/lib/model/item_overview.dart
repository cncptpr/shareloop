//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemOverview {
  /// Returns a new [ItemOverview] instance.
  ItemOverview({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    this.distance,
    this.city,
    this.postalCode,
    required this.score,
    this.imageUuid,
    required this.category,
    required this.pricePerDay,
  });

  int id;

  String title;

  String description;

  Person author;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  Distance? distance;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? city;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? postalCode;

  double score;

  String? imageUuid;

  String category;

  double pricePerDay;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemOverview &&
    other.id == id &&
    other.title == title &&
    other.description == description &&
    other.author == author &&
    other.distance == distance &&
    other.city == city &&
    other.postalCode == postalCode &&
    other.score == score &&
    other.imageUuid == imageUuid &&
    other.category == category &&
    other.pricePerDay == pricePerDay;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (description.hashCode) +
    (author.hashCode) +
    (distance == null ? 0 : distance!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (postalCode == null ? 0 : postalCode!.hashCode) +
    (score.hashCode) +
    (imageUuid == null ? 0 : imageUuid!.hashCode) +
    (category.hashCode) +
    (pricePerDay.hashCode);

  @override
  String toString() => 'ItemOverview[id=$id, title=$title, description=$description, author=$author, distance=$distance, city=$city, postalCode=$postalCode, score=$score, imageUuid=$imageUuid, category=$category, pricePerDay=$pricePerDay]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
      json[r'description'] = this.description;
      json[r'author'] = this.author;
    if (this.distance != null) {
      json[r'distance'] = this.distance;
    } else {
      json[r'distance'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.postalCode != null) {
      json[r'postalCode'] = this.postalCode;
    } else {
      json[r'postalCode'] = null;
    }
      json[r'score'] = this.score;
    if (this.imageUuid != null) {
      json[r'imageUuid'] = this.imageUuid;
    } else {
      json[r'imageUuid'] = null;
    }
      json[r'category'] = this.category;
      json[r'pricePerDay'] = this.pricePerDay;
    return json;
  }

  /// Returns a new [ItemOverview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemOverview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ItemOverview[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ItemOverview[id]" has a null value in JSON.');
        assert(json.containsKey(r'title'), 'Required key "ItemOverview[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "ItemOverview[title]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "ItemOverview[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "ItemOverview[description]" has a null value in JSON.');
        assert(json.containsKey(r'author'), 'Required key "ItemOverview[author]" is missing from JSON.');
        assert(json[r'author'] != null, 'Required key "ItemOverview[author]" has a null value in JSON.');
        assert(json.containsKey(r'score'), 'Required key "ItemOverview[score]" is missing from JSON.');
        assert(json[r'score'] != null, 'Required key "ItemOverview[score]" has a null value in JSON.');
        assert(json.containsKey(r'category'), 'Required key "ItemOverview[category]" is missing from JSON.');
        assert(json[r'category'] != null, 'Required key "ItemOverview[category]" has a null value in JSON.');
        assert(json.containsKey(r'pricePerDay'), 'Required key "ItemOverview[pricePerDay]" is missing from JSON.');
        assert(json[r'pricePerDay'] != null, 'Required key "ItemOverview[pricePerDay]" has a null value in JSON.');
        return true;
      }());

      return ItemOverview(
        id: mapValueOfType<int>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        description: mapValueOfType<String>(json, r'description')!,
        author: Person.fromJson(json[r'author'])!,
        distance: Distance.fromJson(json[r'distance']),
        city: mapValueOfType<String>(json, r'city'),
        postalCode: mapValueOfType<String>(json, r'postalCode'),
        score: mapValueOfType<double>(json, r'score')!,
        imageUuid: mapValueOfType<String>(json, r'imageUuid'),
        category: mapValueOfType<String>(json, r'category')!,
        pricePerDay: mapValueOfType<double>(json, r'pricePerDay')!,
      );
    }
    return null;
  }

  static List<ItemOverview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemOverview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemOverview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemOverview> mapFromJson(dynamic json) {
    final map = <String, ItemOverview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemOverview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemOverview-objects as value to a dart map
  static Map<String, List<ItemOverview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemOverview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemOverview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'description',
    'author',
    'score',
    'category',
    'pricePerDay',
  };
}

