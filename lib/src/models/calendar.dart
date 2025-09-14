/// Calendar model for Traccar API
/// Based on official Traccar API specification
class Calendar {
  final int? id;
  final String name;
  final String data;
  final Map<String, dynamic> attributes;

  const Calendar({
    this.id,
    required this.name,
    required this.data,
    this.attributes = const {},
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      data: json['data'] as String? ?? '',
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'data': this.data,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;

    return data;
  }

  Calendar copyWith({
    int? id,
    String? name,
    String? data,
    Map<String, dynamic>? attributes,
  }) {
    return Calendar(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() {
    return 'Calendar(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Calendar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}