//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ItemSearchRequest {
  /// Returns a new [ItemSearchRequest] instance.
  ItemSearchRequest({
    this.query,
    this.lat,
    this.lng,
    this.maxDistanceKm,
    this.categories = const [],
    this.minScore,
    this.sortBy,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? query;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? lat;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? lng;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? maxDistanceKm;

  List<String> categories;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? minScore;

  ItemSearchRequestSortByEnum? sortBy;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ItemSearchRequest &&
    other.query == query &&
    other.lat == lat &&
    other.lng == lng &&
    other.maxDistanceKm == maxDistanceKm &&
    _deepEquality.equals(other.categories, categories) &&
    other.minScore == minScore &&
    other.sortBy == sortBy;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (query == null ? 0 : query!.hashCode) +
    (lat == null ? 0 : lat!.hashCode) +
    (lng == null ? 0 : lng!.hashCode) +
    (maxDistanceKm == null ? 0 : maxDistanceKm!.hashCode) +
    (categories.hashCode) +
    (minScore == null ? 0 : minScore!.hashCode) +
    (sortBy == null ? 0 : sortBy!.hashCode);

  @override
  String toString() => 'ItemSearchRequest[query=$query, lat=$lat, lng=$lng, maxDistanceKm=$maxDistanceKm, categories=$categories, minScore=$minScore, sortBy=$sortBy]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.query != null) {
      json[r'query'] = this.query;
    } else {
      json[r'query'] = null;
    }
    if (this.lat != null) {
      json[r'lat'] = this.lat;
    } else {
      json[r'lat'] = null;
    }
    if (this.lng != null) {
      json[r'lng'] = this.lng;
    } else {
      json[r'lng'] = null;
    }
    if (this.maxDistanceKm != null) {
      json[r'maxDistanceKm'] = this.maxDistanceKm;
    } else {
      json[r'maxDistanceKm'] = null;
    }
      json[r'categories'] = this.categories;
    if (this.minScore != null) {
      json[r'minScore'] = this.minScore;
    } else {
      json[r'minScore'] = null;
    }
    if (this.sortBy != null) {
      json[r'sortBy'] = this.sortBy;
    } else {
      json[r'sortBy'] = null;
    }
    return json;
  }

  /// Returns a new [ItemSearchRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ItemSearchRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ItemSearchRequest(
        query: mapValueOfType<String>(json, r'query'),
        lat: mapValueOfType<double>(json, r'lat'),
        lng: mapValueOfType<double>(json, r'lng'),
        maxDistanceKm: mapValueOfType<double>(json, r'maxDistanceKm'),
        categories: json[r'categories'] is Iterable
            ? (json[r'categories'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        minScore: mapValueOfType<double>(json, r'minScore'),
        sortBy: ItemSearchRequestSortByEnum.fromJson(json[r'sortBy']),
      );
    }
    return null;
  }

  static List<ItemSearchRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemSearchRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemSearchRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ItemSearchRequest> mapFromJson(dynamic json) {
    final map = <String, ItemSearchRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ItemSearchRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ItemSearchRequest-objects as value to a dart map
  static Map<String, List<ItemSearchRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ItemSearchRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ItemSearchRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class ItemSearchRequestSortByEnum {
  /// Instantiate a new enum with the provided [value].
  const ItemSearchRequestSortByEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const relevance = ItemSearchRequestSortByEnum._(r'relevance');
  static const distance = ItemSearchRequestSortByEnum._(r'distance');
  static const score = ItemSearchRequestSortByEnum._(r'score');
  static const newest = ItemSearchRequestSortByEnum._(r'newest');

  /// List of all possible values in this [enum][ItemSearchRequestSortByEnum].
  static const values = <ItemSearchRequestSortByEnum>[
    relevance,
    distance,
    score,
    newest,
  ];

  static ItemSearchRequestSortByEnum? fromJson(dynamic value) => ItemSearchRequestSortByEnumTypeTransformer().decode(value);

  static List<ItemSearchRequestSortByEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ItemSearchRequestSortByEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ItemSearchRequestSortByEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ItemSearchRequestSortByEnum] to String,
/// and [decode] dynamic data back to [ItemSearchRequestSortByEnum].
class ItemSearchRequestSortByEnumTypeTransformer {
  factory ItemSearchRequestSortByEnumTypeTransformer() => _instance ??= const ItemSearchRequestSortByEnumTypeTransformer._();

  const ItemSearchRequestSortByEnumTypeTransformer._();

  String encode(ItemSearchRequestSortByEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ItemSearchRequestSortByEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ItemSearchRequestSortByEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'relevance': return ItemSearchRequestSortByEnum.relevance;
        case r'distance': return ItemSearchRequestSortByEnum.distance;
        case r'score': return ItemSearchRequestSortByEnum.score;
        case r'newest': return ItemSearchRequestSortByEnum.newest;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ItemSearchRequestSortByEnumTypeTransformer] instance.
  static ItemSearchRequestSortByEnumTypeTransformer? _instance;
}


