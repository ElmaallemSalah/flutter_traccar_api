/// NotificationType model for Traccar API
/// Based on official Traccar API specification
class NotificationType {
  final String type;

  const NotificationType({
    required this.type,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) {
    return NotificationType(
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }

  NotificationType copyWith({
    String? type,
  }) {
    return NotificationType(
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'NotificationType(type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationType && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}