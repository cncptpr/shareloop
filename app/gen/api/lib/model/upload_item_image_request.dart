//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadItemImageRequest {
  /// Returns a new [UploadItemImageRequest] instance.
  UploadItemImageRequest({
    required this.data,
    required this.filename,
    required this.sortOrder,
  });

  /// Base64-encoded image data
  String data;

  /// Original filename for extension detection
  String filename;

  /// Position of this image in the item's image list
  int sortOrder;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadItemImageRequest &&
    other.data == data &&
    other.filename == filename &&
    other.sortOrder == sortOrder;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data.hashCode) +
    (filename.hashCode) +
    (sortOrder.hashCode);

  @override
  String toString() => 'UploadItemImageRequest[data=$data, filename=$filename, sortOrder=$sortOrder]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'data'] = this.data;
      json[r'filename'] = this.filename;
      json[r'sortOrder'] = this.sortOrder;
    return json;
  }

  /// Returns a new [UploadItemImageRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadItemImageRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'data'), 'Required key "UploadItemImageRequest[data]" is missing from JSON.');
        assert(json[r'data'] != null, 'Required key "UploadItemImageRequest[data]" has a null value in JSON.');
        assert(json.containsKey(r'filename'), 'Required key "UploadItemImageRequest[filename]" is missing from JSON.');
        assert(json[r'filename'] != null, 'Required key "UploadItemImageRequest[filename]" has a null value in JSON.');
        assert(json.containsKey(r'sortOrder'), 'Required key "UploadItemImageRequest[sortOrder]" is missing from JSON.');
        assert(json[r'sortOrder'] != null, 'Required key "UploadItemImageRequest[sortOrder]" has a null value in JSON.');
        return true;
      }());

      return UploadItemImageRequest(
        data: mapValueOfType<String>(json, r'data')!,
        filename: mapValueOfType<String>(json, r'filename')!,
        sortOrder: mapValueOfType<int>(json, r'sortOrder')!,
      );
    }
    return null;
  }

  static List<UploadItemImageRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadItemImageRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadItemImageRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadItemImageRequest> mapFromJson(dynamic json) {
    final map = <String, UploadItemImageRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadItemImageRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadItemImageRequest-objects as value to a dart map
  static Map<String, List<UploadItemImageRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadItemImageRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadItemImageRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'data',
    'filename',
    'sortOrder',
  };
}

