//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Distance {
  /// Returns a new [Distance] instance.
  Distance({
    required this.km,
  });

  double km;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Distance &&
    other.km == km;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (km.hashCode);

  @override
  String toString() => 'Distance[km=$km]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'km'] = this.km;
    return json;
  }

  /// Returns a new [Distance] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Distance? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'km'), 'Required key "Distance[km]" is missing from JSON.');
        assert(json[r'km'] != null, 'Required key "Distance[km]" has a null value in JSON.');
        return true;
      }());

      return Distance(
        km: mapValueOfType<double>(json, r'km')!,
      );
    }
    return null;
  }

  static List<Distance> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Distance>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Distance.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Distance> mapFromJson(dynamic json) {
    final map = <String, Distance>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Distance.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Distance-objects as value to a dart map
  static Map<String, List<Distance>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Distance>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Distance.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'km',
  };
}

