//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UserProfile {
  /// Returns a new [UserProfile] instance.
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.rating,
    required this.createdAt,
    required this.lastOnlineAt,
    required this.itemCount,
    required this.ratingCount,
    this.shareCount,
    this.avatarUuid,
  });

  int id;

  String name;

  String email;

  String? bio;

  double? rating;

  DateTime createdAt;

  DateTime lastOnlineAt;

  int itemCount;

  int ratingCount;

  int? shareCount;

  String? avatarUuid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UserProfile &&
    other.id == id &&
    other.name == name &&
    other.email == email &&
    other.bio == bio &&
    other.rating == rating &&
    other.createdAt == createdAt &&
    other.lastOnlineAt == lastOnlineAt &&
    other.itemCount == itemCount &&
    other.ratingCount == ratingCount &&
    other.shareCount == shareCount &&
    other.avatarUuid == avatarUuid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (email.hashCode) +
    (bio == null ? 0 : bio!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (createdAt.hashCode) +
    (lastOnlineAt.hashCode) +
    (itemCount.hashCode) +
    (ratingCount.hashCode) +
    (shareCount == null ? 0 : shareCount!.hashCode) +
    (avatarUuid == null ? 0 : avatarUuid!.hashCode);

  @override
  String toString() => 'UserProfile[id=$id, name=$name, email=$email, bio=$bio, rating=$rating, createdAt=$createdAt, lastOnlineAt=$lastOnlineAt, itemCount=$itemCount, ratingCount=$ratingCount, shareCount=$shareCount, avatarUuid=$avatarUuid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'email'] = this.email;
    if (this.bio != null) {
      json[r'bio'] = this.bio;
    } else {
      json[r'bio'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'lastOnlineAt'] = this.lastOnlineAt.toUtc().toIso8601String();
      json[r'itemCount'] = this.itemCount;
      json[r'ratingCount'] = this.ratingCount;
    if (this.shareCount != null) {
      json[r'shareCount'] = this.shareCount;
    } else {
      json[r'shareCount'] = null;
    }
    if (this.avatarUuid != null) {
      json[r'avatarUuid'] = this.avatarUuid;
    } else {
      json[r'avatarUuid'] = null;
    }
    return json;
  }

  /// Returns a new [UserProfile] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UserProfile? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "UserProfile[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "UserProfile[id]" has a null value in JSON.');
        assert(json.containsKey(r'name'), 'Required key "UserProfile[name]" is missing from JSON.');
        assert(json[r'name'] != null, 'Required key "UserProfile[name]" has a null value in JSON.');
        assert(json.containsKey(r'email'), 'Required key "UserProfile[email]" is missing from JSON.');
        assert(json[r'email'] != null, 'Required key "UserProfile[email]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "UserProfile[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "UserProfile[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'lastOnlineAt'), 'Required key "UserProfile[lastOnlineAt]" is missing from JSON.');
        assert(json[r'lastOnlineAt'] != null, 'Required key "UserProfile[lastOnlineAt]" has a null value in JSON.');
        assert(json.containsKey(r'itemCount'), 'Required key "UserProfile[itemCount]" is missing from JSON.');
        assert(json[r'itemCount'] != null, 'Required key "UserProfile[itemCount]" has a null value in JSON.');
        assert(json.containsKey(r'ratingCount'), 'Required key "UserProfile[ratingCount]" is missing from JSON.');
        assert(json[r'ratingCount'] != null, 'Required key "UserProfile[ratingCount]" has a null value in JSON.');
        return true;
      }());

      return UserProfile(
        id: mapValueOfType<int>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        email: mapValueOfType<String>(json, r'email')!,
        bio: mapValueOfType<String>(json, r'bio'),
        rating: mapValueOfType<double>(json, r'rating'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        lastOnlineAt: mapDateTime(json, r'lastOnlineAt', r'')!,
        itemCount: mapValueOfType<int>(json, r'itemCount')!,
        ratingCount: mapValueOfType<int>(json, r'ratingCount')!,
        shareCount: mapValueOfType<int>(json, r'shareCount'),
        avatarUuid: mapValueOfType<String>(json, r'avatarUuid'),
      );
    }
    return null;
  }

  static List<UserProfile> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UserProfile>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UserProfile.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UserProfile> mapFromJson(dynamic json) {
    final map = <String, UserProfile>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UserProfile.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UserProfile-objects as value to a dart map
  static Map<String, List<UserProfile>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UserProfile>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UserProfile.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'email',
    'createdAt',
    'lastOnlineAt',
    'itemCount',
    'ratingCount',
  };
}

