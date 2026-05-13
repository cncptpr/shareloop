//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FeaturedItem {
  /// Returns a new [FeaturedItem] instance.
  FeaturedItem({
    required this.title,
    required this.description,
    required this.author,
    required this.distance,
    required this.score,
  });

  String title;

  String description;

  Person author;

  Distance distance;

  double score;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FeaturedItem &&
    other.title == title &&
    other.description == description &&
    other.author == author &&
    other.distance == distance &&
    other.score == score;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (description.hashCode) +
    (author.hashCode) +
    (distance.hashCode) +
    (score.hashCode);

  @override
  String toString() => 'FeaturedItem[title=$title, description=$description, author=$author, distance=$distance, score=$score]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'description'] = this.description;
      json[r'author'] = this.author;
      json[r'distance'] = this.distance;
      json[r'score'] = this.score;
    return json;
  }

  /// Returns a new [FeaturedItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FeaturedItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'title'), 'Required key "FeaturedItem[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "FeaturedItem[title]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "FeaturedItem[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "FeaturedItem[description]" has a null value in JSON.');
        assert(json.containsKey(r'author'), 'Required key "FeaturedItem[author]" is missing from JSON.');
        assert(json[r'author'] != null, 'Required key "FeaturedItem[author]" has a null value in JSON.');
        assert(json.containsKey(r'distance'), 'Required key "FeaturedItem[distance]" is missing from JSON.');
        assert(json[r'distance'] != null, 'Required key "FeaturedItem[distance]" has a null value in JSON.');
        assert(json.containsKey(r'score'), 'Required key "FeaturedItem[score]" is missing from JSON.');
        assert(json[r'score'] != null, 'Required key "FeaturedItem[score]" has a null value in JSON.');
        return true;
      }());

      return FeaturedItem(
        title: mapValueOfType<String>(json, r'title')!,
        description: mapValueOfType<String>(json, r'description')!,
        author: Person.fromJson(json[r'author'])!,
        distance: Distance.fromJson(json[r'distance'])!,
        score: mapValueOfType<double>(json, r'score')!,
      );
    }
    return null;
  }

  static List<FeaturedItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FeaturedItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FeaturedItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FeaturedItem> mapFromJson(dynamic json) {
    final map = <String, FeaturedItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FeaturedItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FeaturedItem-objects as value to a dart map
  static Map<String, List<FeaturedItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FeaturedItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FeaturedItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'description',
    'author',
    'distance',
    'score',
  };
}

