/// Server model for Traccar API
/// Based on official Traccar API specification
class Server {
  final int? id;
  final bool registration;
  final bool readonly;
  final bool deviceReadonly;
  final bool limitCommands;
  final String? map;
  final String? bingKey;
  final String? mapUrl;
  final String? poiLayer;
  final double? latitude;
  final double? longitude;
  final int? zoom;
  final String? version;
  final bool forceSettings;
  final String? coordinateFormat;
  final bool openIdEnabled;
  final bool openIdForce;
  final Map<String, dynamic> attributes;

  const Server({
    this.id,
    this.registration = false,
    this.readonly = false,
    this.deviceReadonly = false,
    this.limitCommands = false,
    this.map,
    this.bingKey,
    this.mapUrl,
    this.poiLayer,
    this.latitude,
    this.longitude,
    this.zoom,
    this.version,
    this.forceSettings = false,
    this.coordinateFormat,
    this.openIdEnabled = false,
    this.openIdForce = false,
    this.attributes = const {},
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as int?,
      registration: json['registration'] as bool? ?? false,
      readonly: json['readonly'] as bool? ?? false,
      deviceReadonly: json['deviceReadonly'] as bool? ?? false,
      limitCommands: json['limitCommands'] as bool? ?? false,
      map: json['map'] as String?,
      bingKey: json['bingKey'] as String?,
      mapUrl: json['mapUrl'] as String?,
      poiLayer: json['poiLayer'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      zoom: json['zoom'] as int?,
      version: json['version'] as String?,
      forceSettings: json['forceSettings'] as bool? ?? false,
      coordinateFormat: json['coordinateFormat'] as String?,
      openIdEnabled: json['openIdEnabled'] as bool? ?? false,
      openIdForce: json['openIdForce'] as bool? ?? false,
      attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'registration': registration,
      'readonly': readonly,
      'deviceReadonly': deviceReadonly,
      'limitCommands': limitCommands,
      'forceSettings': forceSettings,
      'openIdEnabled': openIdEnabled,
      'openIdForce': openIdForce,
      'attributes': attributes,
    };

    if (id != null) data['id'] = id;
    if (map != null) data['map'] = map;
    if (bingKey != null) data['bingKey'] = bingKey;
    if (mapUrl != null) data['mapUrl'] = mapUrl;
    if (poiLayer != null) data['poiLayer'] = poiLayer;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (zoom != null) data['zoom'] = zoom;
    if (version != null) data['version'] = version;
    if (coordinateFormat != null) data['coordinateFormat'] = coordinateFormat;

    return data;
  }

  Server copyWith({
    int? id,
    bool? registration,
    bool? readonly,
    bool? deviceReadonly,
    bool? limitCommands,
    String? map,
    String? bingKey,
    String? mapUrl,
    String? poiLayer,
    double? latitude,
    double? longitude,
    int? zoom,
    String? version,
    bool? forceSettings,
    String? coordinateFormat,
    bool? openIdEnabled,
    bool? openIdForce,
    Map<String, dynamic>? attributes,
  }) {
    return Server(
      id: id ?? this.id,
      registration: registration ?? this.registration,
      readonly: readonly ?? this.readonly,
      deviceReadonly: deviceReadonly ?? this.deviceReadonly,
      limitCommands: limitCommands ?? this.limitCommands,
      map: map ?? this.map,
      bingKey: bingKey ?? this.bingKey,
      mapUrl: mapUrl ?? this.mapUrl,
      poiLayer: poiLayer ?? this.poiLayer,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoom: zoom ?? this.zoom,
      version: version ?? this.version,
      forceSettings: forceSettings ?? this.forceSettings,
      coordinateFormat: coordinateFormat ?? this.coordinateFormat,
      openIdEnabled: openIdEnabled ?? this.openIdEnabled,
      openIdForce: openIdForce ?? this.openIdForce,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  String toString() {
    return 'Server(id: $id, version: $version, registration: $registration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Server && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}