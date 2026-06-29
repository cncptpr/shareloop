//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SubmitItemRatingRequest {
  /// Returns a new [SubmitItemRatingRequest] instance.
  SubmitItemRatingRequest({
    required this.condition,
    required this.descriptionAccuracy,
    required this.functionality,
    this.comment,
  });

  /// Minimum value: 1
  /// Maximum value: 5
  int condition;

  /// Minimum value: 1
  /// Maximum value: 5
  int descriptionAccuracy;

  /// Minimum value: 1
  /// Maximum value: 5
  int functionality;

  String? comment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SubmitItemRatingRequest &&
    other.condition == condition &&
    other.descriptionAccuracy == descriptionAccuracy &&
    other.functionality == functionality &&
    other.comment == comment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (condition.hashCode) +
    (descriptionAccuracy.hashCode) +
    (functionality.hashCode) +
    (comment == null ? 0 : comment!.hashCode);

  @override
  String toString() => 'SubmitItemRatingRequest[condition=$condition, descriptionAccuracy=$descriptionAccuracy, functionality=$functionality, comment=$comment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'condition'] = this.condition;
      json[r'descriptionAccuracy'] = this.descriptionAccuracy;
      json[r'functionality'] = this.functionality;
    if (this.comment != null) {
      json[r'comment'] = this.comment;
    } else {
      json[r'comment'] = null;
    }
    return json;
  }

  /// Returns a new [SubmitItemRatingRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SubmitItemRatingRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'condition'), 'Required key "SubmitItemRatingRequest[condition]" is missing from JSON.');
        assert(json[r'condition'] != null, 'Required key "SubmitItemRatingRequest[condition]" has a null value in JSON.');
        assert(json.containsKey(r'descriptionAccuracy'), 'Required key "SubmitItemRatingRequest[descriptionAccuracy]" is missing from JSON.');
        assert(json[r'descriptionAccuracy'] != null, 'Required key "SubmitItemRatingRequest[descriptionAccuracy]" has a null value in JSON.');
        assert(json.containsKey(r'functionality'), 'Required key "SubmitItemRatingRequest[functionality]" is missing from JSON.');
        assert(json[r'functionality'] != null, 'Required key "SubmitItemRatingRequest[functionality]" has a null value in JSON.');
        return true;
      }());

      return SubmitItemRatingRequest(
        condition: mapValueOfType<int>(json, r'condition')!,
        descriptionAccuracy: mapValueOfType<int>(json, r'descriptionAccuracy')!,
        functionality: mapValueOfType<int>(json, r'functionality')!,
        comment: mapValueOfType<String>(json, r'comment'),
      );
    }
    return null;
  }

  static List<SubmitItemRatingRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SubmitItemRatingRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SubmitItemRatingRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SubmitItemRatingRequest> mapFromJson(dynamic json) {
    final map = <String, SubmitItemRatingRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SubmitItemRatingRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SubmitItemRatingRequest-objects as value to a dart map
  static Map<String, List<SubmitItemRatingRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SubmitItemRatingRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SubmitItemRatingRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'condition',
    'descriptionAccuracy',
    'functionality',
  };
}

