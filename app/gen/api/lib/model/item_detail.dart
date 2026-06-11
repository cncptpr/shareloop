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
    this.category,
    this.lat,
    this.lng,
    required this.createdAt,
    required this.authorId,
  });

  int id;

  String title;

  String description;

  Person author;

  double score;

  String? city;

  String? postalCode;

  List<String> imageUuids;

  String? category;

  double? lat;

  double? lng;

  DateTime createdAt;

  int authorId;

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
    other.lat == lat &&
    other.lng == lng &&
    other.createdAt == createdAt &&
    other.authorId == authorId;

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
    (category == null ? 0 : category!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lng == null ? 0 : lng!.hashCode) +
    (createdAt.hashCode) +
    (authorId.hashCode);

  @override
  String toString() => 'ItemDetail[id=$id, title=$title, description=$description, author=$author, score=$score, city=$city, postalCode=$postalCode, imageUuids=$imageUuids, category=$category, lat=$lat, lng=$lng, createdAt=$createdAt, authorId=$authorId]';

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
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
    if (this.lat != null) {
      json[r'lat'] = this.lat;
    } else {
      json[r'lat'] = null;
    }
    if (this.lng != null) {
      json[r'lng'] = this.lng;
    } else {
      json[r'lng'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'authorId'] = this.authorId;
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
        assert(json.containsKey(r'createdAt'), 'Required key "ItemDetail[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ItemDetail[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'authorId'), 'Required key "ItemDetail[authorId]" is missing from JSON.');
        assert(json[r'authorId'] != null, 'Required key "ItemDetail[authorId]" has a null value in JSON.');
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
        category: mapValueOfType<String>(json, r'category'),
        lat: mapValueOfType<double>(json, r'lat'),
        lng: mapValueOfType<double>(json, r'lng'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        authorId: mapValueOfType<int>(json, r'authorId')!,
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
    'createdAt',
    'authorId',
  };
}

