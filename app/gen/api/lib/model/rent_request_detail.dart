//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RentRequestDetail {
  /// Returns a new [RentRequestDetail] instance.
  RentRequestDetail({
    required this.id,
    required this.itemId,
    required this.requester,
    required this.itemTitle,
    required this.ownerName,
    required this.ownerId,
    this.latestAcceptedOfferId,
    this.latestOpenOfferId,
    this.borrowConfirmedAt,
    this.returnedAt,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.offers = const [],
    required this.lastRead,
  });

  int id;

  int itemId;

  Person requester;

  String itemTitle;

  String ownerName;

  int ownerId;

  int? latestAcceptedOfferId;

  int? latestOpenOfferId;

  DateTime? borrowConfirmedAt;

  DateTime? returnedAt;

  DateTime createdAt;

  DateTime updatedAt;

  List<Message> messages;

  List<RentOffer> offers;

  DateTime lastRead;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RentRequestDetail &&
    other.id == id &&
    other.itemId == itemId &&
    other.requester == requester &&
    other.itemTitle == itemTitle &&
    other.ownerName == ownerName &&
    other.ownerId == ownerId &&
    other.latestAcceptedOfferId == latestAcceptedOfferId &&
    other.latestOpenOfferId == latestOpenOfferId &&
    other.borrowConfirmedAt == borrowConfirmedAt &&
    other.returnedAt == returnedAt &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt &&
    _deepEquality.equals(other.messages, messages) &&
    _deepEquality.equals(other.offers, offers) &&
    other.lastRead == lastRead;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (itemId.hashCode) +
    (requester.hashCode) +
    (itemTitle.hashCode) +
    (ownerName.hashCode) +
    (ownerId.hashCode) +
    (latestAcceptedOfferId == null ? 0 : latestAcceptedOfferId!.hashCode) +
    (latestOpenOfferId == null ? 0 : latestOpenOfferId!.hashCode) +
    (borrowConfirmedAt == null ? 0 : borrowConfirmedAt!.hashCode) +
    (returnedAt == null ? 0 : returnedAt!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode) +
    (messages.hashCode) +
    (offers.hashCode) +
    (lastRead.hashCode);

  @override
  String toString() => 'RentRequestDetail[id=$id, itemId=$itemId, requester=$requester, itemTitle=$itemTitle, ownerName=$ownerName, ownerId=$ownerId, latestAcceptedOfferId=$latestAcceptedOfferId, latestOpenOfferId=$latestOpenOfferId, borrowConfirmedAt=$borrowConfirmedAt, returnedAt=$returnedAt, createdAt=$createdAt, updatedAt=$updatedAt, messages=$messages, offers=$offers, lastRead=$lastRead]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'itemId'] = this.itemId;
      json[r'requester'] = this.requester;
      json[r'itemTitle'] = this.itemTitle;
      json[r'ownerName'] = this.ownerName;
      json[r'ownerId'] = this.ownerId;
    if (this.latestAcceptedOfferId != null) {
      json[r'latestAcceptedOfferId'] = this.latestAcceptedOfferId;
    } else {
      json[r'latestAcceptedOfferId'] = null;
    }
    if (this.latestOpenOfferId != null) {
      json[r'latestOpenOfferId'] = this.latestOpenOfferId;
    } else {
      json[r'latestOpenOfferId'] = null;
    }
    if (this.borrowConfirmedAt != null) {
      json[r'borrowConfirmedAt'] = this.borrowConfirmedAt!.toUtc().toIso8601String();
    } else {
      json[r'borrowConfirmedAt'] = null;
    }
    if (this.returnedAt != null) {
      json[r'returnedAt'] = this.returnedAt!.toUtc().toIso8601String();
    } else {
      json[r'returnedAt'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
      json[r'messages'] = this.messages;
      json[r'offers'] = this.offers;
      json[r'lastRead'] = this.lastRead.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [RentRequestDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RentRequestDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "RentRequestDetail[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "RentRequestDetail[id]" has a null value in JSON.');
        assert(json.containsKey(r'itemId'), 'Required key "RentRequestDetail[itemId]" is missing from JSON.');
        assert(json[r'itemId'] != null, 'Required key "RentRequestDetail[itemId]" has a null value in JSON.');
        assert(json.containsKey(r'requester'), 'Required key "RentRequestDetail[requester]" is missing from JSON.');
        assert(json[r'requester'] != null, 'Required key "RentRequestDetail[requester]" has a null value in JSON.');
        assert(json.containsKey(r'itemTitle'), 'Required key "RentRequestDetail[itemTitle]" is missing from JSON.');
        assert(json[r'itemTitle'] != null, 'Required key "RentRequestDetail[itemTitle]" has a null value in JSON.');
        assert(json.containsKey(r'ownerName'), 'Required key "RentRequestDetail[ownerName]" is missing from JSON.');
        assert(json[r'ownerName'] != null, 'Required key "RentRequestDetail[ownerName]" has a null value in JSON.');
        assert(json.containsKey(r'ownerId'), 'Required key "RentRequestDetail[ownerId]" is missing from JSON.');
        assert(json[r'ownerId'] != null, 'Required key "RentRequestDetail[ownerId]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "RentRequestDetail[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "RentRequestDetail[createdAt]" has a null value in JSON.');
        assert(json.containsKey(r'updatedAt'), 'Required key "RentRequestDetail[updatedAt]" is missing from JSON.');
        assert(json[r'updatedAt'] != null, 'Required key "RentRequestDetail[updatedAt]" has a null value in JSON.');
        assert(json.containsKey(r'messages'), 'Required key "RentRequestDetail[messages]" is missing from JSON.');
        assert(json[r'messages'] != null, 'Required key "RentRequestDetail[messages]" has a null value in JSON.');
        assert(json.containsKey(r'offers'), 'Required key "RentRequestDetail[offers]" is missing from JSON.');
        assert(json[r'offers'] != null, 'Required key "RentRequestDetail[offers]" has a null value in JSON.');
        assert(json.containsKey(r'lastRead'), 'Required key "RentRequestDetail[lastRead]" is missing from JSON.');
        assert(json[r'lastRead'] != null, 'Required key "RentRequestDetail[lastRead]" has a null value in JSON.');
        return true;
      }());

      return RentRequestDetail(
        id: mapValueOfType<int>(json, r'id')!,
        itemId: mapValueOfType<int>(json, r'itemId')!,
        requester: Person.fromJson(json[r'requester'])!,
        itemTitle: mapValueOfType<String>(json, r'itemTitle')!,
        ownerName: mapValueOfType<String>(json, r'ownerName')!,
        ownerId: mapValueOfType<int>(json, r'ownerId')!,
        latestAcceptedOfferId: mapValueOfType<int>(json, r'latestAcceptedOfferId'),
        latestOpenOfferId: mapValueOfType<int>(json, r'latestOpenOfferId'),
        borrowConfirmedAt: mapDateTime(json, r'borrowConfirmedAt', r''),
        returnedAt: mapDateTime(json, r'returnedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
        messages: Message.listFromJson(json[r'messages']),
        offers: RentOffer.listFromJson(json[r'offers']),
        lastRead: mapDateTime(json, r'lastRead', r'')!,
      );
    }
    return null;
  }

  static List<RentRequestDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RentRequestDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RentRequestDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RentRequestDetail> mapFromJson(dynamic json) {
    final map = <String, RentRequestDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RentRequestDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RentRequestDetail-objects as value to a dart map
  static Map<String, List<RentRequestDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RentRequestDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RentRequestDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'itemId',
    'requester',
    'itemTitle',
    'ownerName',
    'ownerId',
    'createdAt',
    'updatedAt',
    'messages',
    'offers',
    'lastRead',
  };
}

