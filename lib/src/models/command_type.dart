/// CommandType model for Traccar API
/// Based on official Traccar API specification
class CommandType {
  final String type;

  const CommandType({
    required this.type,
  });

  factory CommandType.fromJson(Map<String, dynamic> json) {
    return CommandType(
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }

  CommandType copyWith({
    String? type,
  }) {
    return CommandType(
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'CommandType(type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommandType && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}