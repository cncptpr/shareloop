//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReorderEntry {
  /// Returns a new [ReorderEntry] instance.
  ReorderEntry({
    required this.uuid,
    required this.sortOrder,
  });

  String uuid;

  int sortOrder;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReorderEntry &&
    other.uuid == uuid &&
    other.sortOrder == sortOrder;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (uuid.hashCode) +
    (sortOrder.hashCode);

  @override
  String toString() => 'ReorderEntry[uuid=$uuid, sortOrder=$sortOrder]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'uuid'] = this.uuid;
      json[r'sortOrder'] = this.sortOrder;
    return json;
  }

  /// Returns a new [ReorderEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReorderEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'uuid'), 'Required key "ReorderEntry[uuid]" is missing from JSON.');
        assert(json[r'uuid'] != null, 'Required key "ReorderEntry[uuid]" has a null value in JSON.');
        assert(json.containsKey(r'sortOrder'), 'Required key "ReorderEntry[sortOrder]" is missing from JSON.');
        assert(json[r'sortOrder'] != null, 'Required key "ReorderEntry[sortOrder]" has a null value in JSON.');
        return true;
      }());

      return ReorderEntry(
        uuid: mapValueOfType<String>(json, r'uuid')!,
        sortOrder: mapValueOfType<int>(json, r'sortOrder')!,
      );
    }
    return null;
  }

  static List<ReorderEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReorderEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReorderEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReorderEntry> mapFromJson(dynamic json) {
    final map = <String, ReorderEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReorderEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReorderEntry-objects as value to a dart map
  static Map<String, List<ReorderEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReorderEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReorderEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'uuid',
    'sortOrder',
  };
}

