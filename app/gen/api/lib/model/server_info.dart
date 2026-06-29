//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ServerInfo {
  /// Returns a new [ServerInfo] instance.
  ServerInfo({
    required this.serverVersion,
    required this.apiVersion,
    this.seeding,
  });

  /// Server version (bumped manually)
  String serverVersion;

  /// API version
  String apiVersion;

  /// Seeding status. `null` = disabled (no seed data configured), `\"prompt\"` = seed data available but never seeded, `\"enabled\"` = seeding already performed, available for re-seed. 
  ServerInfoSeedingEnum? seeding;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ServerInfo &&
    other.serverVersion == serverVersion &&
    other.apiVersion == apiVersion &&
    other.seeding == seeding;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (serverVersion.hashCode) +
    (apiVersion.hashCode) +
    (seeding == null ? 0 : seeding!.hashCode);

  @override
  String toString() => 'ServerInfo[serverVersion=$serverVersion, apiVersion=$apiVersion, seeding=$seeding]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'serverVersion'] = this.serverVersion;
      json[r'apiVersion'] = this.apiVersion;
    if (this.seeding != null) {
      json[r'seeding'] = this.seeding;
    } else {
      json[r'seeding'] = null;
    }
    return json;
  }

  /// Returns a new [ServerInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ServerInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'serverVersion'), 'Required key "ServerInfo[serverVersion]" is missing from JSON.');
        assert(json[r'serverVersion'] != null, 'Required key "ServerInfo[serverVersion]" has a null value in JSON.');
        assert(json.containsKey(r'apiVersion'), 'Required key "ServerInfo[apiVersion]" is missing from JSON.');
        assert(json[r'apiVersion'] != null, 'Required key "ServerInfo[apiVersion]" has a null value in JSON.');
        return true;
      }());

      return ServerInfo(
        serverVersion: mapValueOfType<String>(json, r'serverVersion')!,
        apiVersion: mapValueOfType<String>(json, r'apiVersion')!,
        seeding: ServerInfoSeedingEnum.fromJson(json[r'seeding']),
      );
    }
    return null;
  }

  static List<ServerInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ServerInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ServerInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ServerInfo> mapFromJson(dynamic json) {
    final map = <String, ServerInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ServerInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ServerInfo-objects as value to a dart map
  static Map<String, List<ServerInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ServerInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ServerInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'serverVersion',
    'apiVersion',
  };
}

/// Seeding status. `null` = disabled (no seed data configured), `\"prompt\"` = seed data available but never seeded, `\"enabled\"` = seeding already performed, available for re-seed. 
class ServerInfoSeedingEnum {
  /// Instantiate a new enum with the provided [value].
  const ServerInfoSeedingEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const prompt = ServerInfoSeedingEnum._(r'prompt');
  static const enabled = ServerInfoSeedingEnum._(r'enabled');

  /// List of all possible values in this [enum][ServerInfoSeedingEnum].
  static const values = <ServerInfoSeedingEnum>[
    prompt,
    enabled,
  ];

  static ServerInfoSeedingEnum? fromJson(dynamic value) => ServerInfoSeedingEnumTypeTransformer().decode(value);

  static List<ServerInfoSeedingEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ServerInfoSeedingEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ServerInfoSeedingEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ServerInfoSeedingEnum] to String,
/// and [decode] dynamic data back to [ServerInfoSeedingEnum].
class ServerInfoSeedingEnumTypeTransformer {
  factory ServerInfoSeedingEnumTypeTransformer() => _instance ??= const ServerInfoSeedingEnumTypeTransformer._();

  const ServerInfoSeedingEnumTypeTransformer._();

  String encode(ServerInfoSeedingEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ServerInfoSeedingEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ServerInfoSeedingEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'prompt': return ServerInfoSeedingEnum.prompt;
        case r'enabled': return ServerInfoSeedingEnum.enabled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ServerInfoSeedingEnumTypeTransformer] instance.
  static ServerInfoSeedingEnumTypeTransformer? _instance;
}


