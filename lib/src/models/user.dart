/// User model for Traccar API
/// Based on official Traccar API specification
class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final bool readonly;
  final bool administrator;
  final String? map;
  final double? latitude;
  final double? longitude;
  final int? zoom;
  final String? password;
  final String? coordinateFormat;
  final bool disabled;
  final DateTime? expirationTime;
  final int? deviceLimit;
  final int? userLimit;
  final bool deviceReadonly;
  final bool limitCommands;
  final bool fixedEmail;
  final String? poiLayer;
  final Map<String, dynamic> attributes;

  const User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.readonly = false,
    this.administrator = false,
    this.map,
    this.latitude,
    this.longitude,
    this.zoom,
    this.password,
    this.coordinateFormat,
    this.disabled = false,
    this.expirationTime,
    this.deviceLimit,
    this.userLimit,
    this.deviceReadonly = false,
    this.limitCommands = false,
    this.fixedEmail = false,
    this.poiLayer,
    this.attributes = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      readonly: json['readonly'] as bool? ?? false,
      administrator: json['administrator'] as bool? ?? false,
      map: json['map'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      zoom: json['zoom'] as int?,
      password: json['password'] as String?,
      coordinateFormat: json['coordinateFormat'] as String?,
      disabled: json['disabled'] as bool? ?? false,
      expirationTime: json['expirationTime'] != null
          ? DateTime.parse(json['expirationTime'] as String)
          : null,
      deviceLimit: json['deviceLimit'] as int?,
      userLimit: json['userLimit'] as int?,
      deviceReadonly: json['deviceReadonly'] as bool? ?? false,
      limitCommands: json['limitCommands'] as bool? ?? false,
      fixedEmail: json['fixedEmail'] as bool? ?? false,
      poiLayer: json['poiLayer'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'readonly': readonly,
      'administrator': administrator,
      'disabled': disabled,
      'deviceReadonly': deviceReadonly,
      'limitCommands': limitCommands,
      'fixedEmail': fixedEmail,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (map != null) data['map'] = map;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (zoom != null) data['zoom'] = zoom;
    if (password != null) data['password'] = password;
    if (coordinateFormat != null) data['coordinateFormat'] = coordinateFormat;
    if (expirationTime != null) data['expirationTime'] = expirationTime!.toIso8601String();
    if (deviceLimit != null) data['deviceLimit'] = deviceLimit;
    if (userLimit != null) data['userLimit'] = userLimit;
    if (poiLayer != null) data['poiLayer'] = poiLayer;

    return data;
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    bool? readonly,
    bool? administrator,
    String? map,
    double? latitude,
    double? longitude,
    int? zoom,
    String? password,
    String? coordinateFormat,
    bool? disabled,
    DateTime? expirationTime,
    int? deviceLimit,
    int? userLimit,
    bool? deviceReadonly,
    bool? limitCommands,
    bool? fixedEmail,
    String? poiLayer,
    Map<String, dynamic>? attributes,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      readonly: readonly ?? this.readonly,
      administrator: administrator ?? this.administrator,
      map: map ?? this.map,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      password: password ?? this.password,
      coordinateFormat: coordinateFormat ?? this.coordinateFormat,
      disabled: disabled ?? this.disabled,
      expirationTime: expirationTime ?? this.expirationTime,
      deviceLimit: deviceLimit ?? this.deviceLimit,
      userLimit: userLimit ?? this.userLimit,
      deviceReadonly: deviceReadonly ?? this.deviceReadonly,
      limitCommands: limitCommands ?? this.limitCommands,
      fixedEmail: fixedEmail ?? this.fixedEmail,
      poiLayer: poiLayer ?? this.poiLayer,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, administrator: $administrator)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}