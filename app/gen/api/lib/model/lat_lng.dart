//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LatLng {
  /// Returns a new [LatLng] instance.
  LatLng({
    required this.lat,
    required this.lng,
  });

  double lat;

  double lng;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LatLng &&
    other.lat == lat &&
    other.lng == lng;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (lat.hashCode) +
    (lng.hashCode);

  @override
  String toString() => 'LatLng[lat=$lat, lng=$lng]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'lat'] = this.lat;
      json[r'lng'] = this.lng;
    return json;
  }

  /// Returns a new [LatLng] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LatLng? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'lat'), 'Required key "LatLng[lat]" is missing from JSON.');
        assert(json[r'lat'] != null, 'Required key "LatLng[lat]" has a null value in JSON.');
        assert(json.containsKey(r'lng'), 'Required key "LatLng[lng]" is missing from JSON.');
        assert(json[r'lng'] != null, 'Required key "LatLng[lng]" has a null value in JSON.');
        return true;
      }());

      return LatLng(
        lat: mapValueOfType<double>(json, r'lat')!,
        lng: mapValueOfType<double>(json, r'lng')!,
      );
    }
    return null;
  }

  static List<LatLng> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LatLng>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LatLng.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LatLng> mapFromJson(dynamic json) {
    final map = <String, LatLng>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LatLng.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LatLng-objects as value to a dart map
  static Map<String, List<LatLng>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LatLng>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LatLng.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'lat',
    'lng',
  };
}

