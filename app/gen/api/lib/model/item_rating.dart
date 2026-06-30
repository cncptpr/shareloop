//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemRating {
  /// Returns a new [ItemRating] instance.
  ItemRating({
    required this.id,
    required this.rentRequestId,
    required this.itemId,
    required this.reviewer,
    required this.condition,
    required this.cleanliness,
    required this.overall,
    this.comment,
    required this.createdAt,
  });

  int id;

  int rentRequestId;

  int itemId;

  Person reviewer;

  /// Minimum value: 1
  /// Maximum value: 5
  int condition;

  /// Minimum value: 1
  /// Maximum value: 5
  int cleanliness;

  /// Minimum value: 1
  /// Maximum value: 5
  double overall;

  String? comment;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemRating &&
    other.id == id &&
    other.rentRequestId == rentRequestId &&
    other.itemId == itemId &&
    other.reviewer == reviewer &&
    other.condition == condition &&
    other.cleanliness == cleanliness &&
    other.overall == overall &&
    other.comment == comment &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (rentRequestId.hashCode) +
    (itemId.hashCode) +
    (reviewer.hashCode) +
    (condition.hashCode) +
    (cleanliness.hashCode) +
    (overall.hashCode) +
    (comment == null ? 0 : comment!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'ItemRating[id=$id, rentRequestId=$rentRequestId, itemId=$itemId, reviewer=$reviewer, condition=$condition, cleanliness=$cleanliness, overall=$overall, comment=$comment, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'rentRequestId'] = this.rentRequestId;
      json[r'itemId'] = this.itemId;
      json[r'reviewer'] = this.reviewer;
      json[r'condition'] = this.condition;
      json[r'cleanliness'] = this.cleanliness;
      json[r'overall'] = this.overall;
    if (this.comment != null) {
      json[r'comment'] = this.comment;
    } else {
      json[r'comment'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [ItemRating] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemRating? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "ItemRating[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "ItemRating[id]" has a null value in JSON.');
        assert(json.containsKey(r'rentRequestId'), 'Required key "ItemRating[rentRequestId]" is missing from JSON.');
        assert(json[r'rentRequestId'] != null, 'Required key "ItemRating[rentRequestId]" has a null value in JSON.');
        assert(json.containsKey(r'itemId'), 'Required key "ItemRating[itemId]" is missing from JSON.');
        assert(json[r'itemId'] != null, 'Required key "ItemRating[itemId]" has a null value in JSON.');
        assert(json.containsKey(r'reviewer'), 'Required key "ItemRating[reviewer]" is missing from JSON.');
        assert(json[r'reviewer'] != null, 'Required key "ItemRating[reviewer]" has a null value in JSON.');
        assert(json.containsKey(r'condition'), 'Required key "ItemRating[condition]" is missing from JSON.');
        assert(json[r'condition'] != null, 'Required key "ItemRating[condition]" has a null value in JSON.');
        assert(json.containsKey(r'cleanliness'), 'Required key "ItemRating[cleanliness]" is missing from JSON.');
        assert(json[r'cleanliness'] != null, 'Required key "ItemRating[cleanliness]" has a null value in JSON.');
        assert(json.containsKey(r'overall'), 'Required key "ItemRating[overall]" is missing from JSON.');
        assert(json[r'overall'] != null, 'Required key "ItemRating[overall]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "ItemRating[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "ItemRating[createdAt]" has a null value in JSON.');
        return true;
      }());

      return ItemRating(
        id: mapValueOfType<int>(json, r'id')!,
        rentRequestId: mapValueOfType<int>(json, r'rentRequestId')!,
        itemId: mapValueOfType<int>(json, r'itemId')!,
        reviewer: Person.fromJson(json[r'reviewer'])!,
        condition: mapValueOfType<int>(json, r'condition')!,
        cleanliness: mapValueOfType<int>(json, r'cleanliness')!,
        overall: mapValueOfType<double>(json, r'overall')!,
        comment: mapValueOfType<String>(json, r'comment'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<ItemRating> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemRating>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemRating.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemRating> mapFromJson(dynamic json) {
    final map = <String, ItemRating>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemRating.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemRating-objects as value to a dart map
  static Map<String, List<ItemRating>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemRating>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemRating.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'rentRequestId',
    'itemId',
    'reviewer',
    'condition',
    'cleanliness',
    'overall',
    'createdAt',
  };
}

