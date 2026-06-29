//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubmittedRentRatings {
  /// Returns a new [SubmittedRentRatings] instance.
  SubmittedRentRatings({
    required this.userRating,
    this.itemRating,
  });

  UserRating userRating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ItemRating? itemRating;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubmittedRentRatings &&
    other.userRating == userRating &&
    other.itemRating == itemRating;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (userRating.hashCode) +
    (itemRating == null ? 0 : itemRating!.hashCode);

  @override
  String toString() => 'SubmittedRentRatings[userRating=$userRating, itemRating=$itemRating]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'userRating'] = this.userRating;
    if (this.itemRating != null) {
      json[r'itemRating'] = this.itemRating;
    } else {
      json[r'itemRating'] = null;
    }
    return json;
  }

  /// Returns a new [SubmittedRentRatings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubmittedRentRatings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'userRating'), 'Required key "SubmittedRentRatings[userRating]" is missing from JSON.');
        assert(json[r'userRating'] != null, 'Required key "SubmittedRentRatings[userRating]" has a null value in JSON.');
        return true;
      }());

      return SubmittedRentRatings(
        userRating: UserRating.fromJson(json[r'userRating'])!,
        itemRating: ItemRating.fromJson(json[r'itemRating']),
      );
    }
    return null;
  }

  static List<SubmittedRentRatings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubmittedRentRatings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubmittedRentRatings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubmittedRentRatings> mapFromJson(dynamic json) {
    final map = <String, SubmittedRentRatings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubmittedRentRatings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubmittedRentRatings-objects as value to a dart map
  static Map<String, List<SubmittedRentRatings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubmittedRentRatings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubmittedRentRatings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'userRating',
  };
}

