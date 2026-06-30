//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserRating {
  /// Returns a new [UserRating] instance.
  UserRating({
    required this.id,
    required this.rentRequestId,
    required this.reviewerId,
    required this.revieweeId,
    required this.friendliness,
    required this.punctuality,
    required this.reliability,
    this.communication,
    this.carefulHandling,
    this.comment,
    required this.createdAt,
  });

  int id;

  int rentRequestId;

  int reviewerId;

  int revieweeId;

  /// Minimum value: 1
  /// Maximum value: 5
  int friendliness;

  /// Minimum value: 1
  /// Maximum value: 5
  int punctuality;

  /// Minimum value: 1
  /// Maximum value: 5
  int reliability;

  /// Minimum value: 1
  /// Maximum value: 5
  int? communication;

  /// Minimum value: 1
  /// Maximum value: 5
  int? carefulHandling;

  String? comment;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserRating &&
    other.id == id &&
    other.rentRequestId == rentRequestId &&
    other.reviewerId == reviewerId &&
    other.revieweeId == revieweeId &&
    other.friendliness == friendliness &&
    other.punctuality == punctuality &&
    other.reliability == reliability &&
    other.communication == communication &&
    other.carefulHandling == carefulHandling &&
    other.comment == comment &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (rentRequestId.hashCode) +
    (reviewerId.hashCode) +
    (revieweeId.hashCode) +
    (friendliness.hashCode) +
    (punctuality.hashCode) +
    (reliability.hashCode) +
    (communication == null ? 0 : communication!.hashCode) +
    (carefulHandling == null ? 0 : carefulHandling!.hashCode) +
    (comment == null ? 0 : comment!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'UserRating[id=$id, rentRequestId=$rentRequestId, reviewerId=$reviewerId, revieweeId=$revieweeId, friendliness=$friendliness, punctuality=$punctuality, reliability=$reliability, communication=$communication, carefulHandling=$carefulHandling, comment=$comment, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'rentRequestId'] = this.rentRequestId;
      json[r'reviewerId'] = this.reviewerId;
      json[r'revieweeId'] = this.revieweeId;
      json[r'friendliness'] = this.friendliness;
      json[r'punctuality'] = this.punctuality;
      json[r'reliability'] = this.reliability;
    if (this.communication != null) {
      json[r'communication'] = this.communication;
    } else {
      json[r'communication'] = null;
    }
    if (this.carefulHandling != null) {
      json[r'carefulHandling'] = this.carefulHandling;
    } else {
      json[r'carefulHandling'] = null;
    }
    if (this.comment != null) {
      json[r'comment'] = this.comment;
    } else {
      json[r'comment'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [UserRating] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserRating? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "UserRating[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "UserRating[id]" has a null value in JSON.');
        assert(json.containsKey(r'rentRequestId'), 'Required key "UserRating[rentRequestId]" is missing from JSON.');
        assert(json[r'rentRequestId'] != null, 'Required key "UserRating[rentRequestId]" has a null value in JSON.');
        assert(json.containsKey(r'reviewerId'), 'Required key "UserRating[reviewerId]" is missing from JSON.');
        assert(json[r'reviewerId'] != null, 'Required key "UserRating[reviewerId]" has a null value in JSON.');
        assert(json.containsKey(r'revieweeId'), 'Required key "UserRating[revieweeId]" is missing from JSON.');
        assert(json[r'revieweeId'] != null, 'Required key "UserRating[revieweeId]" has a null value in JSON.');
        assert(json.containsKey(r'friendliness'), 'Required key "UserRating[friendliness]" is missing from JSON.');
        assert(json[r'friendliness'] != null, 'Required key "UserRating[friendliness]" has a null value in JSON.');
        assert(json.containsKey(r'punctuality'), 'Required key "UserRating[punctuality]" is missing from JSON.');
        assert(json[r'punctuality'] != null, 'Required key "UserRating[punctuality]" has a null value in JSON.');
        assert(json.containsKey(r'reliability'), 'Required key "UserRating[reliability]" is missing from JSON.');
        assert(json[r'reliability'] != null, 'Required key "UserRating[reliability]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "UserRating[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "UserRating[createdAt]" has a null value in JSON.');
        return true;
      }());

      return UserRating(
        id: mapValueOfType<int>(json, r'id')!,
        rentRequestId: mapValueOfType<int>(json, r'rentRequestId')!,
        reviewerId: mapValueOfType<int>(json, r'reviewerId')!,
        revieweeId: mapValueOfType<int>(json, r'revieweeId')!,
        friendliness: mapValueOfType<int>(json, r'friendliness')!,
        punctuality: mapValueOfType<int>(json, r'punctuality')!,
        reliability: mapValueOfType<int>(json, r'reliability')!,
        communication: mapValueOfType<int>(json, r'communication'),
        carefulHandling: mapValueOfType<int>(json, r'carefulHandling'),
        comment: mapValueOfType<String>(json, r'comment'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<UserRating> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserRating>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserRating.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserRating> mapFromJson(dynamic json) {
    final map = <String, UserRating>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserRating.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserRating-objects as value to a dart map
  static Map<String, List<UserRating>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserRating>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserRating.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'rentRequestId',
    'reviewerId',
    'revieweeId',
    'friendliness',
    'punctuality',
    'reliability',
    'createdAt',
  };
}

