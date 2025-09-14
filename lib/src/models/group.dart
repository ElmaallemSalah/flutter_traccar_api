/// Group model for Traccar API
/// Based on official Traccar API specification
class Group {
  final int? id;
  final String name;
  final int? groupId;
  final Map<String, dynamic> attributes;

  const Group({
    this.id,
    required this.name,
    this.groupId,
    this.attributes = const {},
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      groupId: json['groupId'] as int?,
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;
    if (groupId != null) data['groupId'] = groupId;

    return data;
  }

  Group copyWith({
    int? id,
    String? name,
    int? groupId,
    Map<String, dynamic>? attributes,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}