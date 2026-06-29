//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemDetail {
  /// Returns a new [ItemDetail] instance.
  ItemDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.score,
    this.city,
    this.postalCode,
    this.imageUuids = const [],
    required this.category,
    required this.createdAt,
    required this.itemRatingCount,
    this.itemRatings = const [],
  });

  int id;

  String title;

  String description;

  Person author;

  double score;

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

  List<String> imageUuids;

  String category;

  DateTime createdAt;

  /// Minimum value: 0
  int itemRatingCount;

  List<ItemRating> itemRatings;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemDetail &&
    other.id == id &&
    other.title == title &&
    other.description == description &&
    other.author == author &&
    other.score == score &&
    other.city == city &&
    other.postalCode == postalCode &&
    _deepEquality.equals(other.imageUuids, imageUuids) &&
    other.category == category &&
    other.createdAt == createdAt &&
    other.itemRatingCount == itemRatingCount &&
    _deepEquality.equals(other.itemRatings, itemRatings);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (description.hashCode) +
    (author.hashCode) +
    (score.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (postalCode == null ? 0 : postalCode!.hashCode) +
    (imageUuids.hashCode) +
    (category.hashCode) +
    (createdAt.hashCode) +
    (itemRatingCount.hashCode) +
    (itemRatings.hashCode);

  @override
  String toString() => 'ItemDetail[id=$id, title=$title, description=$description, author=$author, score=$score, city=$city, postalCode=$postalCode, imageUuids=$imageUuids, category=$category, createdAt=$createdAt, itemRatingCount=$itemRatingCount, itemRatings=$itemRatings]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
      json[r'description'] = this.description;
      json[r'author'] = this.author;
      json[r'score'] = this.score;
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
      json[r'imageUuids'] = this.imageUuids;
      json[r'category'] = this.category;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'itemRatingCount'] = this.itemRatingCount;
      json[r'itemRatings'] = this.itemRatings;
    return json;
  }

  /// Returns a new [ItemDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ItemDetail[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ItemDetail[id]" has a null value in JSON.');
        assert(json.containsKey(r'title'), 'Required key "ItemDetail[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "ItemDetail[title]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "ItemDetail[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "ItemDetail[description]" has a null value in JSON.');
        assert(json.containsKey(r'author'), 'Required key "ItemDetail[author]" is missing from JSON.');
        assert(json[r'author'] != null, 'Required key "ItemDetail[author]" has a null value in JSON.');
        assert(json.containsKey(r'score'), 'Required key "ItemDetail[score]" is missing from JSON.');
        assert(json[r'score'] != null, 'Required key "ItemDetail[score]" has a null value in JSON.');
        assert(json.containsKey(r'imageUuids'), 'Required key "ItemDetail[imageUuids]" is missing from JSON.');
        assert(json[r'imageUuids'] != null, 'Required key "ItemDetail[imageUuids]" has a null value in JSON.');
        assert(json.containsKey(r'category'), 'Required key "ItemDetail[category]" is missing from JSON.');
        assert(json[r'category'] != null, 'Required key "ItemDetail[category]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ItemDetail[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ItemDetail[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'itemRatingCount'), 'Required key "ItemDetail[itemRatingCount]" is missing from JSON.');
        assert(json[r'itemRatingCount'] != null, 'Required key "ItemDetail[itemRatingCount]" has a null value in JSON.');
        assert(json.containsKey(r'itemRatings'), 'Required key "ItemDetail[itemRatings]" is missing from JSON.');
        assert(json[r'itemRatings'] != null, 'Required key "ItemDetail[itemRatings]" has a null value in JSON.');
        return true;
      }());

      return ItemDetail(
        id: mapValueOfType<int>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        description: mapValueOfType<String>(json, r'description')!,
        author: Person.fromJson(json[r'author'])!,
        score: mapValueOfType<double>(json, r'score')!,
        city: mapValueOfType<String>(json, r'city'),
        postalCode: mapValueOfType<String>(json, r'postalCode'),
        imageUuids: json[r'imageUuids'] is Iterable
            ? (json[r'imageUuids'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        category: mapValueOfType<String>(json, r'category')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        itemRatingCount: mapValueOfType<int>(json, r'itemRatingCount')!,
        itemRatings: ItemRating.listFromJson(json[r'itemRatings']),
      );
    }
    return null;
  }

  static List<ItemDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemDetail> mapFromJson(dynamic json) {
    final map = <String, ItemDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemDetail-objects as value to a dart map
  static Map<String, List<ItemDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemDetail.listFromJson(entry.value, growable: growable,);
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
    'imageUuids',
    'category',
    'createdAt',
    'itemRatingCount',
    'itemRatings',
  };
}

