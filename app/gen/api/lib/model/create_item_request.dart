//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateItemRequest {
  /// Returns a new [CreateItemRequest] instance.
  CreateItemRequest({
    required this.title,
    required this.description,
    required this.city,
    required this.postalCode,
    required this.lat,
    required this.lng,
    required this.category,
    required this.pricePerDay,
  });

  String title;

  String description;

  String city;

  String postalCode;

  double lat;

  double lng;

  String category;

  double pricePerDay;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateItemRequest &&
    other.title == title &&
    other.description == description &&
    other.city == city &&
    other.postalCode == postalCode &&
    other.lat == lat &&
    other.lng == lng &&
    other.category == category &&
    other.pricePerDay == pricePerDay;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (description.hashCode) +
    (city.hashCode) +
    (postalCode.hashCode) +
    (lat.hashCode) +
    (lng.hashCode) +
    (category.hashCode) +
    (pricePerDay.hashCode);

  @override
  String toString() => 'CreateItemRequest[title=$title, description=$description, city=$city, postalCode=$postalCode, lat=$lat, lng=$lng, category=$category, pricePerDay=$pricePerDay]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'description'] = this.description;
      json[r'city'] = this.city;
      json[r'postalCode'] = this.postalCode;
      json[r'lat'] = this.lat;
      json[r'lng'] = this.lng;
      json[r'category'] = this.category;
      json[r'pricePerDay'] = this.pricePerDay;
    return json;
  }

  /// Returns a new [CreateItemRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateItemRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'title'), 'Required key "CreateItemRequest[title]" is missing from JSON.');
        assert(json[r'title'] != null, 'Required key "CreateItemRequest[title]" has a null value in JSON.');
        assert(json.containsKey(r'description'), 'Required key "CreateItemRequest[description]" is missing from JSON.');
        assert(json[r'description'] != null, 'Required key "CreateItemRequest[description]" has a null value in JSON.');
        assert(json.containsKey(r'city'), 'Required key "CreateItemRequest[city]" is missing from JSON.');
        assert(json[r'city'] != null, 'Required key "CreateItemRequest[city]" has a null value in JSON.');
        assert(json.containsKey(r'postalCode'), 'Required key "CreateItemRequest[postalCode]" is missing from JSON.');
        assert(json[r'postalCode'] != null, 'Required key "CreateItemRequest[postalCode]" has a null value in JSON.');
        assert(json.containsKey(r'lat'), 'Required key "CreateItemRequest[lat]" is missing from JSON.');
        assert(json[r'lat'] != null, 'Required key "CreateItemRequest[lat]" has a null value in JSON.');
        assert(json.containsKey(r'lng'), 'Required key "CreateItemRequest[lng]" is missing from JSON.');
        assert(json[r'lng'] != null, 'Required key "CreateItemRequest[lng]" has a null value in JSON.');
        assert(json.containsKey(r'category'), 'Required key "CreateItemRequest[category]" is missing from JSON.');
        assert(json[r'category'] != null, 'Required key "CreateItemRequest[category]" has a null value in JSON.');
        assert(json.containsKey(r'pricePerDay'), 'Required key "CreateItemRequest[pricePerDay]" is missing from JSON.');
        assert(json[r'pricePerDay'] != null, 'Required key "CreateItemRequest[pricePerDay]" has a null value in JSON.');
        return true;
      }());

      return CreateItemRequest(
        title: mapValueOfType<String>(json, r'title')!,
        description: mapValueOfType<String>(json, r'description')!,
        city: mapValueOfType<String>(json, r'city')!,
        postalCode: mapValueOfType<String>(json, r'postalCode')!,
        lat: mapValueOfType<double>(json, r'lat')!,
        lng: mapValueOfType<double>(json, r'lng')!,
        category: mapValueOfType<String>(json, r'category')!,
        pricePerDay: mapValueOfType<double>(json, r'pricePerDay')!,
      );
    }
    return null;
  }

  static List<CreateItemRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateItemRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateItemRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateItemRequest> mapFromJson(dynamic json) {
    final map = <String, CreateItemRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateItemRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateItemRequest-objects as value to a dart map
  static Map<String, List<CreateItemRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateItemRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateItemRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'description',
    'city',
    'postalCode',
    'lat',
    'lng',
    'category',
    'pricePerDay',
  };
}
