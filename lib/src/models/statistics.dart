/// Statistics model for Traccar API
/// Based on official Traccar API specification
class Statistics {
  final DateTime captureTime;
  final int activeUsers;
  final int activeDevices;
  final int requests;
  final int messagesReceived;
  final int messagesStored;

  const Statistics({
    required this.captureTime,
    required this.activeUsers,
    required this.activeDevices,
    required this.requests,
    required this.messagesReceived,
    required this.messagesStored,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      captureTime: DateTime.parse(json['captureTime'] as String),
      activeUsers: json['activeUsers'] as int? ?? 0,
      activeDevices: json['activeDevices'] as int? ?? 0,
      requests: json['requests'] as int? ?? 0,
      messagesReceived: json['messagesReceived'] as int? ?? 0,
      messagesStored: json['messagesStored'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'captureTime': captureTime.toIso8601String(),
      'activeUsers': activeUsers,
      'activeDevices': activeDevices,
      'requests': requests,
      'messagesReceived': messagesReceived,
      'messagesStored': messagesStored,
    };
  }

  Statistics copyWith({
    DateTime? captureTime,
    int? activeUsers,
    int? activeDevices,
    int? requests,
    int? messagesReceived,
    int? messagesStored,
  }) {
    return Statistics(
      captureTime: captureTime ?? this.captureTime,
      activeUsers: activeUsers ?? this.activeUsers,
      activeDevices: activeDevices ?? this.activeDevices,
      requests: requests ?? this.requests,
      messagesReceived: messagesReceived ?? this.messagesReceived,
      messagesStored: messagesStored ?? this.messagesStored,
    );
  }

  @override
  String toString() {
    return 'Statistics(captureTime: $captureTime, activeUsers: $activeUsers, activeDevices: $activeDevices, requests: $requests, messagesReceived: $messagesReceived, messagesStored: $messagesStored)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Statistics &&
        other.captureTime == captureTime &&
        other.activeUsers == activeUsers &&
        other.activeDevices == activeDevices &&
        other.requests == requests &&
        other.messagesReceived == messagesReceived &&
        other.messagesStored == messagesStored;
  }

  @override
  int get hashCode {
    return Object.hash(
      captureTime,
      activeUsers,
      activeDevices,
      requests,
      messagesReceived,
      messagesStored,
    );
  }
}