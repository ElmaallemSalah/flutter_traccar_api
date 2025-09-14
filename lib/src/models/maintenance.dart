/// Maintenance model representing a maintenance schedule or record
/// Based on official Traccar API specification
class Maintenance {
  final int? id;
  final String name;
  final String type;
  final double start;
  final double period;
  final Map<String, dynamic> attributes;

  const Maintenance({
    this.id,
    required this.name,
    required this.type,
    required this.start,
    required this.period,
    this.attributes = const {},
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      start: (json['start'] as num?)?.toDouble() ?? 0.0,
      period: (json['period'] as num?)?.toDouble() ?? 0.0,
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'start': start,
      'period': period,
      'attributes': attributes,
    };
  }

  Maintenance copyWith({
    int? id,
    String? name,
    String? type,
    double? start,
    double? period,
    Map<String, dynamic>? attributes,
  }) {
    return Maintenance(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      start: start ?? this.start,
      period: period ?? this.period,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Maintenance &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.start == start &&
        other.period == period;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, type, start, period);
  }

  @override
  String toString() {
    return 'Maintenance(id: $id, name: $name, type: $type, start: $start, period: $period)';
  }

  /// Get maintenance type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'mileage':
        return 'Mileage';
      case 'engine_hours':
      case 'engineHours':
        return 'Engine Hours';
      case 'time':
        return 'Time Based';
      case 'fuel':
        return 'Fuel Based';
      default:
        return type;
    }
  }

  /// Get formatted start value with unit
  String get formattedStart {
    switch (type.toLowerCase()) {
      case 'mileage':
        return '${start.toStringAsFixed(0)} km';
      case 'engine_hours':
      case 'engineHours':
        return '${start.toStringAsFixed(1)} hrs';
      case 'fuel':
        return '${start.toStringAsFixed(1)} L';
      default:
        return start.toStringAsFixed(1);
    }
  }

  /// Get formatted period value with unit
  String get formattedPeriod {
    switch (type.toLowerCase()) {
      case 'mileage':
        return '${period.toStringAsFixed(0)} km';
      case 'engine_hours':
      case 'engineHours':
        return '${period.toStringAsFixed(1)} hrs';
      case 'fuel':
        return '${period.toStringAsFixed(1)} L';
      default:
        return period.toStringAsFixed(1);
    }
  }
}

/// Maintenance alert model for UI display
class MaintenanceAlert {
  final int maintenanceId;
  final String maintenanceName;
  final int deviceId;
  final String deviceName;
  final String type;
  final double currentValue;
  final double threshold;
  final double progress;
  final bool isDueSoon;
  final bool isOverdue;
  final DateTime? dueDate;

  const MaintenanceAlert({
    required this.maintenanceId,
    required this.maintenanceName,
    required this.deviceId,
    required this.deviceName,
    required this.type,
    required this.currentValue,
    required this.threshold,
    required this.progress,
    required this.isDueSoon,
    required this.isOverdue,
    this.dueDate,
  });

  /// Get formatted current value with unit
  String get formattedCurrentValue {
    switch (type.toLowerCase()) {
      case 'mileage':
        return '${currentValue.toStringAsFixed(0)} km';
      case 'engine_hours':
      case 'engineHours':
        return '${currentValue.toStringAsFixed(1)} hrs';
      case 'fuel':
        return '${currentValue.toStringAsFixed(1)} L';
      default:
        return currentValue.toStringAsFixed(1);
    }
  }

  /// Get formatted threshold value with unit
  String get formattedThreshold {
    switch (type.toLowerCase()) {
      case 'mileage':
        return '${threshold.toStringAsFixed(0)} km';
      case 'engine_hours':
      case 'engineHours':
        return '${threshold.toStringAsFixed(1)} hrs';
      case 'fuel':
        return '${threshold.toStringAsFixed(1)} L';
      default:
        return threshold.toStringAsFixed(1);
    }
  }
}

/// Maintenance filter enum
enum MaintenanceFilter {
  all,
  active,
  overdue,
  dueSoon,
}

extension MaintenanceFilterExtension on MaintenanceFilter {
  String get displayName {
    switch (this) {
      case MaintenanceFilter.all:
        return 'All';
      case MaintenanceFilter.active:
        return 'Active';
      case MaintenanceFilter.overdue:
        return 'Overdue';
      case MaintenanceFilter.dueSoon:
        return 'Due Soon';
    }
  }
}