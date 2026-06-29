//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadItemImageResponse {
  /// Returns a new [UploadItemImageResponse] instance.
  UploadItemImageResponse({
    required this.uuid,
  });

  String uuid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadItemImageResponse &&
    other.uuid == uuid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (uuid.hashCode);

  @override
  String toString() => 'UploadItemImageResponse[uuid=$uuid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'uuid'] = this.uuid;
    return json;
  }

  /// Returns a new [UploadItemImageResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadItemImageResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'uuid'), 'Required key "UploadItemImageResponse[uuid]" is missing from JSON.');
        assert(json[r'uuid'] != null, 'Required key "UploadItemImageResponse[uuid]" has a null value in JSON.');
        return true;
      }());

      return UploadItemImageResponse(
        uuid: mapValueOfType<String>(json, r'uuid')!,
      );
    }
    return null;
  }

  static List<UploadItemImageResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadItemImageResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadItemImageResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadItemImageResponse> mapFromJson(dynamic json) {
    final map = <String, UploadItemImageResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadItemImageResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadItemImageResponse-objects as value to a dart map
  static Map<String, List<UploadItemImageResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadItemImageResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadItemImageResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'uuid',
  };
}

