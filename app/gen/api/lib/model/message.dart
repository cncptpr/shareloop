//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Message {
  /// Returns a new [Message] instance.
  Message({
    required this.id,
    required this.rentRequestId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  int id;

  int rentRequestId;

  int authorId;

  String content;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Message &&
    other.id == id &&
    other.rentRequestId == rentRequestId &&
    other.authorId == authorId &&
    other.content == content &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (rentRequestId.hashCode) +
    (authorId.hashCode) +
    (content.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Message[id=$id, rentRequestId=$rentRequestId, authorId=$authorId, content=$content, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'rentRequestId'] = this.rentRequestId;
      json[r'authorId'] = this.authorId;
      json[r'content'] = this.content;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Message] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Message? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'id'), 'Required key "Message[id]" is missing from JSON.');
        assert(json[r'id'] != null, 'Required key "Message[id]" has a null value in JSON.');
        assert(json.containsKey(r'rentRequestId'), 'Required key "Message[rentRequestId]" is missing from JSON.');
        assert(json[r'rentRequestId'] != null, 'Required key "Message[rentRequestId]" has a null value in JSON.');
        assert(json.containsKey(r'authorId'), 'Required key "Message[authorId]" is missing from JSON.');
        assert(json[r'authorId'] != null, 'Required key "Message[authorId]" has a null value in JSON.');
        assert(json.containsKey(r'content'), 'Required key "Message[content]" is missing from JSON.');
        assert(json[r'content'] != null, 'Required key "Message[content]" has a null value in JSON.');
        assert(json.containsKey(r'createdAt'), 'Required key "Message[createdAt]" is missing from JSON.');
        assert(json[r'createdAt'] != null, 'Required key "Message[createdAt]" has a null value in JSON.');
        return true;
      }());

      return Message(
        id: mapValueOfType<int>(json, r'id')!,
        rentRequestId: mapValueOfType<int>(json, r'rentRequestId')!,
        authorId: mapValueOfType<int>(json, r'authorId')!,
        content: mapValueOfType<String>(json, r'content')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Message> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Message>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Message.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Message> mapFromJson(dynamic json) {
    final map = <String, Message>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Message.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Message-objects as value to a dart map
  static Map<String, List<Message>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Message>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Message.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'rentRequestId',
    'authorId',
    'content',
    'createdAt',
  };
}

