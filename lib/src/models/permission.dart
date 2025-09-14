/// Permission model for Traccar API
/// Based on official Traccar API specification
/// 
/// This is a permission map that contains two object indexes. It is used to
/// link/unlink objects. Order is important. Example: { deviceId:8, geofenceId: 16 }
class Permission {
  final int? userId;
  final int? deviceId;
  final int? groupId;
  final int? geofenceId;
  final int? notificationId;
  final int? calendarId;
  final int? attributeId;
  final int? driverId;
  final int? managedUserId;
  final int? commandId;

  const Permission({
    this.userId,
    this.deviceId,
    this.groupId,
    this.geofenceId,
    this.notificationId,
    this.calendarId,
    this.attributeId,
    this.driverId,
    this.managedUserId,
    this.commandId,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      userId: json['userId'] as int?,
      deviceId: json['deviceId'] as int?,
      groupId: json['groupId'] as int?,
      geofenceId: json['geofenceId'] as int?,
      notificationId: json['notificationId'] as int?,
      calendarId: json['calendarId'] as int?,
      attributeId: json['attributeId'] as int?,
      driverId: json['driverId'] as int?,
      managedUserId: json['managedUserId'] as int?,
      commandId: json['commandId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (userId != null) data['userId'] = userId;
    if (deviceId != null) data['deviceId'] = deviceId;
    if (groupId != null) data['groupId'] = groupId;
    if (geofenceId != null) data['geofenceId'] = geofenceId;
    if (notificationId != null) data['notificationId'] = notificationId;
    if (calendarId != null) data['calendarId'] = calendarId;
    if (attributeId != null) data['attributeId'] = attributeId;
    if (driverId != null) data['driverId'] = driverId;
    if (managedUserId != null) data['managedUserId'] = managedUserId;
    if (commandId != null) data['commandId'] = commandId;

    return data;
  }

  /// Creates a permission to link a user to a device
  factory Permission.userDevice({
    required int userId,
    required int deviceId,
  }) {
    return Permission(
      userId: userId,
      deviceId: deviceId,
    );
  }

  /// Creates a permission to link a user to a group
  factory Permission.userGroup({
    required int userId,
    required int groupId,
  }) {
    return Permission(
      userId: userId,
      groupId: groupId,
    );
  }

  /// Creates a permission to link a device to a geofence
  factory Permission.deviceGeofence({
    required int deviceId,
    required int geofenceId,
  }) {
    return Permission(
      deviceId: deviceId,
      geofenceId: geofenceId,
    );
  }

  /// Creates a permission to link a user to a geofence
  factory Permission.userGeofence({
    required int userId,
    required int geofenceId,
  }) {
    return Permission(
      userId: userId,
      geofenceId: geofenceId,
    );
  }

  /// Creates a permission to link a user to a notification
  factory Permission.userNotification({
    required int userId,
    required int notificationId,
  }) {
    return Permission(
      userId: userId,
      notificationId: notificationId,
    );
  }

  /// Creates a permission to link a user to a calendar
  factory Permission.userCalendar({
    required int userId,
    required int calendarId,
  }) {
    return Permission(
      userId: userId,
      calendarId: calendarId,
    );
  }

  /// Creates a permission to link a user to an attribute
  factory Permission.userAttribute({
    required int userId,
    required int attributeId,
  }) {
    return Permission(
      userId: userId,
      attributeId: attributeId,
    );
  }

  /// Creates a permission to link a device to a driver
  factory Permission.deviceDriver({
    required int deviceId,
    required int driverId,
  }) {
    return Permission(
      deviceId: deviceId,
      driverId: driverId,
    );
  }

  /// Creates a permission to link a user to manage another user
  factory Permission.userManager({
    required int userId,
    required int managedUserId,
  }) {
    return Permission(
      userId: userId,
      managedUserId: managedUserId,
    );
  }

  /// Creates a permission to link a device to a command
  factory Permission.deviceCommand({
    required int deviceId,
    required int commandId,
  }) {
    return Permission(
      deviceId: deviceId,
      commandId: commandId,
    );
  }

  Permission copyWith({
    int? userId,
    int? deviceId,
    int? groupId,
    int? geofenceId,
    int? notificationId,
    int? calendarId,
    int? attributeId,
    int? driverId,
    int? managedUserId,
    int? commandId,
  }) {
    return Permission(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      groupId: groupId ?? this.groupId,
      geofenceId: geofenceId ?? this.geofenceId,
      notificationId: notificationId ?? this.notificationId,
      calendarId: calendarId ?? this.calendarId,
      attributeId: attributeId ?? this.attributeId,
      driverId: driverId ?? this.driverId,
      managedUserId: managedUserId ?? this.managedUserId,
      commandId: commandId ?? this.commandId,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (userId != null) parts.add('userId: $userId');
    if (deviceId != null) parts.add('deviceId: $deviceId');
    if (groupId != null) parts.add('groupId: $groupId');
    if (geofenceId != null) parts.add('geofenceId: $geofenceId');
    if (notificationId != null) parts.add('notificationId: $notificationId');
    if (calendarId != null) parts.add('calendarId: $calendarId');
    if (attributeId != null) parts.add('attributeId: $attributeId');
    if (driverId != null) parts.add('driverId: $driverId');
    if (managedUserId != null) parts.add('managedUserId: $managedUserId');
    if (commandId != null) parts.add('commandId: $commandId');
    
    return 'Permission(${parts.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
        other.userId == userId &&
        other.deviceId == deviceId &&
        other.groupId == groupId &&
        other.geofenceId == geofenceId &&
        other.notificationId == notificationId &&
        other.calendarId == calendarId &&
        other.attributeId == attributeId &&
        other.driverId == driverId &&
        other.managedUserId == managedUserId &&
        other.commandId == commandId;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      deviceId,
      groupId,
      geofenceId,
      notificationId,
      calendarId,
      attributeId,
      driverId,
      managedUserId,
      commandId,
    );
  }
}