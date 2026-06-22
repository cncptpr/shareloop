//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LoginResult {
  /// Returns a new [LoginResult] instance.
  LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  User user;

  String accessToken;

  String refreshToken;

  DateTime accessExpiresAt;

  DateTime refreshExpiresAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LoginResult &&
    other.user == user &&
    other.accessToken == accessToken &&
    other.refreshToken == refreshToken &&
    other.accessExpiresAt == accessExpiresAt &&
    other.refreshExpiresAt == refreshExpiresAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (user.hashCode) +
    (accessToken.hashCode) +
    (refreshToken.hashCode) +
    (accessExpiresAt.hashCode) +
    (refreshExpiresAt.hashCode);

  @override
  String toString() => 'LoginResult[user=$user, accessToken=$accessToken, refreshToken=$refreshToken, accessExpiresAt=$accessExpiresAt, refreshExpiresAt=$refreshExpiresAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'user'] = this.user;
      json[r'accessToken'] = this.accessToken;
      json[r'refreshToken'] = this.refreshToken;
      json[r'accessExpiresAt'] = this.accessExpiresAt.toUtc().toIso8601String();
      json[r'refreshExpiresAt'] = this.refreshExpiresAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [LoginResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LoginResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'user'), 'Required key "LoginResult[user]" is missing from JSON.');
        assert(json[r'user'] != null, 'Required key "LoginResult[user]" has a null value in JSON.');
        assert(json.containsKey(r'accessToken'), 'Required key "LoginResult[accessToken]" is missing from JSON.');
        assert(json[r'accessToken'] != null, 'Required key "LoginResult[accessToken]" has a null value in JSON.');
        assert(json.containsKey(r'refreshToken'), 'Required key "LoginResult[refreshToken]" is missing from JSON.');
        assert(json[r'refreshToken'] != null, 'Required key "LoginResult[refreshToken]" has a null value in JSON.');
        assert(json.containsKey(r'accessExpiresAt'), 'Required key "LoginResult[accessExpiresAt]" is missing from JSON.');
        assert(json[r'accessExpiresAt'] != null, 'Required key "LoginResult[accessExpiresAt]" has a null value in JSON.');
        assert(json.containsKey(r'refreshExpiresAt'), 'Required key "LoginResult[refreshExpiresAt]" is missing from JSON.');
        assert(json[r'refreshExpiresAt'] != null, 'Required key "LoginResult[refreshExpiresAt]" has a null value in JSON.');
        return true;
      }());

      return LoginResult(
        user: User.fromJson(json[r'user'])!,
        accessToken: mapValueOfType<String>(json, r'accessToken')!,
        refreshToken: mapValueOfType<String>(json, r'refreshToken')!,
        accessExpiresAt: mapDateTime(json, r'accessExpiresAt', r'')!,
        refreshExpiresAt: mapDateTime(json, r'refreshExpiresAt', r'')!,
      );
    }
    return null;
  }

  static List<LoginResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LoginResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LoginResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LoginResult> mapFromJson(dynamic json) {
    final map = <String, LoginResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LoginResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LoginResult-objects as value to a dart map
  static Map<String, List<LoginResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LoginResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LoginResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'user',
    'accessToken',
    'refreshToken',
    'accessExpiresAt',
    'refreshExpiresAt',
  };
}

