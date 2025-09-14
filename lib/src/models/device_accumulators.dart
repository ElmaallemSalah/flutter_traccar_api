/// DeviceAccumulators model for Traccar API
/// Based on official Traccar API specification
class DeviceAccumulators {
  final int deviceId;
  final double totalDistance;
  final double hours;

  const DeviceAccumulators({
    required this.deviceId,
    required this.totalDistance,
    required this.hours,
  });

  factory DeviceAccumulators.fromJson(Map<String, dynamic> json) {
    return DeviceAccumulators(
      deviceId: json['deviceId'] as int? ?? 0,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'totalDistance': totalDistance,
      'hours': hours,
    };
  }

  DeviceAccumulators copyWith({
    int? deviceId,
    double? totalDistance,
    double? hours,
  }) {
    return DeviceAccumulators(
      deviceId: deviceId ?? this.deviceId,
      totalDistance: totalDistance ?? this.totalDistance,
      hours: hours ?? this.hours,
    );
  }

  /// Get total distance in kilometers
  double get totalDistanceKm => totalDistance / 1000;

  /// Get total distance in miles
  double get totalDistanceMiles => totalDistance / 1609.34;

  @override
  String toString() {
    return 'DeviceAccumulators(deviceId: $deviceId, totalDistance: $totalDistance, hours: $hours)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceAccumulators &&
        other.deviceId == deviceId &&
        other.totalDistance == totalDistance &&
        other.hours == hours;
  }

  @override
  int get hashCode {
    return Object.hash(deviceId, totalDistance, hours);
  }
}