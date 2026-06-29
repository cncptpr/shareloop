//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentOffer {
  /// Returns a new [RentOffer] instance.
  RentOffer({
    required this.id,
    required this.rentRequestId,
    required this.senderId,
    required this.startDate,
    required this.endDate,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;

  int rentRequestId;

  int senderId;

  DateTime startDate;

  DateTime endDate;

  DateTime? acceptedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentOffer &&
    other.id == id &&
    other.rentRequestId == rentRequestId &&
    other.senderId == senderId &&
    other.startDate == startDate &&
    other.endDate == endDate &&
    other.acceptedAt == acceptedAt &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (rentRequestId.hashCode) +
    (senderId.hashCode) +
    (startDate.hashCode) +
    (endDate.hashCode) +
    (acceptedAt == null ? 0 : acceptedAt!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'RentOffer[id=$id, rentRequestId=$rentRequestId, senderId=$senderId, startDate=$startDate, endDate=$endDate, acceptedAt=$acceptedAt, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'rentRequestId'] = this.rentRequestId;
      json[r'senderId'] = this.senderId;
      json[r'startDate'] = this.startDate.toUtc().toIso8601String();
      json[r'endDate'] = this.endDate.toUtc().toIso8601String();
    if (this.acceptedAt != null) {
      json[r'acceptedAt'] = this.acceptedAt!.toUtc().toIso8601String();
    } else {
      json[r'acceptedAt'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [RentOffer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentOffer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "RentOffer[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "RentOffer[id]" has a null value in JSON.');
        assert(json.containsKey(r'rentRequestId'), 'Required key "RentOffer[rentRequestId]" is missing from JSON.');
        assert(json[r'rentRequestId'] != null, 'Required key "RentOffer[rentRequestId]" has a null value in JSON.');
        assert(json.containsKey(r'senderId'), 'Required key "RentOffer[senderId]" is missing from JSON.');
        assert(json[r'senderId'] != null, 'Required key "RentOffer[senderId]" has a null value in JSON.');
        assert(json.containsKey(r'startDate'), 'Required key "RentOffer[startDate]" is missing from JSON.');
        assert(json[r'startDate'] != null, 'Required key "RentOffer[startDate]" has a null value in JSON.');
        assert(json.containsKey(r'endDate'), 'Required key "RentOffer[endDate]" is missing from JSON.');
        assert(json[r'endDate'] != null, 'Required key "RentOffer[endDate]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "RentOffer[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "RentOffer[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "RentOffer[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "RentOffer[updatedAt]" has a null value in JSON.');
        return true;
      }());

      return RentOffer(
        id: mapValueOfType<int>(json, r'id')!,
        rentRequestId: mapValueOfType<int>(json, r'rentRequestId')!,
        senderId: mapValueOfType<int>(json, r'senderId')!,
        startDate: mapDateTime(json, r'startDate', r'')!,
        endDate: mapDateTime(json, r'endDate', r'')!,
        acceptedAt: mapDateTime(json, r'acceptedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<RentOffer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentOffer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentOffer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentOffer> mapFromJson(dynamic json) {
    final map = <String, RentOffer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentOffer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentOffer-objects as value to a dart map
  static Map<String, List<RentOffer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentOffer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentOffer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'rentRequestId',
    'senderId',
    'startDate',
    'endDate',
    'createdAt',
    'updatedAt',
  };
}

